import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/ui/finalize_listing.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/listing_details.dart';
import 'package:instagram_clone/ui/payment_listing.dart';
import 'package:instagram_clone/ui/update_listing.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = "AIzaSyDj5hP1P4PKxOBSjk7zznpJnLG_KJRuLbE";

class ModifyListing extends StatefulWidget {
  DocumentSnapshot details;
  UserVariables variables;

  ModifyListing({this.details, this.variables});
  @override
  ModifyListingState createState() => ModifyListingState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class ModifyListingState extends State<ModifyListing>
    with AutomaticKeepAliveClientMixin {
  Mode _mode = Mode.overlay;
  TextEditingController typeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController rentController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController specificController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  List<String> bedOptions = [
    'Studio',
    '1-Bedroom',
    '2-Bedroom',
    '3-Bedroom',
    'Other'
  ];
  List<String> durationOptions = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];
  List<String> floorOptions = [
    'N/A',
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

  List<String> chosenValue = ['1-Bedroom', 'Monthly', '1st floor', 'For Rent'];
  List<String> saleOrRent = ['For Rent', 'For Sale'];
  String optionSelected = '';
  bool isActive = true;

  List<String> properties = [
    'assets/listing_1.jpg',
    'assets/listing_2.jpg',
    'assets/listing_3.jpg',
    'assets/listing_4.jpg',
    'assets/listing_5.jpg'
  ];
  var _repository = Repository();
  int counter = 0;
  int picIndex = 0;
  ImagePicker _imagePicker = ImagePicker();
  String common_location = '';
  bool reUpload = false;

  Map<int, Widget> listingPictures = {};
  List<String> imageFiles = [];
  List<String> imageUploads = [];
  List<Widget> listings = [];

  bool previewMode = false;
  User currentUser;
  List<Widget> emptyWidgets = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    listingPictures[0] = EmptyWidget();
    listingPictures[1] = EmptyWidget();
    listingPictures[2] = EmptyWidget();
    listingPictures[3] = EmptyWidget();
    listings.add(EmptyWidget());
    listings.add(EmptyWidget());
    listings.add(EmptyWidget());
    listings.add(EmptyWidget());
    getCurrentUser().then((value) {});
    if (widget.details.data()['listingType'] == 'Other') {
      typeController.text = widget.details.data()['listingDescription'];
      optionSelected = 'Other';
    } else {
      typeController.text = widget.details.data()['listingType'].toString();
    }

    chosenValue[0] = widget.details.data()['listingType'];
    chosenValue[1] = widget.details.data()['rentCollection'];
    chosenValue[2] = widget.details.data()['floor'];
    if (widget.details.data()['forRent'] != null) {
      chosenValue[3] = widget.details.data()['forRent'];
    } else {
      chosenValue[3] = 'For Rent';
    }
    var images = widget.details.data()['images'];
    for (int i = 0; i < images.length; i++) {
      imageUploads.add(images[i]);
    }
    var item = widget.details.data();

    nameController.text = item['listingOwnerName'].toString();
    areaController.text = item['area'].toString();
    rentController.text = item['rent'].toString();
    costController.text = item['cost'].toString();
    locationController.text = item['commonLocation'].toString();
    specificController.text = item['preciseLocation'].toString();
    phoneController.text = item['phoneNumber'].toString();
    emailController.text = item['emailAddress'].toString();
    noteController.text = item['additionalNotes'].toString();
    isActive = item['isActive'];

    emptyWidgets.add(Center());
    emptyWidgets.add(Center());
    // listingPictures[4] = EmptyWidget();
  }

