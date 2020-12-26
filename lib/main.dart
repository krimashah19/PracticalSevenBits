import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:krima_practical/ui/profile_screen.dart';
import 'homepage.dart';
import 'ui/login_screen.dart';
import 'ui/otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Authentication',
      routes: <String, WidgetBuilder>{
        '/otpscreen': (BuildContext context) => OtpScreen(),
        '/profilescreen': (BuildContext context) => ProfileScreen(),

      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:LoginScreen(),
    );
  }
}


