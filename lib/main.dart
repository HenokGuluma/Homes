import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/login_screen.dart';
import 'package:instagram_clone/ui/setup_profile.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  var _repository = Repository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        color: Colors.white,
        title: 'Homes',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.white,
            primaryIconTheme: IconThemeData(color: Colors.white),
            primaryTextTheme: TextTheme(
               ),
            textTheme: TextTheme()),
        home: FutureBuilder(
          future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<auth.User> snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data.phoneNumber);
              if (snapshot.data.photoURL==null) {
                return SetupProfile(
                    userId: snapshot.data.uid,
                    emailAddress: snapshot.data.email,
                    name: snapshot.data.displayName);
              } else {
                return InstaHomeScreen();
              }
            } else {
              return LoginScreen();
              // return InstaHomeScreen();
            }
          },
        ));
  }
}
