import Foundation
import AVFoundation
import UIKit

class AudioManager: NSObject {
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession
    private var fadeTimer: Timer?
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    
    override init() {
        self.audioSession = AVAudioSession.sharedInstance()
        super.init()
    }
    
    func initialize() {
        setupAudioSession()
        setupNotificationObservers()
    }
    
    private func setupAudioSession() {
        do {
            // Configure for background audio playback
            try audioSession.setCategory(.playback, mode: .default, options: [
                .allowBluetooth,
                .allowBluetoothA2DP,
                .mixWithOthers // Allow mixing with other audio
            ])
            try audioSession.setActive(true)
        } catch {
            print("AudioManager: Failed to setup audio session: \(error)")
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func playAudio(settings: [String: Any]) {
        guard let audioPath = settings["audioPath"] as? String else {
            print("AudioManager: Audio path is required")
            return
        }
        
        let sourceType = settings["sourceType"] as? String ?? "asset"
        let loop = settings["loop"] as? Bool ?? false
        let volume = settings["volume"] as? Float ?? 1.0
        let fadeInDuration = settings["fadeInDuration"] as? Int
        let fadeOutDuration = settings["fadeOutDuration"] as? Int
        let playInBackground = settings["playInBackground"] as? Bool ?? true
        let respectSilentMode = settings["respectSilentMode"] as? Bool ?? false
        
        // Stop any currently playing audio
        stopAudio()
        
        // Setup audio session based on settings
        setupAudioSessionForPlayback(respectSilentMode: respectSilentMode)
        
        // Get audio URL based on source type
        guard let audioURL = getAudioURL(path: audioPath, sourceType: sourceType) else {
            print("AudioManager: Failed to get audio URL for path: \(audioPath)")
            return
        }
        
        do {
            // Create audio player
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = loop ? -1 : 0
            audioPlayer?.volume = fadeInDuration != nil ? 0.0 : volume
            
            // Prepare and start playback
            audioPlayer?.prepareToPlay()
            
            if playInBackground {
                startBackgroundTask()
            }
            
            audioPlayer?.play()
            
            // Handle fade in
            if let fadeInDuration = fadeInDuration, fadeInDuration > 0 {
                startFadeIn(targetVolume: volume, duration: TimeInterval(fadeInDuration) / 1000.0)
            }
            
        } catch {
            print("AudioManager: Failed to create audio player: \(error)")
        }
    }
    
    private func setupAudioSessionForPlayback(respectSilentMode: Bool) {
        do {
            if respectSilentMode {
                try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            } else {
                try audioSession.setCategory(.playback, mode: .default, options: [
                    .allowBluetooth,
                    .allowBluetoothA2DP,
                    .duckOthers // Duck other audio during playback
                ])
            }
            try audioSession.setActive(true)
        } catch {
            print("AudioManager: Failed to setup audio session for playback: \(error)")
        }
    }
    
    private func getAudioURL(path: String, sourceType: String) -> URL? {
        switch sourceType {
        case "asset":
            // Remove 'assets/' prefix if present
            let assetPath = path.hasPrefix("assets/") ? String(path.dropFirst(7)) : path
            
            // Get the file name and extension
            let pathComponents = assetPath.components(separatedBy: ".")
            guard pathComponents.count >= 2 else { return nil }
            
            let fileName = pathComponents.dropLast().joined(separator: ".")
            let fileExtension = pathComponents.last!
            
            return Bundle.main.url(forResource: fileName, withExtension: fileExtension)
            
        case "file":
            return URL(fileURLWithPath: path)
            
        case "url":
            return URL(string: path)
            
        default:
            return nil
        }
    }
    
    private func startFadeIn(targetVolume: Float, duration: TimeInterval) {
        stopFadeTimer()
        
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = targetVolume / Float(steps)
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            let newVolume = volumeStep * Float(currentStep)
            player.volume = min(newVolume, targetVolume)
            
            if currentStep >= steps {
                timer.invalidate()
                self.fadeTimer = nil
            }
        }
    }
    
    private func startFadeOut(duration: TimeInterval, completion: @escaping () -> Void) {
        stopFadeTimer()
        
        guard let player = audioPlayer else {
            completion()
            return
        }
        
        let initialVolume = player.volume
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = initialVolume / Float(steps)
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                completion()
                return
            }
            
            currentStep += 1
            let newVolume = initialVolume - (volumeStep * Float(currentStep))
            player.volume = max(newVolume, 0.0)
            
            if currentStep >= steps {
                timer.invalidate()
                self.fadeTimer = nil
                completion()
            }
        }
    }
    
    private func stopFadeTimer() {
        fadeTimer?.invalidate()
        fadeTimer = nil
    }
    
    private func startBackgroundTask() {
        endBackgroundTask()
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "AudioPlayback") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
        }
    }
    
    func stopAudio() {
        stopFadeTimer()
        audioPlayer?.stop()
        audioPlayer = nil
        endBackgroundTask()
        
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("AudioManager: Failed to deactivate audio session: \(error)")
        }
    }
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    // MARK: - Notification Handlers
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            audioPlayer?.pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                audioPlayer?.play()
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Headphones were unplugged, pause audio
            audioPlayer?.pause()
        default:
            break
        }
    }
    
    @objc private func appDidEnterBackground() {
        // Audio will continue playing in background if properly configured
    }
    
    @objc private func appWillEnterForeground() {
        // Resume audio if needed
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopAudio()
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            stopAudio()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("AudioManager: Decode error: \(error?.localizedDescription ?? "Unknown error")")
        stopAudio()
    }
}
