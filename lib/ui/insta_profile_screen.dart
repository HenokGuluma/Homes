import 'dart:async';
import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/ui/buy_keys.dart';
import 'package:instagram_clone/ui/comments_screen.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';

import 'package:instagram_clone/ui/edit_profile_screen.dart';
import 'package:instagram_clone/ui/liked_listings.dart';
import 'package:instagram_clone/ui/termsOfService.dart';
import 'package:instagram_clone/ui/unlocked_listings.dart';
import 'package:instagram_clone/ui/view_listings.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:instagram_clone/ui/search_autofill.dart';

class InstaProfileScreen extends StatefulWidget {
  // InstaProfileScreen();
  UserVariables variables;
  InstaProfileScreen({this.variables});

  @override
  _InstaProfileScreenState createState() => _InstaProfileScreenState();
}

class _InstaProfileScreenState extends State<InstaProfileScreen>
    with AutomaticKeepAliveClientMixin {
  var _repository = Repository();
  User _user;
  bool _isLiked = false;
  List<DocumentSnapshot> list;
  bool loading = true;
  bool logging_out = false;
  NavigatorState _navigator;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
     _navigator = Navigator.of(context);
    /*  retrieveUserDetails().then((value) {
      setState(() {
        loading = false;
      });
    }); */
  }

  String adjustNumbers(int num) {
    if (num >= 1000000) {
      String num2 = (num / 1000000).toStringAsFixed(2) + ' M';
      return num2;
    }
    if (num >= 10000) {
      String num2 = (num / 1000).toStringAsFixed(1) + ' K';
      return num2;
    } else {
      String num2 = num.toString();
      return num2;
    }
  }

  Future<void> retrieveUserDetails(UserVariables variables) async {
    auth.User currentUser = await _repository.getCurrentUser();
    User user = await _repository.retrieveUserDetails(currentUser);
    setState(() {
      _user = user;
      variables.currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    var boltTimer = Provider.of<UserVariables>(context, listen: true);
    _user = boltTimer.currentUser;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        toolbarHeight: 50,
        // elevation: 1,
        centerTitle: true,
        title: Text('Profile',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Color(0xff00ffff),
                fontSize: 20,
                fontWeight: FontWeight.w400)),
      ),
      body: RefreshIndicator(
          onRefresh: () {
            retrieveUserDetails(boltTimer);
            return Future.delayed(Duration(seconds: 2));
          },
          backgroundColor: Colors.black,
          color: Color(0xff00ffff),
          child: ListView(
            cacheExtent: 500000000,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: height * 0.05, bottom: 10.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                        image: DecorationImage(
                          image: ProgressiveImage(
                            placeholder: AssetImage('assets/no_image.png'),
                            // size: 1.87KB
                            //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                            thumbnail: AssetImage('assets/grey.png'),
                            // size: 1.29MB
                            image: boltTimer.currentUser!=null
                            ?CachedNetworkImageProvider(boltTimer.currentUser.photoUrl)
                            :_user != null
                                ? CachedNetworkImageProvider(_user.photoUrl)
                                : AssetImage('assets/grey.png'),
                            //image: NetworkImage(_user.photoUrl),
                            fit: BoxFit.cover,
                            width: 130,
                            height: 130,
                          ).image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 130,
                      height: 130,
                    ),
                  )),
              Center(
                child: Text(
                    _user != null ? _user.displayName : 'Your Name',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 25.0)),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: height * 0.03,
                    left: width * 0.03,
                    right: width * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Bio: ',
                      style: TextStyle(
                        fontFamily: 'Muli',
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _user == null
                        ? Container(
                            width: width * 0.8,
                            child: Text(
                                'Your bio will be displayed here.',
                                style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.start))
                        : Container(
                            width: width * 0.8,
                            child: Text(
                                boltTimer.currentUser.bio.isNotEmpty
                                    ? boltTimer.currentUser.bio
                                    : 'Add your bio by clicking on Edit Profile.',
                                style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: boltTimer.currentUser.bio.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.start))
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              GestureDetector(
                child: ProfileButtons('Edit Profile', width, height),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => EditProfileScreen(
                            updateState: (){
                              setState(() {});
                            },
                              variables: boltTimer,
                              currentUser: _user,
                              photoUrl: _user.photoUrl,
                              email: _user.email,
                              bio: _user.bio,
                              name: _user.displayName,
                              phone: _user.phone))));
                },
              ),
              GestureDetector(
                child: ProfileButtons('View Your Listings', width, height),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => ViewListings(
                                variables: boltTimer,
                              ))));
                },
              ),
              GestureDetector(
                child: ProfileButtons('Unlocked Listings', width, height),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => UnlockedListings(
                                variables: boltTimer,
                              ))));
                },
              ),
              GestureDetector(
                child: ProfileButtons('Liked Listings', width, height),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => LikedListings(
                                variables: boltTimer,
                              ))));
                },
              ),
              /*  GestureDetector(
            child: ProfileButtons('Buy Keys', width, height),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => BuyKeys(variables: boltTimer))));
            },
          ), */

           GestureDetector(
            child: ProfileButtons('Terms Of Service', width, height),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => TermsOfService())));
            },
          ),
              GestureDetector(
                  child: ProfileButtons('Log Out', width, height),
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: ((context) {
                          return new AlertDialog(
                            title: new Text(
                              'Logging out',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Muli',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            content: new Text(
                              'Are you sure you want to log out?',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            actions: <Widget>[
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, // Closes the dialog
                                child: new Text(
                                  'No',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              new TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                //  loggingOutDialog();
                                setState(() {
                                  logging_out = true;
                                });
                                  _repository.signOut().then((v) {
                                    boltTimer.reset();
                                    _navigator.pushReplacement(
                                        MaterialPageRoute(builder: (context) {
                                      return MyApp();
                                    }));
                                  });
                                  return print('pressedOK');
                                  // Closes the dialog
                                },
                                child: new Text(
                                  'Yes',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Muli',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          );
                        }));

                    /* if (await confirm(
                      context,
                      title: Text(
                        'Logging Out',
                        style:
                            TextStyle(fontFamily: 'Muli', color: Colors.black),
                      ),
                      content: Text(
                        'Are you sure you want to log out?',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16),
                      ),
                      textOK: Text(
                        'Yes',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16),
                      ),
                      textCancel: Text(
                        'No',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16),
                      ),
                    )) {
                      _repository.signOut().then((v) {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return MyApp();
                        }));
                      });
                      return print('pressedOK');
                    }
                    return print('pressedCancel'); */
                  }),
              Divider(
                color: Colors.black38,
                thickness: 0.5,
              ), 

              logging_out
              ?Center()
              :SizedBox(height: 30,),
              logging_out?
              Center(
                child: Column(
                                children: [
                                   JumpingDotsProgressIndicator(color: Colors.black, fontSize: 30,),
                                  
                                  SizedBox(height: 10,),
                                  Text(
                              'Logging you out...',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Muli',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 20,)
                                ],
                              ),
              )
              :Center(),

              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                    'Contact us',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 22,
                        fontFamily: 'Muli',
                        fontWeight: FontWeight.w900, 
                        decoration: TextDecoration.underline
                        ),
                  ),
                ),
                  SizedBox(height: 20,),
              Row(
                children: [
                  Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Icon(
                Icons.phone,
                size: 20,
                color: Colors.grey,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
               '0923577987',
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),

          SizedBox(width: 15,),
          Row(
            children: [
              Icon(
                Icons.email,
                size: 20,
                color: Colors.grey,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'henimagne@gmail.com',
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),

                ],
              ),
              SizedBox(height: 30,)
            ],
          )),
    );
  }

  Widget ProfileButtons(String text, var width, var height) {
    return Container(
        width: width,
        height: width*0.14,
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(15.0),
          // border: Border.all(color: Colors.black)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(
              color: Colors.black38,
              thickness: 0.5,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(text,
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Color(0xff666666),
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(
                        Icons.arrow_right_outlined,
                        color: Colors.black,
                      ))
                ]),
          ],
        ));
  }
}
