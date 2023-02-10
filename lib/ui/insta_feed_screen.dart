import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_svg/flutter_svg.dart';
//import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:flushbar/flushbar.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/unlock_details.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';
//import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/ui/listing_details.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class InstaFeedScreen extends StatefulWidget {
  @override
  _InstaFeedScreenState createState() => _InstaFeedScreenState();
}

class _InstaFeedScreenState extends State<InstaFeedScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var _repository = Repository();
  User currentUser, user, followingUser;
  ScrollController _scrollController = ScrollController();
  bool showTabBar = true;
  TabController _tabController;
  var startAfter = null;
  bool loading = true;
  int availableKeys = 0;
  bool trial = false;
  bool uploadTrial = false;
  DocumentSnapshot lastListing = null;
  bool _gettingmorefeed = false;
  bool _morefeedavailable = true;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PagingController _pagingController = PagingController(firstPageKey: 0);

  List<String> properties = [
    'assets/listing_1.jpg',
    'assets/listing_2.jpg',
    'assets/listing_3.jpg',
    'assets/listing_4.jpg',
    'assets/listing_5.jpg'
  ];

  List<DocumentSnapshot> listings = [];
  List<String> likedListings = [];
  List<String> unlockedStrings = [];

  List<bool> likes = [];
  Map<String, bool> likeMap = {};

  Map<String, int> counters = {};
  Map<String, Image> cachedImages = {};
  List<String> phoneList = [];

  @override
  bool get wantKeepAlive => true;

  void showFloatingFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 8,
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
        'You have already used your daily bolt',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black),
      )),
    )..show(context);
  }

  Future<void> getPhones (){
    _repository.getAllPhones().then((phoneNumbers) {
      List<String> phones = [];
      for(int i=0; i<phoneNumbers.length; i++){
        String phone = phoneNumbers[i].id;
        phones.add(phone);
      }
      setState(() {
              phoneList = phones;
              // loadingPhones = false;
            });
    });
    return null;
  }




  void getListings(int page) async {
    if (page == 0) {
      try {
        final newItems = await _repository.getListings();
        final nextPageKey = page + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
        setState(() {
          startAfter = newItems[newItems.length - 1].data()['time'];
        });
      } catch (error) {
        _pagingController.error = 'No more listings at the moment';
      }
    } else {
      try {
        final newItems = await _repository.getMoreListings(startAfter);
        final nextPageKey = page + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
        setState(() {
          startAfter = newItems[newItems.length - 1].data()['time'];
        });
      } catch (error) {
        _pagingController.error = 'No more listings at the moment';
      }
    }
  }

  Future cacheImage(BuildContext context, String urlImage) {
    Image image = Image(
      image: CachedNetworkImageProvider(urlImage),
      fit: BoxFit.cover,
    );
    cachedImages[urlImage] = image;
    precacheImage(image.image, context);

    return null;
  }


  Future<List<DocumentSnapshot>> getlistingItems() async {
    List<DocumentSnapshot> onlineListings = await _repository.getListings();
    setState(() {
      listings = onlineListings;
      loading = false;
      lastListing = onlineListings[onlineListings.length -1];
    });
    await Future.forEach(onlineListings, (listing) async {
      List<dynamic> imageList = listing.data()['images'];
      for (int i = 0; i < imageList.length; i++) {
        cacheImage(context, imageList[i]);
      }
      return true;
    });
    return onlineListings;
  }

    getMorelistingItems() async {
     if (_morefeedavailable ==false){
      return;
    }
    if (_gettingmorefeed == true){
      return;
    }
    setState(() {
      _gettingmorefeed = true;
    });
    List<DocumentSnapshot> onlineListings = await _repository.getMoreListings([lastListing['time']]);
    List<dynamic> newListings = listings;
    print(lastListing['commonLocation']);
    print(lastListing['likeCount']);
    if(onlineListings.length<1){
      setState(() {
        _morefeedavailable = false;
      });
      print('muamuwawawa');
    }
    else{
       for(int i = 0; i<onlineListings.length; i++){
      newListings.add(onlineListings[i]);
    }
       setState(() {
      listings = newListings;
      loading = false;
      lastListing = onlineListings[onlineListings.length -1];
      _gettingmorefeed = false;
    });
    await Future.forEach(onlineListings, (listing) async {
      List<dynamic> imageList = listing.data()['images'];
      for (int i = 0; i < imageList.length; i++) {
        cacheImage(context, imageList[i]);
      }
      return true;
    });

    

    addCounters(onlineListings);
    }
   
    return;
  }

  Future<void> getCurrentUser() async {
    _firestore.collection('trial').doc('trialPeriod').get().then((trialValue) {
      setState(() {
              trial = trialValue.data()['trialActive'];
              uploadTrial = trialValue.data()['addTrialActive'];
            });
    });
    auth.User currentUser = await _repository.getCurrentUser();
    User user = await _repository.fetchUserDetailsById(currentUser.uid);
    setState(() {
      this.currentUser = user;
    });
  }

  getUnlockedListings(userId) async {
    var unlockedListings = await _repository.getUnlockedListings(userId);
    for (int i = 0; i < unlockedListings.length; i++) {
      unlockedStrings.add(unlockedListings[i].id);
    }
  }

  addCounters(List<DocumentSnapshot> list) {
    for (int index = 0; index < list.length; index++) {
      counters.putIfAbsent(list[index].id, () => 0);
    }
  }

  getLikedListings(userId) async {
    var likes = await _repository.getLikedListings(userId);
    for (int i = 0; i < likes.length; i++) {
      setState(() {
        likedListings.add(likes[i].id);
        likeMap[likes[i].id] = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((value) {
      getLikedListings(currentUser.uid);
      getPhones();
      getlistingItems().then((list) {
        addCounters(list);
        print('the list length is ' + list.length.toString());
      });
      getUnlockedListings(currentUser.uid);
    });
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height*0.25;
      if (maxScroll - currentScroll < delta){
        getMorelistingItems();
        //fetchMorePosts();
      }
    });

    //fetchFeed();
    // _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var variables = Provider.of<UserVariables>(context, listen: false);
    variables.setCurrentUser(currentUser);
    variables.unlockedListings = unlockedStrings;
    variables.setImages(cachedImages);
    variables.updatePhones(phoneList);
    variables.setTrial(trial);
    variables.setUploadTrial(uploadTrial);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          toolbarHeight: height * 0.1,
          centerTitle: false,
          title: Column(children: [
            Container(
              height: height * 0.04,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/homes_black.png'))),
            ),
            SizedBox(height: 2),
            Center(
                child: Text('Find your dream place easily',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff00ffff),
                        fontSize: 14,
                        fontWeight: FontWeight.w400)))
          ]),
          /* bottom: TabBar(
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
                          "Popular Listings",
                          style: TextStyle( fontFamily: 'Muli', 
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        //text:('Trending Today'),
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Tab(
                        //iconMargin: EdgeInsets.fromLTRB(200, 0, 0, 0),
                        child: Text(
                          "Latest Listings",
                          style: TextStyle( fontFamily: 'Muli', 
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        //text:('Trending Today'),
                      )),
                ]) */
        ),
        body: RefreshIndicator(
            onRefresh: () {
              // getlistingItems();
              return Future.delayed(Duration(seconds: 2));
            },
            backgroundColor: Colors.black,
            color: Color(0xff00ffff),
            child: Container(
                height: height * 0.91,
                padding: EdgeInsets.only(top: 0),
                child: feedWidget(height, width, variables)

                /* TabBarView(
              children: [feedWidget(height), feedWidget(height)],
              controller: _tabController,
            ) */
                )));
  }

  Widget feedWidget(var height, var width, var variables) {
    return Center(
      child: listings.length > 0
          // ? postFeedWidget()
          ? listingFeedWidget(variables)
          : !loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'There are no listings available at the time.',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          loading = true;
                        });
                        getlistingItems();
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
              : JumpingDotsProgressIndicator(
                  fontSize: 50.0,
                  color: Colors.black,
                ),
    );
  }

  likeListing(DocumentSnapshot item) {
    _repository.likeListing(currentUser.uid, item);
  }

  unlikeListing(DocumentSnapshot item) {
    _repository.unlikeListing(currentUser.uid, item);
  }

  Widget ListingTypes(String text, Color color, var height) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(10)),
      height: height*0.05,
      width: 100,
      child: Center(
          child: Text(
        text,
        style: TextStyle(fontFamily: 'Muli', color: color),
      )),
    );
  }

  Future<void> refreshPage() async {}

  Widget postFeedWidget() {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
        height: height * 0.8,
        width: width,
        child: ListView.builder(
            //shrinkWrap: true,
            controller: _scrollController,
            itemCount: properties.length * 3,
            itemBuilder: ((context, index) => listItem(
                list: properties,
                index: index,
                width: width,
                height: height))));
  }

  Widget listingFeedWidget(var variables) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
        height: height * 0.82,
        width: width,
        child: ListView.builder(
            //shrinkWrap: true,
            cacheExtent: 500000000,
            controller: _scrollController,
            itemCount: listings.length,
            itemBuilder: ((context, index) => listingItem(
                list: listings,
                index: index,
                width: width,
                height: height,
                variables: variables))));
  }

  Widget listItem(
      {List<String> list,
      int index,
      var width,
      var height,
      UserVariables variables}) {
    // var _current = 0;
    return Padding(
        padding: EdgeInsets.only(top: height * 0.03, bottom: height * 0.03),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => ListingDetails(
                            notUnlock: false,
                            index: index % 5,
                            imageFile: list[index % 5],
                            like: likes[index % 5],
                            variables: variables,
                          ))));
            },
            onDoubleTap: () {
              setState(() {
                if (likes[index % 5] == false) {
                  likes.removeAt(index % 5);
                  likes.insert(index % 5, true);
                } else {
                  likes.removeAt(index % 5);
                  likes.insert(index % 5, false);
                }
              });
            },
            child: Container(
                child: Stack(alignment: Alignment.bottomCenter, children: [
              CarouselSlider(
                options: CarouselOptions(
                    initialPage: index % 5,
                    height: width * 0.7,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    onPageChanged: (index1, reason) {
                      setState(() {
                        counters['index'] = (index1 - index) % 5;
                      });
                    }),
                items: list
                    .map((item) => Stack(children: [
                          Container(
                            height: width * 0.7,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(item), fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(width * 0.05),
                            ),
                          ),
                          Container(
                            height: width * 0.7,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.05),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black54,
                                    Colors.black87
                                  ],
                                  stops: [
                                    0.8,
                                    0.9,
                                    0.95
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                            ),
                          ),
                        ]))
                    .toList(),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: list.map((url) {
                        int index1 = list.indexOf(url);
                        return Padding(
                          padding: EdgeInsets.only(left: 2, right: 2),
                          child: Container(
                            width: index1 == counters[index] ? 8.0 : 6.0,
                            height: index1 == counters[index] ? 8.0 : 6.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index1 == counters[index]
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),

                      /* children: [
                          dots(0, _current),
                          dots(1, _current),
                          dots(2, _current),
                          dots(3, _current),
                          dots(4, _current),
                        ] */
                    ),
                  )),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  child: IconButton(
                    icon: !likes[index % 5]
                        ? SvgPicture.asset("assets/heart.svg",
                            width: 20, height: 20, color: Colors.white)
                        : SvgPicture.asset("assets/heart_fill.svg",
                            width: 20, height: 20, color: Colors.pinkAccent),
                    onPressed: () {
                      setState(() {
                        if (likes[index % 5] == false) {
                          likes.removeAt(index % 5);
                          likes.insert(index % 5, true);
                        } else {
                          likes.removeAt(index % 5);
                          likes.insert(index % 5, false);
                        }
                      });
                    },
                  ),
                ),
              )
            ])),
          )),
          SizedBox(
            height: 10,
          ),
          description(width, height),
        ]));
  }

  Widget listingItem(
      {List<DocumentSnapshot> list,
      int index,
      var width,
      var height,
      UserVariables variables}) {
    // var _current = 0;
    List<dynamic> imageList = list[index].data()['images'];
    return Padding(
        padding: EdgeInsets.only(top: height * 0.03, bottom: height * 0.03),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => UnlockDetails(
                          modify: false,
                          notUnlock: false,
                          index: 0,
                          item: list[index],
                          images: imageList,
                          variables: variables))));
            },
            onDoubleTap: () {
              setState(() {
                if (!likeMap.containsKey(list[index].id)) {
                  likeListing(list[index]);
                  likeMap[list[index].id] = true;
                  /* likes.removeAt(index);
                  likes.insert(index, true); */
                } else {
                  unlikeListing(list[index]);
                  likeMap.remove(list[index].id);
                  /* likes.removeAt(index);
                  likes.insert(index, false); */
                }
              });
            },
            child: Container(
                child: Stack(alignment: Alignment.bottomCenter, children: [
              CarouselSlider(
                options: CarouselOptions(
                    initialPage: 0,
                    height: width * 0.7,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    onPageChanged: (index1, reason) {
                      setState(() {
                        counters[list[index].id] = (index1);
                      });
                    }),
                items: imageList
                    .map<Widget>((item) => Stack(children: [
                          Container(
                            height: width * 0.7,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: cachedImages[item] != null
                                      ? cachedImages[item].image
                                      : AssetImage('assets/grey.png'),
                                  /* AdvancedNetworkImage(item,
                                        useDiskCache: true), */
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(width * 0.05),
                              /* border: Border.all(
                                    color: Colors.black, width: 0.5) */
                            ),
                          ),
                          Container(
                            height: width * 0.7,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.05),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black54,
                                    Colors.black87
                                  ],
                                  stops: [
                                    0.8,
                                    0.9,
                                    0.95
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                            ),
                          ),
                          
                        ]))
                    .toList(),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: imageList.map((url) {
                        int index1 = imageList.indexOf(url);
                        return Padding(
                          padding: EdgeInsets.only(left: 2, right: 2),
                          child: Container(
                            width:
                                index1 == counters[list[index].id] ? 8.0 : 6.0,
                            height:
                                index1 == counters[list[index].id] ? 8.0 : 6.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index1 == counters[list[index].id]
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),

                      /* children: [
                          dots(0, _current),
                          dots(1, _current),
                          dots(2, _current),
                          dots(3, _current),
                          dots(4, _current),
                        ] */
                    ),
                  )),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, top: 10),
                  child: IconButton(
                    icon: !likeMap.containsKey(list[index].id)
                        ? SvgPicture.asset("assets/heart.svg",
                            width: 20, height: 20, color: Colors.white)
                        : SvgPicture.asset("assets/heart_fill.svg",
                            width: 20, height: 20, color: Colors.pinkAccent),
                    onPressed: () {
                      setState(() {
                        if (!likeMap.containsKey(list[index].id)) {
                          likeListing(list[index]);
                          likeMap[list[index].id] = true;
                          /* likes.removeAt(index);
                  likes.insert(index, true); */
                        } else {
                          unlikeListing(list[index]);
                          likeMap.remove(list[index].id);
                          /* likes.removeAt(index);
                  likes.insert(index, false); */
                        }
                      });
                    },
                  ),
                ),
              )
              ,
              
            ])),
          )),
          SizedBox(
            height: 10,
          ),
          listingDescription(width, height, list[index]),
        ]));
  }

  Widget dots(int index, int currentIndex) {
    return Padding(
      padding: EdgeInsets.only(left: 2, right: 2),
      child: Icon(
        Icons.circle,
        color: index == currentIndex ? Colors.white : Colors.grey,
        size: index == currentIndex ? 11 : 8,
      ),
    );
  }

  Widget listingDescription(var width, var height, DocumentSnapshot item) {
    return Container(
      padding: EdgeInsets.only(left: 20),
      width: width ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            item.data()['test']
            ?Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: Color(0xff000000),
                ),SelectableText(
                  ' Test Listing',
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Color(0xff23aa21),
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 18),
                )
                ])
            :Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 12,
                  color: Colors.pink,
                ),
                SelectableText(
                  ' Available',
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Color(0xff444444),
                      fontSize: 12),
                )
              ],
            ),
            item.data()['userID'] == currentUser.uid
                ? Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      'Your Listing',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 16),
                    ))
                : Center()
          ]),
          SizedBox(
            height: 5,
          ),
          Container(
              width: width * 0.75,
              child: item.data()['listingType'] == 'Other'
                  ? SelectableText(
                      item.data()['listingDescription'] +
                          ' - ' +
                          item.data()['area'] +
                          ' sq.m',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Color(0xff444444),
                          fontSize: width*0.045,
                          fontWeight: FontWeight.w900),
                    )
                  : item.data()['floor'] != null &&
                          item.data()['floor'] != 'N/A'
                      ? SelectableText(
                          item.data()['listingType'] +
                              ' - ' +
                              item.data()['area'] +
                              ' sq.m' +
                              ', ' +
                              item.data()['floor'],
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Color(0xff444444),
                              fontSize: width*0.045,
                              fontWeight: FontWeight.w900),
                        )
                      : SelectableText(
                          item.data()['listingType'] +
                              ' - ' +
                              item.data()['area'] +
                              ' sq.m',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Color(0xff444444),
                              fontSize: width*0.045,
                              fontWeight: FontWeight.w900),
                        )),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Icon(
                Icons.location_pin,
                color: Colors.black,
                size: 17,
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                width: width * 0.85,
                child: Text(
                  item.data()['commonLocation'],
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Color(0xff444444),
                      fontSize: width*0.04,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          item.data()['additionalNotes'].toString().isNotEmpty
              ? Container(
                padding: EdgeInsets.only(bottom: 5),
                  width: width * 0.85,
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                         TextSpan(
                    text: 'Description: ',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: width*0.04,
                        fontWeight: FontWeight.w900),
                  ),
                   TextSpan(
                    text: item.data()['additionalNotes'],
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: width*0.04,
                        fontWeight: FontWeight.w400),
                  ),
                      ]
                    ),
                  )
                )
              : Center(),
          item.data()['additionalNotes'].toString().isNotEmpty
              ? SizedBox(
                  height: 5,
                )
              : Center(),
          item.data()['forRent'] == 'For Sale'
              ? Column(children: [
                  Container(
                      height: width*0.1,
                      width: width * 0.25,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black)),
                      child: Center(
                          child: SelectableText(
                        'For Sale',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ))),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  SelectableText(
                    'Price: ' + item.data()['cost'] + ' ETB',
                    style: TextStyle(
                        
                        fontFamily: 'Muli',
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900),
                  ),
                ])
              : Container(
                  height: width*0.09,
                  width: width * 0.35,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black)),
                  child: Center(
                    child: 
                        Text(
                          item.data()['cost'] + ' ETB/' +  rateConverter(item.data()['rentCollection']),
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w900),
                              overflow: TextOverflow.ellipsis
                        ),
                   
                  ))
        ],
      ),
    );
  }

  Widget description(width, height) {
    return Container(
      padding: EdgeInsets.only(left: 20),
      width: width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: Colors.pink,
              ),
              Text(
                ' 2 reviews',
                style: TextStyle(
                    fontFamily: 'Muli', color: Color(0xff444444), fontSize: 12),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Private room - Journal Square',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Color(0xff444444),
                fontSize: width*0.045,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'CONTACT HOST FIRST B4 BOOKING!',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Color(0xff444444),
                fontSize: width*0.045,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
              height: width*0.09,
              width: 110,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black)),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      new String.fromCharCodes(new Runes('\u0024')) + "9500/",
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "month",
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  String rateConverter(String text) {
    var convertedText;
    if (text == 'Daily') {
      convertedText = 'day';
    } else if (text == 'Weekly') {
      convertedText = 'week';
    } else if (text == 'Monthly') {
      convertedText = 'month';
    } else if (text == 'Yearly') {
      convertedText = 'year';
    }
    return convertedText;
  }

  
}
