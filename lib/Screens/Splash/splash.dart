import 'dart:async';
import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Screens/Authentication/login.dart';
import 'package:deliveryboy_multivendor/Screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Helper/color.dart';
import '../../Helper/string.dart';

//splash screen of app
class Splash extends StatefulWidget {
  @override
  _SplashScreen createState() => _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    backgroundColor: Color(0xffDF4E17);
    theme: new ThemeData(scaffoldBackgroundColor: const Color(0xffDF4E17));
    return
      Scaffold(
        key: _scaffoldKey,
        body: Container(
          // width: double.infinity,
          // height: double.infinity,
          // decoration: back(),
          child: Center(
            child: Center(
                child: Image.asset("assets/images/splash1.png",
                    fit: BoxFit.cover)),
            // child: Image.asset(
            //   'assets/images/splashlogo.png',
            //   width: 250,
            //   height: 250,
            // ),
          ),
        ),
      );
  }

  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  Future<void> navigationPage() async {
    bool isFirstTime = await getPrefrenceBool(isLogin);
    if (isFirstTime) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ));
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.dispose();
  }
}
