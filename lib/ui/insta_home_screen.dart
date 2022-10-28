import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
//import 'package:fluttericon/fontelico_icons.dart';
//import 'package:fluttericon/brandico_icons.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/ui/add_text.dart';
import 'package:instagram_clone/ui/insta_activity_screens.dart';
import 'package:instagram_clone/ui/insta_add_screen.dart';
import 'package:instagram_clone/ui/insta_feed_screen.dart';
import 'package:instagram_clone/ui/insta_profile_screen.dart';
import 'package:instagram_clone/ui/insta_search_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/ui/image_cropper.dart';
import 'package:provider/provider.dart';

class InstaHomeScreen extends StatefulWidget {
  @override
  _InstaHomeScreenState createState() => _InstaHomeScreenState();
}

PageController pageController;

class _InstaHomeScreenState extends State<InstaHomeScreen> {
  int _page = 0;

  void navigationTapped(int page) {
    if (page == 5) {
      Navigator.push(context,
          CupertinoPageRoute(builder: ((context) => InstaAddScreen())));
    } else {
      pageController.jumpToPage(page);
    }
    //Animating Page
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //return homeWidget();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserVariables>(
            create: (context) => UserVariables())
      ],
      child: homeWidget(),
    );
  }

  Widget homeWidget() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: new PageView(
        children: [
          new Container(color: Colors.white, child: InstaFeedScreen()),
          new Container(color: Colors.white, child: InstaSearchScreen()),
          new Container(color: Colors.white, child: InstaAddScreen()),
          new Container(color: Colors.white, child: ActivityScreen()),
          new Container(color: Colors.white, child: InstaProfileScreen()),
        ],
        controller: pageController,
        physics: new NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: new CupertinoTabBar(
        border: Border(top: BorderSide(color: Colors.black, width: 0.5)),
        iconSize: 30,
        currentIndex: _page,
        backgroundColor: Colors.white,
        activeColor: Colors.black,
        inactiveColor: Color(0xff00ffff),
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: _page == 0
                ? SvgPicture.asset("assets/home_fill.svg",
                    width: 20, height: 20, color: Colors.black)
                : SvgPicture.asset("assets/home.svg",
                    width: 20, height: 20, color: Colors.black),
            title: Text(
              'Home',
              style: TextStyle(
                  fontFamily: 'Muli',
                  color: _page == 0 ? Colors.black : Colors.grey,
                  fontWeight: _page == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11),
            ),
            //activeIcon: SvgPicture.asset("assets/home.svg", width: 20, height: 20, color: Colors.black),
          ),
          new BottomNavigationBarItem(
              icon: _page == 1
                  ? SvgPicture.asset("assets/search_thick.svg",
                      width: 22, height: 22, color: Colors.black)
                  : SvgPicture.asset("assets/search.svg",
                      width: 20, height: 20, color: Colors.black),
              title: Text(
                'Search',
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: _page == 1 ? Colors.black : Colors.grey,
                    fontWeight:
                        _page == 1 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11),
              ),
              backgroundColor: Colors.white),
          new BottomNavigationBarItem(
              icon: _page == 2
                  ? SvgPicture.asset("assets/add_fill.svg",
                      width: 26, height: 26, color: Colors.black)
                  : SvgPicture.asset("assets/add.svg",
                      width: 22, height: 22, color: Colors.black),
              title: new Container(height: 0.0),
              backgroundColor: Colors.white),
          new BottomNavigationBarItem(
              icon: _page == 3
                  ? /* Icon(
                      Icons.email,
                      color: Color(0xff00ffff),
                    ) */
                  SvgPicture.asset("assets/email_fill.svg",
                      width: 24, height: 24, color: Colors.black)
                  : /*  Icon(
                      Icons.email_outlined,
                      color: Colors.black,
                    ) */
                  SvgPicture.asset("assets/email.svg",
                      width: 23, height: 23, color: Colors.black),
              title: Text(
                'Message',
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: _page == 3 ? Colors.black : Colors.grey,
                    fontWeight:
                        _page == 3 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11),
              ),
              backgroundColor: Colors.white),
          new BottomNavigationBarItem(
              icon: _page == 4
                  ? SvgPicture.asset("assets/profile_fill.svg",
                      width: 18, height: 18, color: Colors.black)
                  : SvgPicture.asset("assets/profile.svg",
                      width: 18, height: 18, color: Colors.black),
              title: Text(
                'Profile',
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: _page == 4 ? Colors.black : Colors.grey,
                    fontWeight:
                        _page == 4 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11),
              ),
              backgroundColor: Colors.white),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}

class UserVariables extends ChangeNotifier {
  int keys = 0;
  User currentUser = User();
  List<String> unlockedListings = [];
  Map<String, Image> cachedImages = {};
  List<String> phoneList = [];

  void addkeys(int amount) {
    keys += amount;
  }

  void removekeys(int amount) {
    keys -= amount;
  }

   void updatePhones (List<String> phones){
    phoneList = phones;
  }

  void setCurrentUser(User _user) {
    currentUser = _user;
  }

  void unlockListing(String listing) {
    unlockedListings.add(listing);
  }

  void setImages(Map<String, Image> images) {
    cachedImages = images;
  }


  void reset() {
    keys = 0;
    User currentUser = User();
    List<String> unlockedListings = [];
  }
}
