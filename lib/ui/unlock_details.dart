import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/buy_keys.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/modify_listing.dart';
import 'package:provider/provider.dart';

class UnlockDetails extends StatefulWidget {
  final DocumentSnapshot item;
  final UserVariables variables;
  int index;
  List<String> imageFiles;
  List<dynamic> images;
  bool notUnlock;
  bool modify;

  UnlockDetails({
    this.notUnlock,
    this.item,
    this.variables,
    this.index,
    this.imageFiles,
    this.images,
    this.modify,
  });

  @override
  UnlockDetailsState createState() => UnlockDetailsState();
}

class UnlockDetailsState extends State<UnlockDetails> {
  File _image;
  File imageFile;
  final picker = ImagePicker();
  bool like;
  int counter = 0;
  String trialMessage = 'Unlocking an item normally costs 40 birr. But you are given a limited free access. Would you like to unlock this listing?';
  String nonTrialMessage = 'Unlocking an item costs 40 birr or one key. Would you like to use your key to unlock this item?';
  List<Map<String, int>> options = [
    {'amount': 1, 'price': 25},
    {'amount': 3, 'price': 50},
    {'amount': 5, 'price': 75},
    {'amount': 10, 'price': 100}
  ];

  bool unlocked = false;

  List<bool> balls = [true, true, true, true, true];
  var _repository = Repository();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int numberOfKeys = 0;

