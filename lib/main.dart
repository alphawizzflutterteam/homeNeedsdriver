import 'package:deliveryboy_multivendor/Screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Helper/color.dart';
import 'Helper/constant.dart';
import 'Helper/push_notification_service.dart';
import 'Screens/Splash/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestLocationPermission();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // status bar color
    systemNavigationBarColor: Colors.transparent,
  ));
  final pushNotificationService = PushNotificationService();
  pushNotificationService.initialise();
  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
  runApp(MyApp());
}
Future<void> _requestLocationPermission() async {
  // Check if the permission is already granted
  if (await Permission.location.isGranted) {
    return;
  }

  // Request permission
  var status = await Permission.location.request();

  // Check the status and handle accordingly
  if (status.isGranted) {
    print("Location permission granted");
  } else {
    print("Location permission denied");
    // Handle the denial, for example, show a message or disable location-based features
  }
}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: primary_app,
        fontFamily: 'opensans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/home': (context) => Home(),
      },
    );
  }
}
