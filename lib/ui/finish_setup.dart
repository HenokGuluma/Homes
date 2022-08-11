import 'dart:async';
import 'dart:typed_data';
import 'package:async/async.dart';
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
import 'package:instagram_clone/ui/unlocked_listings.dart';
import 'package:instagram_clone/ui/view_listings.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:instagram_clone/ui/search_autofill.dart';

class FinishSetup extends StatefulWidget {
  // FinishSetup();
  Uint8List imageFile;
  FinishSetup({this.imageFile});

  @override
  _FinishSetupState createState() => _FinishSetupState();
}

class _FinishSetupState extends State<FinishSetup>
    with AutomaticKeepAliveClientMixin {
  var _repository = Repository();
  User _user;
  bool _isLiked = false;
  List<DocumentSnapshot> list;
  bool loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
    variables.currentUser = user;
    setState(() {
      _user = user;
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
                            image: _user != null
                                ? NetworkImage(_user.photoUrl)
                                : AssetImage('assets/no_image.png'),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: height * 0.08,
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
                                textAlign: TextAlign.center))
                        : Container(
                            width: width * 0.8,
                            child: Text(
                                _user.bio.isNotEmpty
                                    ? _user.bio
                                    : 'Add your bio by clicking on Edit Profile.',
                                style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: _user.bio.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center))
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
                  child: ProfileButtons('Log Out', width, height),
                  onTap: () async {
                    if (await confirm(
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
                    return print('pressedCancel');
                  }),
              Divider(
                color: Colors.black38,
                thickness: 0.5,
              )
            ],
          )),
    );
  }

  Widget ProfileButtons(String text, var width, var height) {
    return Container(
        width: width,
        height: height * 0.08,
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(15.0),
          // border: Border.all(color: Colors.black)
        ),
        child: Column(
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
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400)),
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
