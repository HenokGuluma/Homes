import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/add_listing.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/insta_upload_photo_screen.dart';
import 'package:instagram_clone/ui/listing_details.dart';
import 'package:instagram_clone/ui/modify_listing.dart';
import 'package:instagram_clone/ui/view_listings.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class InstaAddScreen extends StatefulWidget {
  @override
  _InstaAddScreenState createState() => _InstaAddScreenState();
}

class _InstaAddScreenState extends State<InstaAddScreen>
    with TickerProviderStateMixin {
  File imageFile;
  final picker = ImagePicker();
  List<String> properties = [
    'assets/listing_1.jpg',
    'assets/listing_2.jpg',
    'assets/listing_3.jpg',
    'assets/listing_4.jpg',
    'assets/listing_5.jpg'
  ];
  int picIndex = 0;
  TabController _tabController;
  var _repository = Repository();
  User currentUser;
  bool loading = true;
  List<DocumentSnapshot> ownListings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _repository.getCurrentUser().then((user) {
      _repository.getUserWithId(user.uid).then((users) {
        setState(() {
          currentUser = users;
        });
      });
      _repository.getOwnListings(user.uid).then((listings) {
        setState(() {
          ownListings = listings;
          loading = false;
        });
      });
    });
    //fetchFeed();
    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var variables = Provider.of<UserVariables>(context, listen: false);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: Colors.black,
            // toolbarHeight: height * 0.12,
            title: TabBar(
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
                          "Add Listing",
                          style: TextStyle(
                              fontFamily: 'Muli',
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
                          "Modify Listing",
                          style: TextStyle(
                              fontFamily: 'Muli',
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                        //text:('Trending Today'),
                      )),
                ])),
        body: Container(
            height: height * 0.9,
            padding: EdgeInsets.only(top: 0),
            child: TabBarView(
              children: [AddListing(), ModifyWidget(width, height, variables)],
              controller: _tabController,
            )));
  }

  Widget ModifyWidget(var width, var height, var variables) {
    return Container(
      width: width,
      height: height,
      child: !loading
          ? ownListings.length == 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/home_fill.svg",
                        width: 40, height: 40, color: Colors.black),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'No listings yet.',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Add your listings by clicking the Add Listing tab.',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                )
              : Column(children: [
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        'Pick the listing you want to modify',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Container(
                    height: height * 0.7,
                    child: GridView.builder(
                        itemCount: ownListings.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 0.9),
                        cacheExtent: 5000000,

                        // ignore: missing_return
                        itemBuilder: ((context, index) {
                          return listingWidget(
                            list: ownListings,
                            index: index,
                            width: width,
                            height: height,
                            variables: variables,
                          );
                        })),
                  )
                ])
          : Center(
              child: JumpingDotsProgressIndicator(
              fontSize: 50.0,
              color: Colors.black,
            )),
    );
  }

  Widget listingWidget(
      {var height,
      var width,
      int index,
      List<DocumentSnapshot> list,
      UserVariables variables}) {
    return GestureDetector(
      child: Container(
        width: width * 0.45,
        height: width * 0.6,
        child: Column(
          children: [
            Container(
              width: width * 0.45,
              height: width * 0.35,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: variables.cachedImages[list[index].data()['images']
                                  [0]] !=
                              null
                          ? variables
                              .cachedImages[list[index].data()['images'][0]]
                              .image
                          : list[index].data()['images'][0] == null
                              ? AssetImage('assets/grey.png')
                              : CachedNetworkImageProvider(
                                  list[index].data()['images'][0]),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(20)),
            ),
            description(width, height, list[index])
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => ModifyListing(
                      details: list[index],
                      variables: variables,
                    ))));
      },
    );
  }

  Widget description(width, height, DocumentSnapshot item) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 5),
      width: width * 0.5,
      child: Container(
          width: width * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.data()['listingType'] +
                        ' - ' +
                        item.data()['area'].toString() +
                        ' sq.m',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_pin,
                    color: Colors.black,
                    size: 15,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: width * 0.4,
                    child: Text(
                      item.data()['commonLocation'],
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Color(0xff444444),
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Icon(
                Icons.more_horiz,
                size: 16,
                color: Colors.black,
              )
            ],
          )),
    );
  }
}
