import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/listing_details.dart';
import 'package:instagram_clone/ui/profile_picture_manager.dart';
import 'package:instagram_clone/ui/unlock_details.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';

class ViewListings extends StatefulWidget {
  UserVariables variables;
  ViewListings({this.variables});

  @override
  ViewListingsState createState() => ViewListingsState();
}

class ViewListingsState extends State<ViewListings> {
  var _repository = Repository();
  User currentuser;
  TextEditingController _nameController;
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  StorageReference _storageReference;
  List<DocumentSnapshot> ownListings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    currentuser = widget.variables.currentUser;
    getOwnListings();
  }

  Future cacheImage(BuildContext context, String urlImage) {
    Image image = Image(
      image: CachedNetworkImageProvider(urlImage),
      fit: BoxFit.cover,
    );
    widget.variables.cachedImages.putIfAbsent(urlImage, () => image);
    precacheImage(image.image, context);

    return null;
  }

  getOwnListings() async {
    _repository.getOwnListings(currentuser.uid).then((listings) {
      setState(() {
        ownListings = listings;
        loading = false;
      });
      for (int i = 0; i < listings.length; i++) {
        List<dynamic> imageList = listings[i].data()['images'];
        imageList.map((image) {
          if (!widget.variables.cachedImages.containsKey(image)) {
            cacheImage(context, image);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          toolbarHeight: height * 0.08,
          elevation: 1,
          title: Text(
            'View Listings',
            style: TextStyle(fontFamily: 'Muli', color: Colors.white),
          ),
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, color: Colors.white),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
            color: Color(0xff00ffff),
            backgroundColor: Colors.black,
            strokeWidth: 2,
            onRefresh: () {
              getOwnListings();
              return Future.delayed(Duration(seconds: 2));
            },
            child: Center(
                child: !loading
                    ? (ownListings.length == 0)
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
                                'Add your listings by going back and clicking the + button.',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        : Container(
                            height: height * 0.85,
                            child: Padding(
                              padding: EdgeInsets.only(top: 0, bottom: 0),
                              child: GridView.builder(
                                  itemCount: ownListings.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.9),
                                  cacheExtent: 5000000,

                                  // ignore: missing_return
                                  itemBuilder: ((context, index) {
                                    return listingWidget(
                                      list: ownListings,
                                      index: index,
                                      width: width,
                                      height: height,
                                    );
                                  })),
                            ))
                    : Center(
                        child: JumpingDotsProgressIndicator(
                        fontSize: 50.0,
                        color: Colors.black,
                      )))));
  }

  Widget listingWidget(
      {var height, var width, int index, List<DocumentSnapshot> list}) {
    return GestureDetector(
      child: Padding(
          padding: EdgeInsets.only(
            top: 10,
          ),
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
                          image: widget.variables.cachedImages[
                                      list[index].data()['images'][0]] !=
                                  null
                              ? widget
                                  .variables
                                  .cachedImages[list[index].data()['images'][0]]
                                  .image
                              : CachedNetworkImageProvider(
                                  list[index].data()['images'][0]),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(20)),
                ),
                description(width, height, list[index])
              ],
            ),
          )),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => UnlockDetails(
                    modify: true,
                    notUnlock: true,
                    variables: widget.variables,
                    index: 0,
                    item: list[index],
                    images: list[index].data()['images']))));
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
