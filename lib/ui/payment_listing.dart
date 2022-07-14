import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:provider/provider.dart';

class PaymentListing extends StatefulWidget {
  List<String> imageFiles;
  User user;
  String listingType;
  String listingDescription;
  String rentCollection;
  String commonLocation;
  String preciseLocation;
  String cost;
  String floor;
  String area;
  String additionalNotes;
  String emailAddress;
  String phoneNumber;
  bool isActive;
  String forRent;
  String listingOwnerName;
  PaymentListing(
      {this.imageFiles,
      this.listingDescription,
      this.listingType,
      this.rentCollection,
      this.commonLocation,
      this.cost,
      this.floor,
      this.additionalNotes,
      this.area,
      this.isActive,
      this.user,
      this.preciseLocation,
      this.emailAddress,
      this.phoneNumber,
      this.listingOwnerName,
      this.forRent});

  @override
  PaymentListingState createState() => PaymentListingState();
}

class PaymentListingState extends State<PaymentListing> {
  int counter = 0;
  double _progress = 0;
  StorageReference _storageReference;
  bool uploading = false;
  List<bool> balls = [true, true, true, true, true];
  final _repository = Repository();
  bool posting = false;

  @override
  void initState() {
    super.initState();
    printDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  printDetails() {
    print(widget.emailAddress);
    print(widget.phoneNumber);
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
            'Finalize Listing',
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
          description(width, height),
          SizedBox(
            height: 10,
          ),
        ]));
  }

  Widget description(width, height) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      width: width,
      child: Container(
          width: width * 0.9,
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
                  Container(
                      width: width * 0.75,
                      child: widget.listingType == 'Other'
                          ? SelectableText(
                              widget.listingDescription +
                                  ' - ' +
                                  widget.area +
                                  ' sq.m',
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Color(0xff444444),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400),
                            )
                          : widget.floor != null && widget.floor != 'N/A'
                              ? SelectableText(
                                  widget.listingType +
                                      ' - ' +
                                      widget.area +
                                      ' sq.m' +
                                      ', ' +
                                      widget.floor,
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff444444),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                )
                              : SelectableText(
                                  widget.listingType +
                                      ' - ' +
                                      widget.area +
                                      ' sq.m',
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff444444),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                )),
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
                  Container(
                    width: width * 0.75,
                    child: SelectableText(
                      widget.commonLocation,
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Color(0xff444444),
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              widget.additionalNotes.isNotEmpty
                  ? Column(
                      children: [
                        Container(
                            width: width * 0.75,
                            child: SelectableText(
                              widget.additionalNotes,
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Color(0xff444444),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  : Center(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                widget.forRent == 'For Rent'
                    ? Container(
                        height: height * 0.05,
                        width: width * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SelectableText(
                                widget.cost.toString() + ' ETB/',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              rateConverter(widget.rentCollection)
                            ],
                          ),
                        ))
                    : Column(children: [
                        Container(
                            height: height * 0.05,
                            width: width * 0.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(15),
                            ),
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
                          'Price: ' + widget.cost,
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                Container(
                    height: height * 0.05,
                    width: 110,
                    // padding: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            'Is Active: ',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            widget.isActive ? 'Yes' : 'No',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    )),
              ]),
              SizedBox(
                height: 20,
              ),
              extraDescription(width, height),
              SizedBox(
                height: 30,
              ),
              Center(
                child: !posting
                    ? GestureDetector(
                        onTap: () async {
                          setState(() {
                            posting = true;
                          });
                          List<dynamic> urls =
                              await uploadImages(widget.imageFiles);
                          _repository
                              .addListingToDb(
                                  urls,
                                  widget.user.uid,
                                  widget.additionalNotes,
                                  widget.area,
                                  widget.user.displayName,
                                  widget.user.photoUrl,
                                  widget.emailAddress,
                                  widget.phoneNumber,
                                  widget.listingType,
                                  widget.listingDescription,
                                  widget.forRent,
                                  widget.rentCollection,
                                  widget.cost,
                                  widget.floor,
                                  widget.commonLocation,
                                  widget.preciseLocation,
                                  widget.isActive)
                              .then((value) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => InstaHomeScreen())),
                              (Route<dynamic> route) => false,
                            );
                            Fluttertoast.showToast(
                                msg:
                                    'You have successfully posted your listing.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Color(0xff00ffff),
                                textColor: Colors.black);
                          });
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Icon(
                                      Icons.post_add,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Post your Listing',
                                        style: TextStyle(
                                            fontFamily: 'Muli',
                                            color: Color(0xff00ffff),
                                            fontSize: 16)),
                                  ])),
                            )),
                      )
                    : Container(
                        height: height * 0.08,
                        width: width * 0.6,
                        padding: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                Icon(
                                  Icons.post_add,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                SelectableText('Posting...',
                                    style: TextStyle(
                                        fontFamily: 'Muli',
                                        color: Colors.white,
                                        fontSize: 16)),
                              ])),
                        )),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          )),
    );
  }

  Future<List<dynamic>> uploadImages(List<String> imageFiles) async {
    var imageUrls = [];
    await Future.forEach(imageFiles, (image) async {
      var url = await uploadImageToStorage(image);
      imageUrls.add(url.toString());
    });
    var strings = [];
    for (int i = 0; i < imageUrls.length; i++) {
      strings.add(imageUrls[i].toString());
    }
    return strings;
  }

  Future<String> uploadImageToStorage(String imageFile) async {
    print('The file name is ' + imageFile);
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    var image = await File(imageFile).readAsBytes();
    StorageUploadTask storageUploadTask = _storageReference.putData(image);
    storageUploadTask.events.listen((event) {
      setState(() {
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    print(url + 'babbbbby');
    return url.toString();
  }

  Widget extraDescription(var width, var height) {
    return Container(
      // padding: EdgeInsets.only(left: 20),
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Extra Details',
              style: TextStyle(
                  fontFamily: 'Muli',
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: 15,
          ),
          widget.forRent == 'For Sale'
              ? Center()
              : Row(
                  children: [
                    SelectableText('Owner Name:',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                      width: 5,
                    ),
                    SelectableText(widget.listingOwnerName,
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
          widget.forRent == 'For Sale'
              ? Center()
              : Row(
                  children: [
                    SelectableText('Address:',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400)),
                    SizedBox(
                      width: 5,
                    ),
                    SelectableText(widget.preciseLocation,
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400))
                  ],
                ),
          widget.forRent == 'For Sale'
              ? Center()
              : SizedBox(
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
              widget.forRent == 'For Sale'
                  ? SelectableText(
                      '0923577987',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    )
                  : SelectableText(
                      widget.phoneNumber,
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
          widget.emailAddress.isEmpty || widget.forRent == 'For Sale'
              ? Center()
              : Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 15,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SelectableText(widget.emailAddress,
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
}
