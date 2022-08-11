import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/unlock_details.dart';
import 'package:provider/provider.dart';

class ListingDetailsTemp extends StatefulWidget {
  String imageFile;
  bool like;
  int index;
  List<String> imageFiles;
  List<dynamic> images;
  DocumentSnapshot item;
  UserVariables variables;
  bool notUnlock;
  VoidCallback removeItem;
  bool approved;
  bool declined;

  ListingDetailsTemp(
      {this.imageFile,
      this.like,
      this.index,
      this.imageFiles,
      this.images,
      this.item,
      this.variables,
      this.notUnlock,
      this.removeItem,
      this.approved,
      this.declined});

  @override
  ListingDetailsTempState createState() => ListingDetailsTempState();
}

class ListingDetailsTempState extends State<ListingDetailsTemp> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  bool like;
  int counter = 0;
  var _repository = Repository();
  List<String> properties = [
    'assets/listing_1.jpg',
    'assets/listing_2.jpg',
    'assets/listing_3.jpg',
    'assets/listing_4.jpg',
    'assets/listing_5.jpg',
  ];

  List<bool> balls = [true, true, true, true, true];

  bool approved = false;
  bool declined = false;
  bool undo = false;
  bool reasonSent = false;
  TextEditingController reasonController;

  @override
  void initState() {
    super.initState();
    like = widget.like;
    approved = widget.approved;
    declined = widget.declined;
    reasonController = TextEditingController();
    if (widget.item.data()['reason'] != null) {
      reasonController.text = widget.item.data()['reason'];
    } else {
      reasonController.text = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    like = widget.like;
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
          toolbarHeight: 50,
          backgroundColor: Colors.black,
          title: Text(
            'Listing Detail',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        backgroundColor: Colors.white,
        body: Container(
            height: height * 0.9,
            width: width,
            child: ListView(children: [
              /* Container(
                height: width * 0.8,
                width: width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(widget.imageFile), fit: BoxFit.cover),
                  // // borderRadius: BorderRadius.circular(width * 0.05),
                ),
              ), */
              GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      if (like == false) {
                        like = true;
                      } else {
                        like = false;
                      }
                    });
                  },
                  child: Container(
                      child:
                          Stack(alignment: Alignment.bottomCenter, children: [
                    CarouselSlider(
                      options: CarouselOptions(
                          initialPage: widget.index,
                          height: width * 0.8,
                          viewportFraction: 1.0,
                          enlargeCenterPage: false,
                          onPageChanged: (index1, reason) {
                            setState(() {
                              counter = (index1 - widget.index) % 5;
                            });
                          }),
                      items:
                          // properties
                          widget.images
                              .map((item) => Stack(children: [
                                    Container(
                                      height: width * 0.8,
                                      width: width,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image:
                                                // AssetImage(item),
                                                widget.variables.cachedImages[
                                                            item] !=
                                                        null
                                                    ? widget
                                                        .variables
                                                        .cachedImages[item]
                                                        .image
                                                    : AssetImage(
                                                        'assets/grey.png'),
                                            fit: BoxFit.cover),
                                        // borderRadius: BorderRadius.circular(width * 0.05),
                                      ),
                                    ),
                                    Container(
                                      height: width * 0.8,
                                      width: width,
                                      decoration: BoxDecoration(
                                        // borderRadius: BorderRadius.circular(width * 0.05),
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
                            children: widget.images.map((url) {
                              int index1 = widget.images.indexOf(url);
                              return Padding(
                                padding: EdgeInsets.only(left: 2, right: 2),
                                child: Container(
                                  width: index1 == counter ? 8.0 : 6.0,
                                  height: index1 == counter ? 8.0 : 6.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index1 == counter
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
                    /*  Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: IconButton(
                      icon: !like
                          ? SvgPicture.asset("assets/heart.svg",
                              width: 25, height: 25, color: Colors.white)
                          : SvgPicture.asset("assets/heart_fill.svg",
                              width: 25, height: 25, color: Colors.pink),
                      onPressed: () {
                        setState(() {
                          if (like == false) {
                            like = true;
                          } else {
                            like = false;
                          }
                        });
                      },
                    ),
                  ),
                ) */
                  ]))),
              SizedBox(
                height: 10,
              ),
              listingDescription(width, height, widget.item),
              SizedBox(
                height: height * 0.03,
              ),
              extraDescription(width, height, widget.item),
              SizedBox(
                height: height * 0.03,
              ),
              approved && !undo
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                          Container(
                            width: width * 0.35,
                            height: height * 0.07,
                            decoration: BoxDecoration(
                              color: Color(0xff00ff00),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Approved',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ])
                  : declined && !undo
                      ? Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: width * 0.35,
                                  height: height * 0.07,
                                  decoration: BoxDecoration(
                                    color: Color(0xffff0000),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Declined',
                                      style: TextStyle(
                                          fontFamily: 'Muli',
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ]),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20, top: 20),
                                child: Text(
                                  'Reason for Declining',
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 20),
                                child: Center(
                                    child: Container(
                                        width: width * 0.9,
                                        height: height * 0.2,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: TextField(
                                            maxLength: 200,
                                            autofocus: false,
                                            maxLines: 3,
                                            style: TextStyle(
                                                fontFamily: 'Muli',
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400),
                                            controller: reasonController,
                                            enabled: false,
                                            cursorColor: Colors.black,
                                            cursorHeight: 25,
                                            cursorWidth: 0.5,
                                            decoration: InputDecoration(
                                                hintText: '',
                                                // contentPadding: EdgeInsets.only(bottom: 20),
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                    fontFamily: 'Muli',
                                                    color: Color(0xff999999),
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ),
                                        ))),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                              MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    approved = true;
                                    undo = false;
                                  });
                                  widget.removeItem;
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
                                      'Approve Listing',
                                      style: TextStyle(
                                          fontFamily: 'Muli',
                                          color: Color(0xff00ffff),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    undo = false;
                                    declined = true;
                                  });
                                  widget.removeItem;
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
                                      'Decline Listing',
                                      style: TextStyle(
                                          fontFamily: 'Muli',
                                          color: Color(0xff00ffff),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
              SizedBox(
                height: height * 0.03,
              ),
            ])));
  }

  void showFloatingFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
      borderRadius: 8,
      //flushbarPosition: FlushbarPosition.,
      backgroundGradient: LinearGradient(
        colors: [Color(0xff00ffff), Color(0xff00ffff)],
        stops: [0.6, 1],
      ),
      duration: Duration(seconds: 2),
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      messageText: Center(
          child: Text(
        'Enter text before sending notification.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.black),
      )),
    )..show(context);
  }

  Widget extraDescription(var width, var height, DocumentSnapshot item) {
    return Container(
      padding: EdgeInsets.only(left: 20),
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Extra Details',
              style: TextStyle(
                  fontFamily: 'Muli',
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Text('Address:',
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
              SizedBox(
                width: 5,
              ),
              Text(item.data()['preciseLocation'],
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400))
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 15,
                color: Colors.black,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                item.data()['phoneNumber'],
                style: TextStyle(
                    fontFamily: 'Muli',
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Icon(
                Icons.email,
                size: 15,
                color: Colors.black,
              ),
              SizedBox(
                width: 5,
              ),
              Text(item.data()['emailAddress'],
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400)),
            ],
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget listingDescription(var width, var height, DocumentSnapshot item) {
    return Container(
        padding: EdgeInsets.only(left: 20),
        width: width,
        child: Row(children: [
          Container(
            width: width * 0.9,
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
                      ' Available',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Color(0xff444444),
                          fontSize: 12),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                    width: width * 0.75,
                    child: item.data()['listingType'] == 'Other'
                        ? Text(
                            item.data()['listingDescription'] +
                                ' - ' +
                                item.data()['area'] +
                                ' sq.m',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Color(0xff444444),
                                fontSize: 17,
                                fontWeight: FontWeight.w400),
                          )
                        : item.data()['floor'] != null &&
                                item.data()['floor'] != 'N/A'
                            ? Text(
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
                                    fontWeight: FontWeight.w400),
                              )
                            : Text(
                                item.data()['listingType'] +
                                    ' - ' +
                                    item.data()['area'] +
                                    ' sq.m',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Color(0xff444444),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400),
                              )),
                SizedBox(
                  height: 5,
                ),
                Container(
                    width: width * 0.9,
                    child: Row(
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
                          width: width * 0.75,
                          child: Text(item.data()['commonLocation'],
                              style: TextStyle(
                                fontFamily: 'Muli',
                                color: Color(0xff444444),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.clip),
                        )
                      ],
                    )),
                SizedBox(
                  height: 5,
                ),
                item.data()['additionalNotes'].toString().isNotEmpty
                    ? Text(
                        item.data()['additionalNotes'],
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Color(0xff444444),
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
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
                                child: Text(
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
                        Text(
                          'Price: ' + item.data()['cost'] + ' ETB',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.data()['cost'] + ' ETB/',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              rateConverter(item.data()['rentCollection'])
                            ],
                          ),
                        ))
              ],
            ),
          ),
        ]));
  }

  Widget rateConverter(String text) {
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
    return Text(
      convertedText,
      style: TextStyle(
          fontFamily: 'Muli',
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w400),
    );
  }

  Widget description(width, height) {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                width: width * 0.5,
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
                          ' Available',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Color(0xff444444),
                              fontSize: 12),
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
                          fontSize: 17,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                        height: height * 0.05,
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                new String.fromCharCodes(new Runes('\u0024')) +
                                    "9500/",
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Color(0xff00ffff),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "month",
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Color(0xff00ffff),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        ))
                  ],
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.05,
                  child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Center(
                          child: Row(children: [
                        Icon(
                          Icons.lock_open_outlined,
                          color: Colors.yellow,
                          size: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Unlock Details',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Color(0xff00ffff),
                                fontSize: 16)),
                      ]))),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15)),
                ),
                /* Container(
                    height: height * 0.05,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Center(
                          child: Row(children: [
                        Icon(
                          Icons.check,
                          color: Colors.yellow,
                          size: 15,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('Book now',
                            style: TextStyle( fontFamily: 'Muli', 
                                color: Color(0xff00ffff), fontSize: 16)),
                      ])),
                    )), */
                SizedBox(
                  height: 20,
                ),
              ],
            )
          ],
        ));
  }
}
