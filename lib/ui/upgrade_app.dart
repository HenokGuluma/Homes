import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/ui/profile_picture_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';

class UpgradeApp extends StatefulWidget {
  

  @override
  _UpgradeAppState createState() => _UpgradeAppState();
}

class _UpgradeAppState extends State<UpgradeApp> {


  @override
  void initState() {
    super.initState();
   
  }
 
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        width: size.width,
        height: size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             SvgPicture.asset('assets/homes.svg', color: Colors.black, width: 60, height: 60,),
              SizedBox(height: 20,),
              Text('Your app is out of date. Upgrade the app to the latest version', style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 18, fontWeight: FontWeight.normal),
        )
            ],
          )
        ),
      )   );
  }

}
