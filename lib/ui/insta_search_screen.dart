import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/listing_details.dart';
import 'package:instagram_clone/ui/listing_details_temp.dart';
import 'package:instagram_clone/ui/unlock_details.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:provider/provider.dart';

class InstaSearchScreen extends StatefulWidget {
  @override
  _InstaSearchScreenState createState() => _InstaSearchScreenState();
}

class _InstaSearchScreenState extends State<InstaSearchScreen>
    with AutomaticKeepAliveClientMixin {
  var _repository = Repository();
  List<DocumentSnapshot> list = List<DocumentSnapshot>();
  User _user = User();
  User currentUser;
  List<User> usersList = List<User>();
  List<User> topUsersList = List<User>();
  List<User> suggestedUsersList = List<User>();
  List<bool> isFollowing = [];
  Map<String, bool> _isFollowing = Map();
  TextEditingController controller = TextEditingController();
  Widget typeWidget = Center();
  Widget floorWidget = Center();
  Widget priceWidget = Center();
  Widget rentWidget = Center();
  Widget areaWidget = Center();

  List<String> dropDown = ['Type', 'Floor', 'Price', 'Offer', 'Area'];
  String chosenDropDown = 'Type';
  List<String> categories = [
    'Studio',
    '1-Bedroom',
    '2-Bedroom',
    '3-Bedroom',
    'Other'
  ];
  List<String> listingTypes = [
    'Studio',
    '1-Bedroom',
    '2-Bedroom',
    '3-Bedroom',
    'Other'
  ];
  List<String> forRent = [
    'For Rent',
    'For Sale',
  ];

  List<String> rentPrice = [
    '<6000',
    '6000-7500',
    '7500-9000',
    '9000-10500',
    '10500-12000',
    '12000-13500',
    '13500-15000',
    '15000-16500',
    '16500-18000',
    '18000-19500',
    '19500-20000',
    '20000-21500',
    '21500-23000',
    '23000-24500',
    '24500-26000',
    '26000-27500',
    '27500-29000',
    '29000-30500',
    '30500-32000',
    '32000-33500',
    '33500-35000',
    '35000-36500',
    '36500-39000',
    '39000-45000',
    '45000-50000',
    '50000-60000',
    '60000-75000',
    '>75000'
  ];

  Map<String, Map<int, int>> rentPriceConverter = {
    '<6000': {0: 0, 1: 5999},
    '6000-7500': {0: 6000, 1: 7499},
    '7500-9000': {0: 7500, 1: 8999},
    '9000-10500': {0: 9000, 1: 10499},
    '10500-12000': {0: 10500, 1: 11999},
    '12000-13500': {0: 12000, 1: 13499},
    '13500-15000': {0: 13500, 1: 14999},
    '15000-16500': {0: 15000, 1: 16499},
    '16500-18000': {0: 16500, 1: 17999},
    '18000-19500': {0: 18000, 1: 19499},
    '19500-20000': {0: 19500, 1: 19999},
    '20000-21500': {0: 20000, 1: 21499},
    '21500-23000': {0: 21500, 1: 22999},
    '23000-24500': {0: 23000, 1: 24499},
    '24500-26000': {0: 24500, 1: 25999},
    '26000-27500': {0: 26000, 1: 27499},
    '27500-29000': {0: 27500, 1: 28999},
    '29000-30500': {0: 29000, 1: 30499},
    '30500-32000': {0: 305500, 1: 31999},
    '32000-33500': {0: 32000, 1: 33499},
    '33500-35000': {0: 33500, 1: 34999},
    '35000-36500': {0: 35000, 1: 36499},
    '36500-39000': {0: 36500, 1: 38999},
    '39000-45000': {0: 39000, 1: 44999},
    '45000-50000': {0: 45000, 1: 49999},
    '50000-60000': {0: 50000, 1: 59999},
    '60000-75000': {0: 60000, 1: 74999},
    '>75000': {0: 75000, 1: 9999999}
  };

  Map<String, Map<int, int>> salePriceConverter = {
    '<800,000': {0: 0, 1: 799999},
    '800,000-1,000,000': {0: 800000, 1: 999999},
    '1,000,000 - 1,500,000': {0: 1000000, 1: 1499999},
    '1,500,000 - 2,000,000': {0: 1500000, 1: 1999999},
    '2,000,000 - 2,500,000': {0: 2000000, 1: 2499999},
    '2,500,000 - 3,000,000': {0: 2500000, 1: 2999999},
    '3,000,000 - 3,500,000': {0: 3000000, 1: 3499999},
    '3,500,000 - 4,000,000': {0: 3500000, 1: 3999999},
    '4,000,000 - 4,500,000': {0: 4000000, 1: 4499999},
    '4,500,000 - 5,000,000': {0: 4500000, 1: 4999999},
    '5,000,000 - 5,500,000': {0: 5000000, 1: 5499999},
    '5,500,000 - 6,000,000': {0: 5500000, 1: 5999999},
    '6,000,000 - 7,000,000': {0: 6000000, 1: 6999999},
    '7,000,000 - 8,000,000': {0: 7000000, 1: 7999999},
    '8,000,000 - 9,000,000': {0: 8000000, 1: 8999999},
    '9,000,000 - 10,000,000': {0: 9000000, 1: 9999999},
    '10,000,000 - 11,000,000': {0: 10000000, 1: 10999999},
    '11,000,000 - 12,000,000': {0: 11000000, 1: 11999999},
    '>12,000,000': {0: 12000000, 1: 100000000000}
  };

  List<String> salePrice = [
    '<800,000',
    '800,000-1,000,000',
    '1,000,000 - 1,500,000',
    '1,500,000 - 2,000,000',
    '2,000,000 - 2,500,000',
    '2,500,000 - 3,000,000',
    '3,000,000 - 3,500,000',
    '3,500,000 - 4,000,000',
    '4,000,000 - 4,500,000',
    '4,500,000 - 5,000,000',
    '5,000,000 - 5,500,000',
    '5,500,000 - 6,000,000',
    '6,000,000 - 7,000,000',
    '7,000,000 - 8,000,000',
    '8,000,000 - 9,000,000',
    '9,000,000 - 10,000,000',
    '10,000,000 - 11,000,000',
    '11,000,000 - 12,000,000',
    '>12,000,000'
  ];

  List<String> area = [
    '<30',
    '30-35',
    '35-40',
    '40-45',
    '45-50',
    '50-55',
    '55-60',
    '60-65',
    '65-70',
    '70-75',
    '75-80',
    '80-85',
    '85-90',
    '90-100',
    '100-120',
    '120-140',
    '140-160',
    '160-180',
    '180-200',
    '>200'
  ];

  Map<String, Map<int, int>> areaConverter = {
    '<30': {0: 0, 1: 30},
    '30-35': {0: 30, 1: 35},
    '35-40': {0: 35, 1: 40},
    '40-45': {0: 40, 1: 45},
    '45-50': {0: 45, 1: 50},
    '50-55': {0: 50, 1: 55},
    '55-60': {0: 55, 1: 60},
    '60-65': {0: 60, 1: 65},
    '65-70': {0: 65, 1: 70},
    '70-75': {0: 70, 1: 75},
    '75-80': {0: 75, 1: 80},
    '80-85': {0: 80, 1: 85},
    '85-90': {0: 85, 1: 90},
    '90-100': {0: 90, 1: 100},
    '100-120': {0: 100, 1: 120},
    '120-140': {0: 120, 1: 140},
    '140-160': {0: 140, 1: 160},
    '160-180': {0: 160, 1: 180},
    '180-200': {0: 180, 1: 200},
    '>200': {0: 200, 1: 1000000}
  };

  List<String> floor = [
    'Ground floor',
    '1st floor',
    '2nd floor',
    '3rd floor',
    '4th floor',
    '5th floor',
    '6th floor',
    '7th floor',
    '8th floor',
    '9th floor',
    '10th or above floor'
  ];

  List<DocumentSnapshot> listings = [];
  String query = '';
  String typeQuery = '';
  String floorQuery = '';
  String priceQuery = '';
  String rentQuery = '';
  String areaQuery = '';
  bool isSearching = false;
  List<DocumentSnapshot> filteredListings = [];
  bool isRent = true;
  ScrollController _scrollController = ScrollController();
  bool loading = true;
  Map<int, int> counters = {};

  List<String> properties = [
    'assets/listing_1.jpg',
    'assets/listing_2.jpg',
    'assets/listing_3.jpg',
    'assets/listing_4.jpg',
    'assets/listing_5.jpg'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((value) {
      getlistingItems();
    });
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  addCounters() {
    for (int index = 0; index < listings.length; index++) {
      counters.putIfAbsent(index, () => 0);
    }
  }

  getlistingItems() async {
    List<DocumentSnapshot> onlineListings =
        await _repository.getSearchListings();
    setState(() {
      listings = onlineListings;
      loading = false;
    });
    print(onlineListings[0].data());
    print('............................');
    addCounters();
  }

  Future<void> getCurrentUser() async {
    auth.User currentUser = await _repository.getCurrentUser();
    User user = await _repository.fetchUserDetailsById(currentUser.uid);
    setState(() {
      this.currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var variables = Provider.of<UserVariables>(context, listen: false);
    // print("INSIDE BUILD");
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(children: [
          SizedBox(
            height: height * 0.01,
          ),
          GestureDetector(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Container(
                      width: width * 0.8,
                      height: height*0.06,
                      decoration: BoxDecoration(
                          color: Color(0xfff1f1f1),
                          // border: Border.all(color: Colors.grey, width: 0.5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: <Widget>[
                          Center(
                            child: IconButton(
                              alignment: Alignment.topRight,
                              icon: SvgPicture.asset("assets/search.svg",
                                  width: 15, height: 15, color: Colors.black),
                            ),
                          ),
                          Center(
                              child: Container(
                            width: width * 0.5,
                            height: 30,
                            padding: EdgeInsets.only(left: 5, top: 0),
                            child: TextField(
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              controller: controller,
                              cursorColor: Colors.black,
                              cursorHeight: 20,
                              maxLength: 20,
                              cursorWidth: 0.5,
                              onChanged: searchQuery,
                              decoration: InputDecoration(
                                  hintText: 'Search by location',
                                  // contentPadding: EdgeInsets.only(bottom: 20),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff999999),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
                            ),
                          )),
                          controller.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      controller.text = '';
                                      query = '';
                                    });
                                    searchQuery('');
                                    print('clearing');
                                  },
                                  child: Center(
                                    child: Text(
                                      'Clear',
                                      style: TextStyle(
                                        fontFamily: 'Muli',
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ))
                              : Center(
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ))),
            onTap: () {
              /* showSearch(
                context: context,
                delegate: shownSearch(usersList: usersList, currentUser: currentUser)); */
            },
          ),
          Container(
            height: height * 0.82,
            child: isSearching
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.02),
                      Container(
                          padding: EdgeInsets.only(
                              left: width * 0.02, right: width * 0.02),
                          height: width * 0.08,
                          width: width,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              query == ''
                                  ? Center()
                                  : CategorySearchWidget(query, width, 'a'),
                              typeWidget,
                              areaWidget,
                              floorWidget,
                              rentWidget,
                              priceWidget
                            ],
                          )),
                      SizedBox(height: height * 0.02),
                      Container(
                          padding: EdgeInsets.only(
                              left: width * 0.02, right: width * 0.02),
                          constraints: BoxConstraints(
                            maxHeight: width*0.08,
                          ),
                          width: width,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                                  DropDownWidget('text', dropDown, 'hintText',
                                      width, height, 0)
                                ] +
                                categories.map((category) {
                                  return CategoryWidget(category, width);
                                }).toList()
                            /*  CategoryWidget(categories[0], width),
                              CategoryWidget(categories[1], width),
                              CategoryWidget(categories[2], width),
                              CategoryWidget(categories[3], width),
                              CategoryWidget(categories[4], width), */
                            ,
                          )),
                      SizedBox(height: height * 0.02),
                      Container(
                          height: height * 0.65,
                          child: Center(
                              child: resultWidget(height, width, variables)))
                    ],
                  )
                : ListView(
                    children: [
                      SizedBox(height: height * 0.02),
                      Container(
                          padding: EdgeInsets.only(
                              left: width * 0.02, right: width * 0.02),
                          height: width*0.08,
                          width: width,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                                  DropDownWidget('text', dropDown, 'hintText',
                                      width, height, 0)
                                ] +
                                categories.map((category) {
                                  return CategoryWidget(category, width);
                                }).toList()
                            /*  CategoryWidget(categories[0], width),
                              CategoryWidget(categories[1], width),
                              CategoryWidget(categories[2], width),
                              CategoryWidget(categories[3], width),
                              CategoryWidget(categories[4], width), */
                            ,
                          )),
                      SizedBox(height: height * 0.02),
                      RefreshIndicator(
                          onRefresh: () {
                            getlistingItems();
                            return Future.delayed(Duration(seconds: 2));
                          },
                          backgroundColor: Colors.black,
                          color: Color(0xff00ffff),
                          child: Container(
                              height: height * 0.75,
                              child: listings.length > 0
                                  ? GridView.builder(
                                      itemCount: listings.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: 1.1),
                                      cacheExtent: 5000000,

                                      // ignore: missing_return
                                      itemBuilder: ((context, index) {
                                        return listItem(
                                            list: listings,
                                            index: index,
                                            width: width,
                                            height: height,
                                            variables: variables);
                                      }))
                                  : loading
                                      ? Center(
                                          child: JumpingDotsProgressIndicator(
                                            fontSize: 50.0,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Refresh',
                                                    style: TextStyle(
                                                        fontFamily: 'Muli',
                                                        color:
                                                            Color(0xff00ffff),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )))
                    ],
                  ),
          )
        ]));
  }

  Widget emptyWidget() {
    return Center();
  }

  Widget DropDownWidget(String text, List<String> options, String hintText,
      var width, var height, index) {
    return Padding(
        padding: EdgeInsets.only(left: 10),
        child: Container(
          width: width * 0.25,
          height: height * 0.1,
          color: Colors.white,
          // padding: EdgeInsets.only(top: 10),
          child: Center(
              child: DropdownButton<String>(
            focusColor: Color(0xff99ffff),
            value: chosenDropDown,
            underline: Container(
              color: Colors.white,
            ),
            //elevation: 5,
            style: TextStyle(
              fontFamily: 'Muli',
              color: Colors.black,
              fontSize: width*0.05
            ),

            iconEnabledColor: Colors.black,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Colors.black,
                        fontSize: width*0.05,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center),
              );
            }).toList(),
            hint: Text(
              hintText,
              style: TextStyle(
                  fontFamily: 'Muli',
                  color: Color(0xff999999),
                  fontSize: width*0.05,
                  fontWeight: FontWeight.w400),
            ),
            onChanged: (String value) {
              setState(() {
                chosenDropDown = value;
              });
              if (value == 'Type') {
                setState(() {
                  categories = listingTypes;
                });
              } else if (value == 'Floor') {
                setState(() {
                  categories = floor;
                });
              } else if (value == 'Price') {
                if (rentQuery != 'For Sale') {
                  setState(() {
                    categories = rentPrice;
                  });
                } else {
                  setState(() {
                    categories = salePrice;
                  });
                }
              } else if (value == 'Offer') {
                setState(() {
                  categories = forRent;
                });
              } else if (value == 'Area') {
                setState(() {
                  categories = area;
                });
              }
            },
          )),
        ));
  }

  Widget listItem(
      {List<DocumentSnapshot> list,
      int index,
      var width,
      var height,
      var variables}) {
    List<dynamic> imageList = list[index].data()['images'];
    return Padding(
        padding: EdgeInsets.only(bottom: 0, left: 5, right: 5),
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
                                  images: list[index].data()['images'],
                                  variables: variables,
                                ))));
                  },
                  child: Stack(children: [
                    Container(
                      height: width * 0.4,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: variables.cachedImages[imageList[0]] != null
                                ? variables
                                    .cachedImages[imageList[0].toString()].image
                                : AssetImage('assets/grey.png'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(width * 0.05),
                        // border: Border.all(color: Colors.black, width: 0.5)
                      ),
                    ),
                    Container(
                      height: width * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.05),
                        gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black38,
                              Colors.black54
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
                  ]))),
        ]));
  }

  Widget CategoryWidget(String text, var width) {
    return /* SizedBox(
        height: width*0.01,
        // constraints: BoxConstraints(maxHeight: 30),
        child: */ GestureDetector(
            onTap: () {
              if (chosenDropDown == 'Type') {
                setState(() {
                  typeWidget = CategorySearchWidget(text, width, 'type');
                  typeQuery = text;
                });
              } else if (chosenDropDown == 'Floor') {
                setState(() {
                  floorWidget = CategorySearchWidget(text, width, 'floor');
                  floorQuery = text;
                });
              } else if (chosenDropDown == 'Offer') {
                setState(() {
                  rentWidget = CategorySearchWidget(text, width, 'rent');
                  rentQuery = text;
                });
              } else if (chosenDropDown == 'Price') {
                setState(() {
                  priceWidget = CategorySearchWidget(text, width, 'price');
                  priceQuery = text;
                });
              } else if (chosenDropDown == 'Area') {
                setState(() {
                  areaWidget = CategorySearchWidget(text, width, 'area');
                  areaQuery = text;
                });
              }
              clickQuery(text);
            },
            child: Padding(
                padding: EdgeInsets.only(left: 2, right: 2),
                child: Container(
                    height:  width*0.08,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                        color: Color(0xffd1d1d1),
                        borderRadius: BorderRadius.circular(width*0.05)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black87,
                            fontSize: width*0.045,
                          ),
                        ),
                      ),
                    )))
                    // )
                    );
  }

  Widget CategorySearchWidget(String text, var width, String categoryWidget) {
    return Container(
      height: width*0.08,
      child: GestureDetector(
      onTap: () {
        if (categoryWidget == 'type') {
          setState(() {
            typeQuery = '';
            typeWidget = Center();
            clickQuery('query1');
          });
        } else if (categoryWidget == 'floor') {
          setState(() {
            floorQuery = '';
            floorWidget = Center();
            clickQuery('query1');
          });
        } else if (categoryWidget == 'rent') {
          setState(() {
            rentQuery = '';
            rentWidget = Center();
            clickQuery('query1');
          });
        } else if (categoryWidget == 'price') {
          setState(() {
            priceQuery = '';
            priceWidget = Center();
            clickQuery('query1');
          });
        } else if (categoryWidget == 'area') {
          setState(() {
            areaQuery = '';
            areaWidget = Center();
            clickQuery('query1');
          });
        } else {
          setState(() {
            query = '';
            // clickQuery('query1');
            controller.text = '';
            clickQuery('query1');
            // searchQuery('');
          });
        }

        if (typeQuery == '' &&
            floorQuery == '' &&
            rentQuery == '' &&
            priceQuery == '' &&
            areaQuery == '' &&
            query == '') {
          setState(() {
            isSearching = false;
          });
        }
      },
      child: Padding(
          padding: EdgeInsets.only(left: 2, right: 2),
          child: Container(
              height: width*0.08,
              decoration: BoxDecoration(
                  color: Color(0xffd1d1d1),
                  borderRadius: BorderRadius.circular(width*0.05)),
              child: Row(children: [
                Container(
                    height: width*0.08,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Color(0xff008888),
                                  fontSize: width*0.045,
                                ),
                                // overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: SvgPicture.asset("assets/close.svg",
                                width: 10, height: 10, color: Colors.black),
                          )
                        ])),
                Center()
              ]))),
    ));
  }

  String renderSearchQuery() {
    String result = 'No search results with the filter ';
    if (query.isNotEmpty) {
      result = result + query + ', ';
    }
    if (typeQuery.isNotEmpty) {
      result = result + typeQuery + ', ';
    }
    if (areaQuery.isNotEmpty) {
      result = result + areaQuery + ', ';
    }
    if (rentQuery.isNotEmpty) {
      result = result + rentQuery + ', ';
    }
    if (floorQuery.isNotEmpty) {
      result = result + floorQuery + ', ';
    }
    if (priceQuery.isNotEmpty) {
      result = result + priceQuery + ' ETB';
    }
    return result;
  }

  Widget resultWidget(var height, var width, var variables) {
    return Container(
        height: height * 0.7,
        child: filteredListings.length == 0
            ? Center(
                child: Container(
                    width: width * 0.8,
                    child: Text(
                      renderSearchQuery(),
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 16),
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    )),
              )
            : ListView.builder(
                //shrinkWrap: true,
                controller: _scrollController,
                itemCount: filteredListings.length,
                itemBuilder: ((context, index) => listingItem(
                    list: filteredListings,
                    index: index,
                    width: width,
                    height: height,
                    variables: variables))));
  }

  void searchQuery(String text) {
    print(typeQuery);
    print(text);
    print(priceQuery);
    print('is the query');

    final suggestions = listings.where((listing) {
      final listingLocation =
          listing.data()['commonLocation'].toString().toLowerCase();
      final listingType =
          listing.data()['listingType'].toString().toLowerCase();
      final floor = listing.data()['floor'].toString().toLowerCase();
      final forRent = listing.data()['forRent'].toString().toLowerCase();
      final price = removeComma(listing.data()['cost'].toString());
      final area = removeComma(listing.data()['area'].toString());
      bool priceIsRight;
      print(rentQuery);
      bool areaIsRight;
      if (areaQuery == '') {
        areaIsRight = true;
      } else {
        var areaMap = areaConverter[areaQuery];
        int lower = areaMap[0];
        int higher = areaMap[1];
        areaIsRight = area >= lower && area <= higher;
      }

      if (priceQuery == '') {
        priceIsRight = true;
      } else if (rentQuery == 'For Rent') {
        var map = rentPriceConverter[priceQuery];
        if (map == null) {
          priceIsRight = false;
        } else {
          int lower = map[0];
          int higher = map[1];
          priceIsRight = price >= lower && price <= higher;
        }
      } else if (rentQuery == 'For Sale') {
        var map = salePriceConverter[priceQuery];
        if (map == null) {
          priceIsRight = false;
        } else {
          int lower = map[0];
          int higher = map[1];
          priceIsRight = price >= lower && price <= higher;
        }
      } else {
        print('booya');
        var map = rentPriceConverter[priceQuery];
        var map2 = salePriceConverter[priceQuery];
        if (map == null) {
          if (map2 == null) {
            priceIsRight = false;
          } else {
            int lower = map2[0];
            int higher = map2[1];
            priceIsRight = price >= lower && price <= higher;
          }
        } else {
          int lower = map[0];
          int higher = map[1];
          priceIsRight = price >= lower && price <= higher;
        }
      }
      final input = controller.text.toLowerCase();
      final typeInput = typeQuery.toLowerCase();
      final floorInput = floorQuery.toLowerCase();
      bool pass;
      bool queryPass;
      if (input == '') {
        queryPass = true;
      } else {
        queryPass = listingLocation.contains(input);
      }

      final rentInput = rentQuery.toLowerCase();
      if (rentQuery == 'For Sale') {
        pass = forRent.contains(rentInput);
      } else {
        pass = forRent != 'for sale';
      }
      return (queryPass &&
          listingType.contains(typeInput) &&
          floor.contains(floorInput) &&
          pass &&
          priceIsRight &&
          areaIsRight);
    }).toList();

    if (typeQuery == '' &&
        floorQuery == '' &&
        rentQuery == '' &&
        priceQuery == '' &&
        areaQuery == '' &&
        text == '') {
      setState(() {
        isSearching = false;
      });
      print('baaaam');
    } else {
      setState(() {
        isSearching = true;
        filteredListings = suggestions;
        query = text;
      });
    }
  }

  double removeComma(String text) {
    String removed = text.replaceAll(',', '');
    double num = double.parse(removed);
    return num;
  }

  void clickQuery(String query1) {
    final suggestions = listings.where((listing) {
      final listingLocation =
          listing.data()['commonLocation'].toString().toLowerCase();
      final listingType =
          listing.data()['listingType'].toString().toLowerCase();
      final floor = listing.data()['floor'].toString().toLowerCase();
      final forRent = listing.data()['forRent'].toString().toLowerCase();
      final price = removeComma(listing.data()['cost'].toString());
      final area = removeComma(listing.data()['area'].toString());
      bool priceIsRight;
      print(rentQuery);
      print('is the query');
      bool areaIsRight;
      if (areaQuery == '') {
        areaIsRight = true;
      } else {
        var areaMap = areaConverter[areaQuery];
        int lower = areaMap[0];
        int higher = areaMap[1];
        areaIsRight = area >= lower && area <= higher;
      }
      if (priceQuery == '') {
        priceIsRight = true;
      } else if (rentQuery == 'For Rent') {
        var map = rentPriceConverter[priceQuery];
        if (map == null) {
          priceIsRight = false;
        } else {
          int lower = map[0];
          int higher = map[1];
          priceIsRight = price.toInt() >= lower && price <= higher;
        }
      } else if (rentQuery == 'For Sale') {
        var map = salePriceConverter[priceQuery];
        if (map == null) {
          priceIsRight = false;
        } else {
          int lower = map[0];
          int higher = map[1];
          priceIsRight = price.toInt() >= lower && price <= higher;
        }
      } else {
        // print('booya');
        var map = rentPriceConverter[priceQuery];
        var map2 = salePriceConverter[priceQuery];
        if (map == null) {
          // print('booya');
          if (map2 == null) {
            // print('booya2');
            priceIsRight = false;
          } else {
            int lower = map2[0];
            int higher = map2[1];
            /*  print(lower.toString() + 'is the lower');
            print(higher.toString() + 'is the higher');
            print(price.toString() + 'is the price'); */
            priceIsRight = price.toInt() >= lower && price <= higher;
            print(priceIsRight);
          }
        } else {
          int lower = map[0];
          int higher = map[1];
          priceIsRight = price.toInt() >= lower && price <= higher;
          print(priceIsRight);
        }
      }

      final input = controller.text.toLowerCase();
      final typeInput = typeQuery.toLowerCase();
      final floorInput = floorQuery.toLowerCase();
      bool pass;
      bool queryPass;
      if (input == '') {
        queryPass = true;
      } else {
        queryPass = listingLocation.contains(input);
      }

      final rentInput = rentQuery.toLowerCase();
      if (rentQuery == 'For Sale') {
        pass = forRent.contains(rentInput);
      } else if (rentQuery == 'For Rent') {
        pass = forRent != 'for sale';
      } else {
        pass = true;
      }
      return (queryPass &&
          listingType.contains(typeInput) &&
          floor.contains(floorInput) &&
          pass &&
          priceIsRight &&
          areaIsRight);
    }).toList();

    if (typeQuery == '' &&
        floorQuery == '' &&
        rentQuery == '' &&
        priceQuery == '' &&
        areaQuery == '' &&
        query == '') {
      setState(() {
        isSearching = false;
      });
    } else {
      setState(() {
        isSearching = true;
        filteredListings = suggestions;
      });
    }
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
                        counters[index] = (index1);
                      });
                    }),
                items: imageList
                    .map<Widget>((item) => Stack(children: [
                          Container(
                            height: width * 0.7,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: variables.cachedImages[item] == null
                                      ? AssetImage('assets/grey.png')
                                      : variables.cachedImages[item].image,
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(width * 0.05),
                              // border: Border.all(
                              //     color: Colors.black, width: 0.5)
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
            ])),
          )),
          SizedBox(
            height: 10,
          ),
          listingDescription(width, height, list[index]),
        ]));
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
            Row(
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
                          fontSize: 17,
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
                              fontSize: 17,
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
                              fontSize: 17,
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
                      fontSize: 17,
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
                  width: width * 0.85,
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                         TextSpan(
                    text: 'Description: ',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: 14,
                        fontWeight: FontWeight.w900),
                  ),
                   TextSpan(
                    text: item.data()['additionalNotes'],
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: 14,
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
                      height: height * 0.05,
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
                  height: height * 0.05,
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