  @override
  void initState() {
    super.initState();
    print(widget.variables.trial); print (' is the trial');
    print(widget.variables.currentUser.keys);
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
            'Listing Details',
            style: TextStyle(
                fontFamily: 'Muli',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
                children: [
                  /* SizedBox(
                    height: height * 0.05,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      'After unlocking this item you are left with ' +
                          (widget.variables.keys - 1).toString() +
                          ' keys. Are you sure you want to unlock this listing?',
                      style: TextStyle( fontFamily: 'Muli', color: Colors.black, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ), */
                  listing(width, height),
                ],
              ));
  }

  unlockItem(){

    print(' the difference is ');
    print(DateTime.now().millisecondsSinceEpoch - widget.variables.currentUser.recentActivity);
    print(widget.variables.trial);
    print(widget.variables.currentUser.posts);

    if(widget.variables.trial && widget.variables.currentUser.posts>1 && (DateTime.now().millisecondsSinceEpoch - widget.variables.currentUser.recentActivity)>86400000){
        _firestore.collection('users').doc(widget.variables.currentUser.uid).update({'recentActivity': DateTime.now().millisecondsSinceEpoch, 'posts': 1});
      
       widget.variables
          .unlockListing(widget.item.id);
      _repository.unlockListing(

          widget.item.id,
          widget.variables.currentUser.uid);

      print('trial unlock');

       User user = widget.variables.currentUser;
        
        user.recentActivity = DateTime.now().millisecondsSinceEpoch;
        user.posts = 1;

        widget.variables.setCurrentUser(user);

      
        setState(() {
        unlocked = true;
      });
      showUnlockedFlushbar(context);
    }
    else if(widget.variables.trial && widget.variables.keys<1){
       widget.variables
          .unlockListing(widget.item.id);
      _repository.unlockListing(

          widget.item.id,
          widget.variables.currentUser.uid);

      print('trial unlock');

       User user = widget.variables.currentUser;
        
        user.posts = user.posts+1;

        widget.variables.setCurrentUser(user);

      
        setState(() {
        unlocked = true;
      });
      showUnlockedFlushbar(context);
    }
    else{
      _firestore.collection('users').doc(widget.variables.currentUser.uid).update({'keys': widget.variables.currentUser.keys -1}).then((value) {
         widget.variables
          .unlockListing(widget.item.id);
      _repository.unlockListing(
          widget.item.id,
          widget.variables.currentUser.uid);
        User user = widget.variables.currentUser;
        
        user.keys = user.keys-1;
        user.posts = user.posts+1;
        widget.variables.setCurrentUser(user);
        setState(() {
        unlocked = true;
      });
      });
      showUnlockedFlushbar(context);
    }
   
     
      return print('pressedOK');
  }

  Widget imageWidget(var width, var height) {
    return Container(
        child: Stack(alignment: Alignment.bottomCenter, children: [
      CarouselSlider(
        options: CarouselOptions(
            initialPage: widget.index,
            height: width * 0.7,
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
                                  widget.variables.cachedImages[item] != null
                                      ? widget
                                          .variables.cachedImages[item].image
                                      : CachedNetworkImageProvider(item),
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
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index1 == counter ? Colors.white : Colors.grey,
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
    ]));
  }

  Widget listing(var width, var height) {
    List images = widget.item.data()['images'];
    var image = images[0];
    return Container(
        width: width,
        height: height * 0.85,
        child: Stack(children: [
          ListView(children: [
            /* Container(
              height: width * 0.7,
              width: width * 0.9,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image:AdvancedNetworkImage(image), fit: BoxFit.cover),
              ),
            ), */
            imageWidget(width, height),
            SizedBox(
              height: height * 0.01,
            ),
            listingDescription(width, height, widget.item),
            SizedBox(
              height: height * 0.03,
            ),
            unlocked ||
                    widget.notUnlock ||
                    widget.variables.unlockedListings
                        .contains(widget.item.id) ||
                    widget.item.data()['userID'] ==
                        widget.variables.currentUser.uid ||
                    widget.item.data()['forRent'] == 'For Sale'
                ? extraDescription(width, height, widget.item)
                : widget.notUnlock
                    ? Center()
                    : MaterialButton(
                        onPressed: () async {
                         if(!widget.variables.trial && widget.variables.currentUser.keys <1){
                                          showCannotUnlockFlushbar(context);
                                        }
                          else if(widget.variables.trial && widget.variables.currentUser.keys <1 && widget.variables.currentUser.posts>1 && (DateTime.now().millisecondsSinceEpoch - widget.variables.currentUser.recentActivity)<86400000){
                                          showTrialCannotUnlockFlushbar(context);
                                        }
                          else{
                            showDialog(
                              context: context,
                              builder: ((context) {
                                return new AlertDialog(
                                  title: new Text(
                                    'Unlocking item',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Muli',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: new Text(
                                    widget.variables.trial
                                    ?trialMessage
                                    :nonTrialMessage,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Muli',
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  actions: <Widget>[
                                    new TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }, // Closes the dialog
                                      child: new Text(
                                        'No',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Muli',
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                    new TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        
                                           unlockItem();
                                        
                                        // Closes the dialog
                                      },
                                      child: new Text(
                                        'Yes',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Muli',
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ],
                                );
                              }));
                        
                          }
                          },
                        child: Container(
                          width: width * 0.5,
                          height: height * 0.07,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: width * 0.05,
                                ),
                                Icon(
                                  Icons.lock_open_outlined,
                                  color: Colors.yellow,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: width * 0.02,
                                ),
                                Text(
                                  'Unlock Extras',
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Color(0xff00ffff),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900),
                                ),
                              ]),
                        ),
                      ),
            
            !widget.notUnlock && !widget.modify  && !widget.variables.unlockedListings
                        .contains(widget.item.id) &&  widget.item.data()['userID'] !=
                        widget.variables.currentUser.uid &&
                    widget.item.data()['forRent'] != 'For Sale'
            ?Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/key_fill.svg', color: Colors.black, width: 15, height: 15,),
                  SizedBox(width: 5,),
                  Text(
                                  'Wallet: '+ widget.variables.currentUser.keys.toString(),
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900),
                                ),
                    ],
                  ),
                  MaterialButton(
                    onPressed: (){
                      Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => BuyKeys(variables: widget.variables))));
                  },
                  child: Container(
                    width: width*0.25,
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),

                    ),
                    child: Center(
                      child: Text(
                                  'Buy Keys',
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900),
                                ),
                    ),
                  ),
                  )
                ],
              )
            )
            :Center(),
            widget.notUnlock && widget.modify
                ? Container(
                    width: width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => ModifyListing(
                                        details: widget.item,
                                        variables: widget.variables))));
                          },
                          child: Container(
                            width: width * 0.45,
                            height: height * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width * 0.05,
                                  ),
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: width * 0.02,
                                  ),
                                  Text(
                                    'Modify Listing',
                                    style: TextStyle(
                                        fontFamily: 'Muli',
                                        color: Color(0xff00ffff),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: ((context) {
                                  return new AlertDialog(
                                    title: new Text(
                                      'Deleting item',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Muli',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: new Text(
                                      'Are you sure you want to delete this listing?',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Muli',
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    actions: <Widget>[
                                      new TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }, // Closes the dialog
                                        child: new Text(
                                          'No',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      new TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            unlocked = true;
                                          });
                                          _repository.deleteListing(
                                              widget.item.data()['userID'],
                                              widget.item.id);
                                          Navigator.pop(context);
                                          showFloatingFlushbar(context);

                                          return print('pressedOK');
                                          // Closes the dialog
                                        },
                                        child: new Text(
                                          'Yes',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                    ],
                                  );
                                }));
                          },
                          child: Container(
                            width: width * 0.45,
                            height: height * 0.07,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width * 0.05,
                                  ),
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: width * 0.02,
                                  ),
                                  Text(
                                    'Delete Listing',
                                    style: TextStyle(
                                        fontFamily: 'Muli',
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ]),
                          ),
                        )
                      ],
                    ))
                : Center()
          ]),
          /*   Container(
            height: width * 0.7,
            width: width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.05),
              gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.white70, Colors.white],
                  stops: [0.8, 0.9, 0.95],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
          ), */
        ]));
  }

  void showFloatingFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
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
        'You have successfully deleted this listing.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.white),
      )),
    )..show(context);
  }

  void showCannotUnlockFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
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
        'You do not have any keys in your wallet to unlock this item.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.white),
      )),
    )..show(context);
  }

   void showTrialCannotUnlockFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
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
        'You do not have any keys in your wallet and you have already used your two daily free keys.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.white),
        textAlign: TextAlign.center
      )),
    )..show(context);
  }

   void showUnlockedFlushbar(BuildContext context) {
    Flushbar(
      padding: EdgeInsets.all(10),
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
        'You have successfully unlocked this item.',
        style: TextStyle(fontFamily: 'Muli', color: Colors.white),
      )),
    )..show(context);
  }

  Widget UnlockOptions(int amount, int price, var width) {
    return GestureDetector(
        onTap: () {
          print('The option that you chose is ' + price.toString());
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: width * 0.3,
            height: width * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SvgPicture.asset("assets/key.svg",
                      width: 20, height: 20, color: Colors.yellow),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    amount != 1
                        ? amount.toString() + ' keys'
                        : amount.toString() + ' key',
                    style: TextStyle(
                        fontFamily: 'Muli',
                        color: Color(0xff00ffff),
                        fontSize: 20),
                  ),
                ]),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'for ' + price.toString() + ' birr',
                  style: TextStyle(
                      fontFamily: 'Muli', color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ));
  }

  Widget listingDescription(var width, var height, DocumentSnapshot item) {
    return Container(
        padding: EdgeInsets.only(left: 20),
        width: width,
        child: Container(
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
                item.data()['userID'] == widget.variables.currentUser.uid
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
                  child: item.data()['listingDescription'] != null &&
                          item.data()['listingType'] == 'Other'
                      ? item.data()['listingDescription'].isNotEmpty
                          ? Text(
                              item.data()['listingDescription'] +
                                  ' - ' +
                                  item.data()['area'] +
                                  ' sq.m',
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Color(0xff444444),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900),
                              overflow: TextOverflow.clip,
                            )
                          : Center()
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
                      width: width * 0.75,
                      child: Text(
                        item.data()['commonLocation'],
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Color(0xff444444),
                            fontSize: 17,
                            fontWeight: FontWeight.w400),
                        overflow: TextOverflow.clip,
                      )),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              item.data()['additionalNotes'].toString().isNotEmpty
                  ? RichText(
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
                                fontWeight: FontWeight.w900),
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
          width: width * 0.9,
        ));
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

  Widget extraDescription(var width, var height, DocumentSnapshot item) {
    return Container(
      padding: EdgeInsets.only(left: 20),
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
          item.data()['forRent'] == 'For Sale'
              ? Center()
              : Row(
                  children: [
                    Text('Owner Name:',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                    SizedBox(
                      width: 5,
                    ),
                    SelectableText(item.data()['listingOwnerName'],
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
          item.data()['forRent'] == 'For Sale'
              ? Center()
              : Row(
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
                    SelectableText(item.data()['preciseLocation'],
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400))
                  ],
                ),
          item.data()['forRent'] == 'For Sale'
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
              item.data()['forRent'] == 'For Sale'
                  ? SelectableText(
                      '0923577987',
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    )
                  : SelectableText(
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
          item.data()['emailAddress'].isEmpty ||
                  item.data()['forRent'] == 'For Sale'
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
                    SelectableText(item.data()['emailAddress'],
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
}
