import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_home_screen.dart';
import 'package:instagram_clone/models/post.dart';
//import 'package:location/location.dart';
import 'package:flutter/services.dart';
//import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InstaUploadPhotoScreen extends StatefulWidget {
  Uint8List thumbnailFile;
  Uint8List imageFile;
  img.Image image;
  File image_file;
  double aspectRatio;
  DocumentReference reference;
  bool original;
  InstaUploadPhotoScreen(
      {this.thumbnailFile,
      this.imageFile,
      this.image_file,
      this.image,
      this.original,
      this.reference,
      this.aspectRatio});

  @override
  _InstaUploadPhotoScreenState createState() => _InstaUploadPhotoScreenState();
}

class _InstaUploadPhotoScreenState extends State<InstaUploadPhotoScreen> {
  var _locationController;
  var _captionController;
  final _repository = Repository();
  int initial = 20;
  double _progress = 0;
  StorageReference _storageReference;
  bool uploading = false;
  Post post;
  bool posted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationController = TextEditingController();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _locationController?.dispose();
    _captionController?.dispose();
  }

  bool _visibility = true;

  void _changeVisibility(bool visibility) {
    setState(() {
      _visibility = visibility;
    });
  }

  Future<String> uploadImagesToStorage(Uint8List imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putData(imageFile);
    storageUploadTask.events.listen((event) {
      setState(() {
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    storageUploadTask.events.listen((event) {
      setState(() {
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<String> uploadThumbnailToStorage(Uint8List imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putData(imageFile);
    /* storageUploadTask.events.listen((event) {
      setState(() {
        _progress= event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });*/
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        brightness: Brightness.dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'New Post',
          style:
              TextStyle(fontFamily: 'Muli', color: Colors.white, fontSize: 16),
        ),
        backgroundColor: new Color(0xff1a1a1a),
        toolbarHeight: 40.0,
        elevation: 1.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 7.0, bottom: 7.0),
            child: posted
                ? Container(
                    width: 60.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                        color: Color(0xff009999),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Color(0xff009999))),
                    child: Center(
                      child: Text('Share',
                          style: TextStyle(
                              fontFamily: 'Muli',
                              color: Colors.black,
                              fontSize: 16)),
                    ),
                  )
                : GestureDetector(
                    child: Container(
                      width: 60.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          color: Color(0xff00ffff),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Color(0xff00ffff))),
                      child: Center(
                        child: Text('Share',
                            style: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.black,
                                fontSize: 16)),
                      ),
                    ),
                    onTap: () {
                      // To show the CircularProgressIndicator
                      _changeVisibility(false);
                      setState(() {
                        uploading = true;
                        posted = true;
                      });

                      _repository.getCurrentUser().then((currentUser) {
                        if (currentUser != null) {
                          compressImage().then((images) {
                            _repository
                                .retrieveUserDetails(currentUser)
                                .then((user) {
                              //uploadImagesToStorage(widget.imageFile)
                              uploadThumbnailToStorage(widget.thumbnailFile)
                                  .then((thumbnailUrl) {
                                uploadImagesToStorage(images).then((url) {
                                  print('the original value is ');
                                  print(widget.original);
                                  if (!widget.original) {
                                    widget.reference.get().then((doc) {
                                      double bonus = doc['trending'] * 0.2;
                                      _repository
                                          .addPictureTrendPostToDb(
                                              user,
                                              url,
                                              thumbnailUrl,
                                              doc['postOwnerName'],
                                              _captionController.text,
                                              _locationController.text,
                                              initial + bonus.toInt(),
                                              widget.reference,
                                              widget.aspectRatio)
                                          .then((ref) {
                                        print("Post added to db");
                                        _repository.followPictureTrend(
                                            user, widget.reference, ref);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  InstaHomeScreen())),
                                          (Route<dynamic> route) => false,
                                        );
                                      });

                                      //.catchError((e) =>
                                      //print("Error adding current post to db : $e"));
                                    });
                                  } else {
                                    _repository
                                        .addPicturePostToDb(
                                            user,
                                            url,
                                            thumbnailUrl,
                                            _captionController.text,
                                            _locationController.text,
                                            initial,
                                            widget.aspectRatio)
                                        .then((value) {
                                      print("Post added to db");
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                InstaHomeScreen())),
                                        (Route<dynamic> route) => false,
                                      );
                                    });
                                  }
                                }).catchError((e) {
                                  print(
                                      "Error uploading image to storage : $e");
                                });
                              });
                            });
                          });
                        } else {
                          print("Current User is null");
                        }
                      });
                    },
                  ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(widget.thumbnailFile))),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: TextField(
                    controller: _captionController,
                    style: TextStyle(fontFamily: 'Muli', color: Colors.white),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    keyboardAppearance: Brightness.light,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      hintStyle:
                          TextStyle(fontFamily: 'Muli', color: Colors.white),
                    ),
                    /*onChanged: ((value) {
                      _captionController.value = TextEditingValue(
                        text: value,
                        selection: TextSelection.collapsed(offset: value.length),
                      );
                    }),*/
                  ),
                ),
              )
            ],
          ),
          uploading == true
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text(
                        'Uploading ${(_progress * 100).toStringAsFixed(2)} %',
                        style: TextStyle(
                            fontFamily: 'Muli',
                            color: Colors.white,
                            fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: LinearProgressIndicator(
                        value: _progress,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xff00ffff)),
                        backgroundColor: Colors.white24,
                      ),
                    )
                  ],
                )
              : Center()
        ],
      ),
    );
  }

  Future<void> compressFile() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(widget.imageFile);
    //Im.copyResizeCropSquare(image, 500);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 25));

    setState(() {
      widget.image_file = newim2;
    });
    print('done');
  }

  Future<Uint8List> compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(widget.imageFile);
    //Im.copyResizeCropSquare(image, 500);
    var result = await FlutterImageCompress.compressWithList(
      widget.imageFile,
      quality: 25,
    );

    /*var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 20));*/
    print('done');
    return result;
  }

  /*Future<List<Address>> locateUser() async {
    LocationData currentLocation;
    Future<List<Address>> addresses;

    var location = new Location();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();

      print(
          'LATITUDE : ${currentLocation.latitude} && LONGITUDE : ${currentLocation.longitude}');

      // From coordinates
      final coordinates =
          new Coordinates(currentLocation.latitude, currentLocation.longitude);

      addresses = Geocoder.local.findAddressesFromCoordinates(coordinates);
    } on PlatformException catch (e) {
      print('ERROR : $e');
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
      currentLocation = null;
    }
    return addresses;
  }*/
}
