import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/admin/AndroidStudioProjects/krima_practical/lib/ui/view/profile_screen.dart';
import 'ui/view/otp_screen.dart';
import 'package:krima_practical/ui/view/login_screen.dart';
import 'package:krima_practical/ui/view/welcome_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/otpscreen': (BuildContext context) => OtpScreen(),
        '/profilescreen': (BuildContext context) => ProfileScreen(),
        '/welcomescreen': (BuildContext context) => WelcomeScreen(),



      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:LoginScreen(),
    );
  }
}


