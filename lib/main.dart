import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/login_screen.dart';
import 'package:instagram_clone/ui/setup_profile.dart';
import 'package:instagram_clone/ui/upgrade_app.dart';
import 'package:progress_indicators/progress_indicators.dart';
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

  Widget LoadingWidget(){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
     color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/homes.svg', color: Colors.black, width: 80, height: 80,),
          // Text('Loading...', style: TextStyle( fontFamily: 'Muli', color: Color(0xff00ffff), fontSize: 20, fontWeight: FontWeight.w400)),
          JumpingDotsProgressIndicator(color: Colors.black, fontSize: 50, dotSpacing: 0.0,),
        ],
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
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
              print( ' is the phone number initially');
              if (snapshot.data.phoneNumber==null) {
                return SetupProfile(
                    userId: snapshot.data.uid,
                    emailAddress: snapshot.data.email,
                    name: snapshot.data.displayName);
              } else {
                return FutureBuilder(
          future: _repository.appVersion(),
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data > 1) {
                return UpgradeApp();
              } else {
                return InstaHomeScreen();
              }
            } else {
              return LoadingWidget();
              // return InstaHomeScreen();
            }
          },
        );
                // InstaHomeScreen();
              }
            } else {
              return LoginScreen();
              // return InstaHomeScreen();
            }
          },
        ));
  }
}
