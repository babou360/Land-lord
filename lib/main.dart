import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:landlord/pages/details.dart';
import 'package:landlord/pages/home.dart';
import 'package:landlord/pages/register.dart';
import 'package:landlord/pages/splash.dart';
import 'package:landlord/pages/test.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

final FirebaseAuth auth = FirebaseAuth.instance;


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Land Lord',
      debugShowCheckedModeBanner: false,
      color: Color(0xFFFFC107),
      theme: ThemeData(
        //primarySwatch: generateMaterialColor(),
        primaryColor: Color(0xFFFFC107),
          accentColor: Color(0xFFFFC107),
          // hintColor: Color(0xFFC0F0E8),
          hintColor: Color(0xFFFFC107),
          textSelectionColor: Color(0xFFC0F0E8),
          // backgroundColor:Color(0xFF80E1D1),
          backgroundColor: Color(0xFFFFC107),
          // primaryColor: Color(0xFF80E1D1),
          fontFamily: "Montserrat",
          canvasColor: Colors.transparent),
          home: Splash(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new Home(),
        '/login': (BuildContext context) => new LoginRegister(),
        '/Details': (BuildContext context) => new Details()
      },
    );
  }
}