  Future<Null> getCurrentUser() async {
    auth.User user = await _repository.getCurrentUser();
    User _user = await _repository.getUserWithId(user.uid);
    setState(() {
      currentUser = _user;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // print("INSIDE BUILD");
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          centerTitle: true,
          toolbarHeight: 50,
          title: Text(
            'Modify Listing',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Color(0xff00ffff),
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: [
            imageUploads.length > 1 || imageFiles.length > 1
                ? Center()
                : Container(
                    padding: EdgeInsets.only(top: height * 0.05),
                    child: Center(
                      child: Text('Add at least two pictures of your listing.',
                          style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          )),
                    ),
                  ),
            SizedBox(
              height: height * 0.03,
            ),
            Padding(
                padding: EdgeInsets.only(left: 20, bottom: 10),
                child: Row(
                  children: [
                    (imageUploads.length != 0 && !reUpload) ||
                            imageFiles.length != 0
                        ? MaterialButton(
                            onPressed: () {
                              if (previewMode) {
                                setState(() {
                                  previewMode = false;
                                  counter = 0;
                                });
                              } else {
                                setState(() {
                                  previewMode = true;
                                });
                              }
                            },
                            child: Container(
                                width: width * 0.2,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: !previewMode
                                        ? Colors.black
                                        : Colors.white,
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                  child: Text(
                                    previewMode ? 'Back' : 'Preview',
                                    style: TextStyle(
                                      fontFamily: 'Muli',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: !previewMode
                                          ? Color(0xff00ffff)
                                          : Colors.black,
                                    ),
                                  ),
                                )),
                          )
                        : Center(),

                    MaterialButton(
                      onPressed: () {
                        if (reUpload) {
                          setState(() {
                            reUpload = false;
                          });
                        } else {
                          setState(() {
                            reUpload = true;
                            previewMode = false;
                          });
                        }
                      },
                      child: Container(
                          width: width * 0.22,
                          height: 30,
                          decoration: BoxDecoration(
                              color: !reUpload ? Colors.black : Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              reUpload ? 'Cancel' : 'Re-Upload',
                              style: TextStyle(
                                fontFamily: 'Muli',
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: !reUpload
                                    ? Color(0xff00ffff)
                                    : Colors.black,
                              ),
                            ),
                          )),
                    )

                    // Text('Preview Mode', style: TextStyle( fontFamily: 'Muli', color: Colors.black, fontSize: 16),)
                  ],
                )),
            !reUpload
                ? !previewMode
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.05, right: width * 0.05),
                        child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8.0, // gap between adjacent chips
                            runSpacing: 8.0, // gap between lines
                            children: imageUploads.map((item) {
                              int index = imageUploads.indexOf(item);
                              return UploadedImageWidget(
                                  index, imageUploads[index], height);
                            }).toList()),
                      )
                    : Container(
                        child:
                            Stack(alignment: Alignment.bottomCenter, children: [
                        CarouselSlider(
                          options: CarouselOptions(
                              initialPage: 0,
                              height: width * 0.7,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              onPageChanged: (index1, reason) {
                                setState(() {
                                  counter = index1;
                                });
                              }),
                          items: imageUploads
                              .map((item) => Stack(children: [
                                    Container(
                                      height: width * 0.7,
                                      width: width * 0.9,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: widget.variables
                                                        .cachedImages[item] !=
                                                    null
                                                ? widget.variables
                                                    .cachedImages[item].image
                                                : NetworkImage(item),
                                            fit: BoxFit.cover),
                                        borderRadius:
                                            BorderRadius.circular(width * 0.05),
                                      ),
                                    ),
                                    Container(
                                      height: width * 0.7,
                                      width: width * 0.9,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(width * 0.05),
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
                                children: imageUploads.map((url) {
                                  int index1 = imageUploads.indexOf(url);
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
                            ))
                      ]))
                : !previewMode
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.05, right: width * 0.05),
                        child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8.0, // gap between adjacent chips
                            runSpacing: 8.0, // gap between lines
                            children: imageFiles.length < 5
                                ? [AddPicture(height)] +
                                    imageFiles.map((item) {
                                      int index = imageFiles.indexOf(item);
                                      return PictureWidget(
                                          index, imageFiles[index], height);
                                    }).toList() +
                                    emptyWidgets.map((item) {
                                      return emptyBox(width);
                                    }).toList()
                                : imageFiles.map((item) {
                                    int index = imageFiles.indexOf(item);
                                    return PictureWidget(
                                        index, imageFiles[index], height);
                                  }).toList()),
                      )
                    : Container(
                        child:
                            Stack(alignment: Alignment.bottomCenter, children: [
                        CarouselSlider(
                          options: CarouselOptions(
                              initialPage: 0,
                              height: width * 0.7,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              onPageChanged: (index1, reason) {
                                setState(() {
                                  counter = index1;
                                });
                              }),
                          items: imageFiles
                              .map((item) => Stack(children: [
                                    Container(
                                      height: width * 0.7,
                                      width: width * 0.9,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: FileImage(File(item)),
                                            fit: BoxFit.cover),
                                        borderRadius:
                                            BorderRadius.circular(width * 0.05),
                                      ),
                                    ),
                                    Container(
                                      height: width * 0.7,
                                      width: width * 0.9,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(width * 0.05),
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
                                children: imageFiles.map((url) {
                                  int index1 = imageFiles.indexOf(url);
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
                            ))
                      ])),
            SizedBox(
              height: height * 0.02,
            ),
            DropDownWidget('Listing Type', bedOptions, 'e.g - 2-Bedroom', width,
                height, 0),
            SizedBox(
              height: height * 0.01,
            ),
            chosenValue[0] == 'Other'
                ? TextInputWidget(
                    'Listing Description',
                    'e.g - Villa, 4-Bedroom, 2-Bathroom',
                    width,
                    height,
                    typeController,
                    false,
                    35)
                : Center(),
            chosenValue[0] == 'Other'
                ? SizedBox(
                    height: height * 0.01,
                  )
                : Center(),
            DropDownWidget('Rent or Sale:', saleOrRent, 'e.g - For Rent', width,
                height, 3),
            chosenValue[3] == 'For Rent'
                ? Column(children: [
                    DropDownWidget('Rent Collection:', durationOptions,
                        'e.g - monthly', width, height, 1),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    TextInputWidget('Cost in ETB', 'e.g - 9500', width, height,
                        costController, false, 20)
                  ])
                : TextInputWidget('Price', 'e.g - 9500', width, height,
                    costController, false, 20),
            DropDownWidget('Floor/Level:', floorOptions, 'e.g - 1st floor',
                width, height, 2),
            SizedBox(
              height: height * 0.01,
            ),
            TextInputWidget('Area in sq.m', 'e.g - 56', width, height,
                areaController, false, 10),
            SizedBox(
              height: height * 0.01,
            ),
            TextInputWidget('Common Location', 'e.g - Megenagna', width, height,
                locationController, true, 40),
            SizedBox(
              height: height * 0.01,
            ),
            TextInputWidget(
                'Specific Address',
                'e.g - Gurd Shola Road, B-12 H.No-20',
                width,
                height,
                specificController,
                false,
                30),
            SizedBox(
              height: height * 0.01,
            ),
            TextInputWidget('Owner Name', 'e.g - John Doe', width, height,
                nameController, false, 20),
            SizedBox(
              height: height * 0.01,
            ),
            TextInputWidget('Email Address', 'e.g - eg@gmail.com', width,
                height, emailController, false, 25),
            SizedBox(
              height: height * 0.01,
            ),
            TextInputWidget('Phone Number', 'e.g - 09XXXXXXXX', width, height,
                phoneController, false, 15),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                    focusColor: Colors.black,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Is Active',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w400))
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    'Additional Notes',
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
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 10),
                            child: TextField(
                              maxLength: 100,
                              autofocus: false,
                              maxLines: 3,
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              controller: noteController,
                              cursorColor: Colors.black,
                              cursorHeight: 25,
                              cursorWidth: 0.5,
                              decoration: InputDecoration(
                                  hintText: '',
                                  // contentPadding: EdgeInsets.only(bottom: 20),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff999999),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ))),
                )
              ],
            ),
            Container(
              width: width * 0.2,
              height: height * 0.05,
              child: MaterialButton(
                  onPressed: () {
                    print(currentUser.uid);
                    print('is the uid');
                    (imageUploads.length != 0 || imageFiles.length > 1) &&
                            costController.value.text.isNotEmpty &&
                            areaController.value.text.isNotEmpty &&
                            specificController.value.text.isNotEmpty &&
                            phoneController.value.text.isNotEmpty &&
                            nameController.value.text.isNotEmpty &&
                            locationController.text.length != 0 &&
                            (imageFiles.length > 1 || !reUpload)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => UpdateListing(
                                      variables: widget.variables,
                                      user: currentUser,
                                      imageFiles:
                                          reUpload ? imageFiles : imageUploads,
                                      cost: costController.text,
                                      floor: chosenValue[2],
                                      additionalNotes: noteController.text,
                                      area: areaController.text,
                                      listingType: chosenValue[0],
                                      listingDescription: typeController.text,
                                      rentCollection: chosenValue[1],
                                      commonLocation: locationController.text,
                                      preciseLocation: specificController.text,
                                      emailAddress: emailController.value.text,
                                      phoneNumber: phoneController.value.text,
                                      isActive: isActive,
                                      updatePhoto: reUpload,
                                      reference: widget.details.id,
                                      listingOwnerName: nameController.text,
                                      forRent: chosenValue[3],
                                    ))))
                        : print('');
                  },
                  child: Container(
                      width: width * 0.2,
                      height: height * 0.05,
                      decoration: BoxDecoration(
                          color: (imageUploads.length != 0 ||
                                      imageFiles.length > 1) &&
                                  costController.value.text.isNotEmpty &&
                                  areaController.value.text.isNotEmpty &&
                                  specificController.value.text.isNotEmpty &&
                                  phoneController.value.text.isNotEmpty &&
                                  nameController.value.text.isNotEmpty &&
                                  locationController.text.length != 0 &&
                                  (imageFiles.length > 1 || !reUpload)
                              ? Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: (imageUploads.length != 0 ||
                                          imageFiles.length > 1) &&
                                      costController.value.text.isNotEmpty &&
                                      areaController.value.text.isNotEmpty &&
                                      specificController
                                          .value.text.isNotEmpty &&
                                      phoneController.value.text.isNotEmpty &&
                                      nameController.value.text.isNotEmpty &&
                                      locationController.text.length != 0 &&
                                      (imageFiles.length > 1 || !reUpload)
                                  ? Colors.black
                                  : Colors.grey)),
                      child: Center(
                        child: Text(
                          'Next',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: (imageUploads.length != 0 ||
                                          imageFiles.length > 1) &&
                                      costController.value.text.isNotEmpty &&
                                      areaController.value.text.isNotEmpty &&
                                      specificController
                                          .value.text.isNotEmpty &&
                                      phoneController.value.text.isNotEmpty &&
                                      nameController.value.text.isNotEmpty &&
                                      locationController.text.length != 0 &&
                                      (imageFiles.length > 1 || !reUpload)
                                  ? Color(0xff00ffff)
                                  : Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ))),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ));
  }

  Widget emptyBox(var width) {
    return DottedBorder(
      color: Colors.black38,
      dashPattern: [8, 4],
      strokeWidth: 1,
      borderType: BorderType.RRect,
      radius: Radius.circular(20),
      child: Container(
        width: width * 0.25,
        height: width * 0.25,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget DropDownWidget(String text, List<String> options, String hintText,
      var width, var height, index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: width * 0.4,
            height: height * 0.05,
            child: Center(
              child: Text(text,
                  style: TextStyle(
                    fontFamily: 'Muli',
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  )),
            )),
        Container(
          width: width * 0.5,
          height: height * 0.1,
          child: DropdownButton<String>(
            focusColor: Color(0xff99ffff),
            value: chosenValue[index],
            //elevation: 5,
            style: TextStyle(fontFamily: 'Muli', color: Colors.white),
            iconEnabledColor: Colors.black,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
              );
            }).toList(),
            hint: Text(
              hintText,
              style: TextStyle(
                  fontFamily: 'Muli',
                  color: Color(0xff999999),
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
            onChanged: (String value) {
              setState(() {
                chosenValue[index] = value;
                optionSelected = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget TextInputWidget(String text, String hintText, var width, var height,
      TextEditingController controller, bool autocomplete, int maxlength) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: width * 0.4,
          height: height * 0.08,
          child: Center(
            child: Text(text,
                style: TextStyle(
                  fontFamily: 'Muli',
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                )),
          ),
        ),
        Container(
          width: width * 0.5,
          height: height * 0.08,
          color: Colors.white,
          child: autocomplete
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                      onTap: _handlePressButton,
                      child: locationController.text.length == 0
                          ? Text(hintText,
                              style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ))
                          : Text(locationController.text,
                              style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ))),
                )
              : TextField(
                  style: TextStyle(
                      fontFamily: 'Muli',
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                  controller: controller,
                  cursorColor: Colors.black,
                  cursorHeight: 25,
                  cursorWidth: 0.5,
                  maxLength: maxlength,
                  onSubmitted: (String) {
                    setState(() {
                      controller.text = controller.text;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: hintText,
                      // contentPadding: EdgeInsets.only(bottom: 20),
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          fontFamily: 'Muli',
                          color: Color(0xff999999),
                          fontSize: 18,
                          fontWeight: FontWeight.w400)),
                ),
        )
      ],
    );
  }

  Widget UploadedImageWidget(int index, String image, var height) {
    return Stack(children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: widget.variables.cachedImages[image] != null
                    ? widget.variables.cachedImages[image].image
                    : NetworkImage(image),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(20)),
      ),
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black87, Colors.black54, Colors.transparent],
                stops: [0.0, 0.2, 0.3],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(20)),
      ),
    ]);
  }

  Widget PictureWidget(int index, String image, var height) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: FileImage(File(image)), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(20)),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black87, Colors.black54, Colors.transparent],
                  stops: [0.0, 0.2, 0.3],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(20)),
        ),
        index == picIndex - 1
            ? IconButton(
                onPressed: () {
                  setState(() {
                    imageFiles.removeAt(index);
                    /* listingPictures[index] = EmptyWidget();
                    listings.removeAt(index);
                    listings.add(EmptyWidget()); */
                    picIndex = picIndex - 1;
                    if (imageFiles.length < 2) {
                      emptyWidgets.add(Center());
                    }
                  });
                },
                icon: Icon(
                  Icons.cancel_outlined,
                  color: Colors.white,
                ))
            : IconButton(
                icon: Center(),
              )
      ],
    );
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
        'You have already chosen that picture.',
        style: TextStyle(fontFamily: 'Muli', color: Color(0xff00ffff)),
      )),
    )..show(context);
  }

  Widget EmptyWidget() {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 0.5)),
        ),
      ],
    );
  }

  Widget AddPicture(var height) {
    return GestureDetector(
        onTap: () async {
          var image = await ImagePicker.pickImage(source: ImageSource.gallery);
          if (imageFiles.contains(image.path)) {
            showFloatingFlushbar(context);
          } else {
            setState(() {
              /* listingPictures[picIndex] = PictureWidget(picIndex, image, height);
            listings.removeAt(picIndex);
            listings.insert(picIndex, (PictureWidget(picIndex, image, height))); */
              imageFiles.add(image.path);
              picIndex = picIndex + 1;
              if (emptyWidgets.length != 0) {
                emptyWidgets.removeAt(0);
              }
            });
          }
        },
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Color(0xffd1d1d1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.add,
            size: 20,
            color: Colors.white,
          ),
        ));
  }

  Widget _buildDropdownMenu() => DropdownButton(
        value: _mode,
        items: <DropdownMenuItem<Mode>>[
          DropdownMenuItem<Mode>(
            child: Text("Overlay"),
            value: Mode.overlay,
          ),
          DropdownMenuItem<Mode>(
            child: Text("Fullscreen"),
            value: Mode.fullscreen,
          ),
        ],
        onChanged: (m) {
          setState(() {
            _mode = m;
          });
        },
      );

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode,
      language: "en",

      /* decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ), */
      components: [Component(Component.country, "et")],
    );

    displayPrediction(p, homeScaffoldKey.currentState);
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      setState(() {
        common_location = p.description;
        locationController.text = p.description;
      });

      /* scaffold.showSnackBar(
        SnackBar(content: Text("${p.description} - $lat/$lng")),
      ); */
    }
  }
}
