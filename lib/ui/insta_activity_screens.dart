import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/models/activity_model.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user_data.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/ui/comments_screen.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/listing_details.dart';
import 'package:instagram_clone/ui/listing_details_temp.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  ActivityScreen({this.currentUserId});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  User _currentUser = User();
  bool loading = true;
  Map<String, bool> followStatus = Map();
  TabController _tabController;
  List<DocumentSnapshot> notificationItems = [];
  List<String> names = [
    'Daniel',
    'Solomon',
    'Abraham',
    'Mikias',
    'Mahlet',
    'Birhanu',
    'Zelalem'
  ];

  @override
  bool get wantKeepAlive => true;

  List<Activity> _activities = [];
  var _repository = Repository();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getNotifications();
  }

  getNotifications() {
    _repository.getCurrentUser().then((user) {
      _repository.getNotifications(user.uid).then((notifications) {
        setState(() {
          notificationItems = notifications;
          loading = false;
        });
      });
    });
  }

  void showFloatingFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 0,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Colors.black, Colors.black],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: Text(
        'This item does not exist any more.',
        style: TextStyle(fontFamily: 'Muli', color: Color(0xff00ffff)),
      )),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    var variables = Provider.of<UserVariables>(context, listen: false);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: height * 0.9,
          child: Column(
            children: [
              Container(
                height: height * 0.12,
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.only(top: height * 0.05),
                    child: Center(
                      child: Text(
                        "Messages",
                        style: TextStyle(
                            fontFamily: 'Muli',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff00ffff)),
                      ),
                    ) /* TabBar(
                        controller: _tabController,
                        indicatorColor: Color(0xff00ffff),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Color(0xff00ffff),
                        unselectedLabelColor: Color(0xff009999),
                        tabs: <Widget>[
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Tab(
                                //iconMargin: EdgeInsets.fromLTRB(200, 0, 0, 0),
                                child: Text(
                                  "Notifications",
                                  style: TextStyle( fontFamily: 'Muli', 
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                                //text:('Trending Today'),
                              )),
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Tab(
                                //iconMargin: EdgeInsets.fromLTRB(200, 0, 0, 0),
                                child: Text(
                                  "Messages",
                                  style: TextStyle( fontFamily: 'Muli', 
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                                //text:('Trending Today'),
                              )),
                        ]) */
                    ),
              ),
              Container(
                height: height * 0.75,
                child: notifications(
                    'Messages',
                    SvgPicture.asset("assets/email_fill.svg",
                        width: 40, height: 40, color: Colors.black),
                    width,
                    height,
                    true,
                    variables), /* TabBarView(
                  children: [
                    notifications(
                        'notifications',
                        Icon(
                          Icons.notifications_off,
                          size: 40,
                          color: Colors.black,
                        ),
                        width,
                        height,
                        true,
                        variables),
                    notifications(
                        'messages',
                        SvgPicture.asset("assets/email_fill.svg",
                            width: 40, height: 40, color: Colors.black),
                        width,
                        height,
                        false,
                        variables)
                  ],
                  controller: _tabController,
                ), */
              )
            ],
          ),
        ));
  }

  Widget notificationItem(
      DocumentSnapshot item, var width, var height, var variables) {
    return GestureDetector(
        onTap: () async {
          String listingReference = item.data()['reference'];
          DocumentSnapshot listingItem =
              await _repository.getListingWithId(listingReference);
          if (listingItem.data() != null) {
          
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => ListingDetailsTemp(
                          notUnlock: false,
                          index: 0,
                          item: listingItem,
                          images: listingItem.data()['images'],
                          like: false,
                          variables: variables,
                          approved: listingItem.data()['approved'],
                          declined: !listingItem.data()['approved'],
                        ))));
          } 
          else  if(item.data()['from'] == 'Homes'){
              print('From Homes');
            }
          else {
            showFloatingFlushbar(context);
          }
        },
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 5,),
                SvgPicture.asset('assets/homes.svg', color: Colors.black, width: 40, height: 40,),
                SizedBox(width: 5,),
                Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: Container(
                  padding: EdgeInsets.only(bottom: 10, top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: width * 0.7,
                  child: Center(
                    child: Text(
                      item.data()['message'],
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Color(0xff555555),
                          fontSize: 16,
                          fontWeight: FontWeight.w900),
                    ),
                  )),
            ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                    timeago.format(DateTime.fromMillisecondsSinceEpoch(
                        item.data()['time'])),
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ),
            ),
            Divider(
              color: Color(0xff00ffff),
              thickness: 0.5,
            )
          ],
        ));
  }

  Widget notifications(String text, var icon, var width, var height,
      var visible, var variables) {
    return Container(
        child: visible
            ? loading
                ? Center(
                    child: JumpingDotsProgressIndicator(
                      fontSize: 50.0,
                      color: Colors.black,
                    ),
                  )
                : notificationItems.length == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'No ' + text + ' yet.',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'We will let you know when you have one.',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              getNotifications();
                            },
                            child: Container(
                              width: width * 0.35,
                              height: height * 0.07,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Refresh',
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff00ffff),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: height * 0.75,
                        child: RefreshIndicator(
                            onRefresh: () {
                              getNotifications();
                              return Future.delayed(Duration(seconds: 2));
                            },
                            backgroundColor: Colors.black,
                            color: Color(0xff00ffff),
                            child: Center(
                              child: Container(
                                width: width * 0.95,
                                height: height * 0.75,
                                child: ListView.builder(
                                  cacheExtent: 50000000,
                                  itemCount: notificationItems.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return notificationItem(
                                        notificationItems[index],
                                        width,
                                        height,
                                        variables);
                                    //return CircularProgressIndicator();
                                  },
                                ),
                              ),
                            )))
            : Center());
  }
}
