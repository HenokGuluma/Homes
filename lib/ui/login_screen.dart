import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/setup_profile.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _repository = Repository();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: new Color(0xff1a1a1a),
          brightness: Brightness.dark,
          toolbarHeight: 0,
          centerTitle: true,
          elevation: 1.0,
        ),
        body: ListView(children: <Widget>[
          SizedBox(
            height: height * 0.1,
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: Container(
                  height: height * 0.15,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/homes_icon.png'))),
                ),
              )),
          SizedBox(
            height: height * 0.05,
          ),
          Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
              child: Center(
                  child: Text(
                "Welcome to",
                style: TextStyle(
                    fontFamily: 'Muli', color: Colors.white, fontSize: 30.0),
              ))),
          Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Center(
                  child: Container(
                height: 60,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/homes_black.png'))),
              ))),
          Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: Center(
                  child: Text(
                "Find your homes easily",
                style: TextStyle(
                    fontFamily: 'Muli', color: Colors.white, fontSize: 20.0),
              ))),
          SizedBox(
            height: height * 0.15,
          ),
          Center(
            child: GestureDetector(
              child: Container(
                width: width * 0.7,
                height: height * 0.08,
                decoration: BoxDecoration(
                  color: Color(0xff00ffff),
                  border: Border.all(color: Color(0xff00ffff)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/google_icon.jpg'),
                              )),
                          width: height * 0.06,
                          height: height * 0.06,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text('Sign in with Google',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black,
                              fontSize: 18.0)),
                    )
                  ],
                ),
              ),
              onTap: () {
                _repository.signIn().then((user) {
                  if (user != null) {
                    authenticateUser(user);
                  } else {
                    print("Error");
                  }
                });
              },
            ),
          ),
        ]));
  }

  void authenticateUser(auth.User user) {
    print("Inside Login Screen -> authenticateUser");
    _repository.authenticateUser(user).then((value) {
      if (value) {
        print("VALUE : $value");
        print("INSIDE IF");
        _repository.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return SetupProfile(
              userId: user.uid,
              emailAddress: user.email,
              name: user.displayName,
            );
          }));
        });
      } else {
        print("INSIDE ELSE");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return InstaHomeScreen();
        }));
      }
    });
  }
}
