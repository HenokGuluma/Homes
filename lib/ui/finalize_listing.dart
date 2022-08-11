import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/ui/payment_listing.dart';
import 'package:provider/provider.dart';

class FinalizeListing extends StatefulWidget {
  List<String> imageFiles;
  String listingType;
  String rentCollection;
  String commonLocation;
  String cost;
  String area;
  bool isActive;
  String additionalNotes;
  String emailAddress;
  String phoneNumber;
  User user;
  FinalizeListing(
      {this.imageFiles,
      this.user,
      this.listingType,
      this.rentCollection,
      this.commonLocation,
      this.cost,
      this.additionalNotes,
      this.isActive,
      this.emailAddress,
      this.phoneNumber,
      this.area});

  @override
  FinalizeListingState createState() => FinalizeListingState();
}

class FinalizeListingState extends State<FinalizeListing> {
  int counter = 0;

  List<bool> balls = [true, true, true, true, true];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            'Preview Listing',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(children: [
          GestureDetector(
              child: Container(
                  child: Stack(alignment: Alignment.bottomCenter, children: [
            CarouselSlider(
              options: CarouselOptions(
                  initialPage: 0,
                  height: width * 0.8,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  onPageChanged: (index1, reason) {
                    setState(() {
                      counter = index1 % 5;
                    });
                  }),
              items: widget.imageFiles
                  .map((item) => Stack(children: [
                        Container(
                          height: width * 0.8,
                          width: width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(File(item)),
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
                    children: widget.imageFiles.map((url) {
                      int index1 = widget.imageFiles.indexOf(url);
                      return Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: Container(
                          width: index1 == counter ? 8.0 : 6.0,
                          height: index1 == counter ? 8.0 : 6.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                index1 == counter ? Colors.white : Colors.grey,
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
          ]))),
          SizedBox(
            height: 10,
          ),
          description(width, height)
        ]));
  }

  Widget description(width, height) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      width: width,
      child: Container(
          width: width * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.listingType +
                        ' - ' +
                        widget.area.toString() +
                        ' sq.m',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: 18,
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
                    size: 18,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.commonLocation,
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff444444),
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              widget.additionalNotes.isNotEmpty
                  ? Column(
                      children: [
                        Text(
                          widget.additionalNotes,
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Color(0xff444444),
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  : Center(),
              Container(
                  height: height * 0.05,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          new String.fromCharCodes(new Runes('\u0024')) +
                              widget.cost.toString() +
                              '/',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        rateConverter(widget.rentCollection)
                      ],
                    ),
                  )),
              SizedBox(
                height: 30,
              ),
              Center(
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => PaymentListing(
                                    imageFiles: widget.imageFiles,
                                    listingType: widget.listingType,
                                    rentCollection: widget.rentCollection,
                                    commonLocation: widget.commonLocation,
                                    cost: widget.cost,
                                    additionalNotes: widget.additionalNotes,
                                    area: widget.area,
                                    isActive: widget.isActive,
                                    user: widget.user,
                                  ))));
                    },
                    child: Container(
                        height: height * 0.08,
                        width: width * 0.6,
                        padding: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Icon(
                                  Icons.money_outlined,
                                  color: Colors.green,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Proceed to Payment',
                                    style: TextStyle(
                                        fontFamily: 'Muli',
                                        color: Color(0xff00ffff),
                                        fontSize: 16)),
                              ])),
                        ))),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          )),
    );
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
}
