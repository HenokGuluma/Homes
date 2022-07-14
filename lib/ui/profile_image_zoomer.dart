import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
//import 'package:image_cropper/image_cropper.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/edit_profile_screen.dart';
import 'package:instagram_clone/ui/insta_upload_photo_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:instagram_clone/models/user.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
  Uint8List imageFile;
  bool profileSetup;
  double aspectRatio;
  Uint8List thumnailFile;
  bool original;
  DocumentReference reference;
  User currentUser;
  Profile(
      {this.imageFile,
      this.profileSetup,
      this.original,
      this.reference,
      this.aspectRatio,
      this.thumnailFile,
      this.currentUser});
}

class ProfileState extends State<Profile> {
  File imageFile;
  bool buttonActive = false;
  var _repository = Repository();
  StorageReference _storageReference;
  bool updating = false;

  @override
  void dispose() {
    super.dispose();
  }

  /// Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          brightness: Brightness.dark,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Color(0xff00ffff),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SelectableText(
                "Image Preview",
                style: TextStyle(fontFamily: 'Muli', color: Colors.black),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: updating
                      ? SelectableText(
                          "Updating",
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black38,
                              fontSize: 17),
                        )
                      : widget.profileSetup
                          ? MaterialButton(
                              onPressed: () {},
                              child: SelectableText(
                                'Next',
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 17),
                              ),
                            )
                          : MaterialButton(
                              child: SelectableText(
                                "Update",
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.black,
                                    fontSize: 17),
                              ),
                              onPressed: widget.imageFile == null
                                  ? () {}
                                  : () {
                                      setState(() {
                                        updating = true;
                                      });
                                      print("The file is ${imageFile}");
                                      compressImage().then((compressedImage) {
                                        uploadImagesToStorage(compressedImage)
                                            .then((url) {
                                          _repository
                                              .updatePhoto(
                                                  url, widget.currentUser.uid)
                                              .then((v) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Profile Image successfully updated',
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor:
                                                    Color(0xff00ffff),
                                                textColor: Colors.black);
                                            Navigator.pop(context);
                                          });
                                        });
                                      });
                                    }))
            ],
          ),
        ),
        body: Container(
            child: widget.imageFile == null
                ? Center()
                : Center(
                    child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Image.memory(widget.imageFile, fit: BoxFit.fitHeight
                        //BoxFit.cover
                        ),
                  ))));
  }

  /// Get from gallery
  _getFromGallery() async {
    var pickedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      //maxWidth: 1800,
      //maxHeight: 1800,
    );
    //_cropImage(pickedFile.path);
  }

  /// Crop Image
  /*_cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      toolbarColor: Color(0xff00ffff),
      toolbarTitle:"Customize photo",
    );
    if (croppedImage != null) {
      setState(() {
        imageFile = croppedImage;
        buttonActive = true;
      });
    }
  }*/
  Future<String> uploadImagesToStorage(Uint8List imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putData(imageFile);
    /*storageUploadTask.events.listen((event) {
      setState(() {
        _progress= event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });*/
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<Uint8List> compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    //Im.copyResizeCropSquare(image, 500);
    var result = await FlutterImageCompress.compressWithList(
      widget.imageFile,
      quality: 25,
    );
    print('done');
    return result;
  }
}
