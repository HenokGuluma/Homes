import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
//import 'package:image_cropper/image_cropper.dart';
import 'package:instagram_clone/ui/insta_upload_photo_screen.dart';

class ImageZoomer extends StatefulWidget {
  @override
  ImageZoomerState createState() => ImageZoomerState();
  File imageFile;
  double aspectRatio;
  Uint8List thumnailFile;
  bool original;
  DocumentReference reference;
  ImageZoomer(
      {this.imageFile,
      this.original,
      this.reference,
      this.aspectRatio,
      this.thumnailFile});
}

class ImageZoomerState extends State<ImageZoomer> {
  File imageFile;
  bool buttonActive = false;

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
                  child: MaterialButton(
                      child: SelectableText(
                        "Next",
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.black,
                            fontSize: 17),
                      ),
                      onPressed: widget.imageFile == null
                          ? () {}
                          : () {
                              print("The file is ${imageFile}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          InstaUploadPhotoScreen(
                                            thumbnailFile: widget.thumnailFile,
                                            imageFile: widget.imageFile
                                                .readAsBytesSync(),
                                            original: widget.original,
                                            reference: widget.reference,
                                            aspectRatio: widget.aspectRatio,
                                          ))));
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
                    child: Image.file(widget.imageFile, fit: BoxFit.fitHeight
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
}
