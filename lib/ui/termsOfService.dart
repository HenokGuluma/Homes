import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

class TermsOfService extends StatefulWidget {
  final String userId;
  final String emailAddress;
  final String name;

  TermsOfService({this.userId, this.emailAddress, this.name});

  @override
  _TermsOfServiceState createState() => _TermsOfServiceState();
}

class _TermsOfServiceState extends State<TermsOfService> {
  var _repository = Repository();
  auth.User currentUser;
  User currentuser;
  TextEditingController _nameController;
  final _bioController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  StorageReference _storageReference;
  bool checkingUsername = false;
  bool usernameExists = false;
  bool usernameChecked = false;
  bool usernameTooShort = false;
  bool finishingUp = false;
  bool loadingPhones = true;
  List<String> phoneList = [];
  String terms = '';

  @override
  void initState() {
    readFilesFromAssets();
    super.initState();
    _nameController = TextEditingController(text: 'Name');
    if (widget.emailAddress != null) {
      _emailController.text = widget.emailAddress;
    }
    if (widget.name != null) {
      _nameController.text = widget.name;
    }
    getPhones();
  }

  File imageFile;

  readFilesFromAssets() async {
  String assetContent = await rootBundle.loadString('assets/terms.txt');
  setState(() {
      terms = assetContent;
    });
}

  Future<File> _pickImage(String action) async {
    File selectedImage;

    action == 'Gallery'
        ? selectedImage =
            await ImagePicker.pickImage(source: ImageSource.gallery)
        : await ImagePicker.pickImage(source: ImageSource.camera);

    return selectedImage;
  }

  Future<void> getPhones (){
    _repository.getAllPhones().then((phoneNumbers) {
      List<String> phones = [];
      for(int i=0; i<phoneNumbers.length; i++){
        String phone = phoneNumbers[i].id;
        phones.add(phone);
      }
      setState(() {
              phoneList = phones;
              loadingPhones = false;
            });
    });
    return null;
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: new Color(0xff1a1a1a),
        toolbarHeight: 40.0,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Terms of Service',
          style: TextStyle(fontFamily: 'Muli', color: Colors.white),
        ),
       
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        width: size.width,
        child: Center(
          child: Column(
            children: [
              Text('Our Terms...', style: TextStyle(color: Color(0xff444444), fontFamily: 'Muli', fontSize: 22, fontWeight: FontWeight.w900),
 ),
              SizedBox(height: 20,),
              Expanded(
            flex: 1,
            child: new SingleChildScrollView(
              scrollDirection: Axis.vertical,//.horizontal
              child: Text(terms, style: TextStyle(color: Colors.black, fontFamily: 'Muli', fontSize: 18, fontWeight: FontWeight.normal),
        ))),
            ],
          )
        ),
      )   );
  }

  changeText(String text) {
    setState(() {});
    print(phoneList);
  }

  changeUserName(String text) {
    if (text.length < 6 && text.length > 0) {
      setState(() {
        usernameTooShort = true;
      });
    } else if (text.length == 0) {
      setState(() {
        checkingUsername = false;
        usernameExists = false;
        usernameChecked = false;
        usernameTooShort = false;
      });
    } else {}
  }

  checkUserName(String text) async {}

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
        'You have successfully updated your profile.',
        style: TextStyle(fontFamily: 'Muli', color: Color(0xfff2029e)),
      )),
    )..show(context);
  }

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

  /*void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    Im.copyResizeCropSquare(image, 500);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = newim2;
    });
    print('done');
  }*/
  Future<Uint8List> compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Random().nextInt(10000);

    //Im.copyResizeCropSquare(image, 500);
    var result = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 25,
    );
    print('done');
    return result;
  }
}
