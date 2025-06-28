import 'package:flutter/material.dart';
import 'package:smart_local_notification/smart_local_notification.dart';
import 'screens/home_screen.dart';
import 'utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the plugin
  await SmartLocalNotification.initialize();
  
  // Initialize background audio manager
  BackgroundAudioManager().initialize();
  
  // Initialize notification helper
  await NotificationHelper.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Local Notification Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
