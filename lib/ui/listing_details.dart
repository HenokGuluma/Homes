import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/unlock_details.dart';
import 'package:provider/provider.dart';

class ListingDetails extends StatefulWidget {
  String imageFile;
  bool like;
  int index;
  List<String> imageFiles;
  List<dynamic> images;
  DocumentSnapshot item;
  UserVariables variables;
  bool notUnlock;

  ListingDetails(
      {this.imageFile,
      this.like,
      this.index,
      this.imageFiles,
      this.images,
      this.item,
      this.variables,
      this.notUnlock});

  @override
  ListingDetailsState createState() => ListingDetailsState();
}

class ListingDetailsState extends State<ListingDetails> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  bool like;
  int counter = 0;
  List<String> properties = [
    'assets/listing_1.jpg',
    'assets/listing_2.jpg',
    'assets/listing_3.jpg',
    'assets/listing_4.jpg',
    'assets/listing_5.jpg',
  ];

  List<bool> balls = [true, true, true, true, true];

  @override
  void initState() {
    super.initState();
    like = widget.like;
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
          title: SelectableText(
            'Listing Detail',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  child: Stack(alignment: Alignment.bottomCenter, children: [
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
                                            NetworkImage(item.toString()),
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
          listingDescription(width, height, widget.item)
        ]));
  }

  Widget listingDescription(var width, var height, DocumentSnapshot item) {
    return Container(
        padding: EdgeInsets.only(left: 20),
        width: width,
        child: Row(children: [
          Container(
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
                    SelectableText(
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
                SelectableText(
                  item.data()['listingType'] +
                      ' - ' +
                      item.data()['area'] +
                      ' sq.m',
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Color(0xff444444),
                      fontSize: 17,
                      fontWeight: FontWeight.w400),
                ),
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
                      width: width * 0.5,
                      child: Text(item.data()['commonLocation'],
                          style: TextStyle(
                            fontFamily: 'Muli',
                            color: Color(0xff444444),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                item.data()['additionalNotes'].toString().isNotEmpty
                    ? SelectableText(
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
                Container(
                    height: height * 0.05,
                    width: width * 0.32,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black)),
                    child: Center(
                      child: item.data()['forRent'] == 'For Sale'
                          ? Column(children: [
                              SelectableText(
                                item.data()['cost'] + ' ETB/',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              SelectableText(
                                'For Sale',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ])
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SelectableText(
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
            width: width * 0.6,
          ),
          widget.notUnlock
              ? Center()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Container(
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
                              SelectableText('Unlock Details',
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => UnlockDetails(
                                      item: item,
                                      variables: widget.variables,
                                      imageFiles: widget.imageFiles,
                                      images: widget.images,
                                      index: widget.index,
                                    ))));
                      },
                    ),
                    SizedBox(height: height * 0.1),
                  ],
                )
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
    return SelectableText(
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
                        SelectableText(
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
                    SelectableText(
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
                    SelectableText(
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
                              SelectableText(
                                new String.fromCharCodes(new Runes('\u0024')) +
                                    "9500/",
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Color(0xff00ffff),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              SelectableText(
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
                        SelectableText('Unlock Details',
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
                        SelectableText('Book now',
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
