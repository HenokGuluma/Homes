import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as Im;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/resources/repository.dart';
import 'package:instagram_clone/ui/insta_profile_screen.dart';
//import 'package:instagram_clone/ui/post_detail_screen.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatDetailScreen extends StatefulWidget {
  final String photoUrl;
  final String name;
  final String receiverUid;

  ChatDetailScreen({this.photoUrl, this.name, this.receiverUid});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  var _formKey = GlobalKey<FormState>();
  String _senderuid;
  TextEditingController _messageController = TextEditingController();
  final _repository = Repository();
  String receiverPhotoUrl, senderPhotoUrl, receiverName, senderName;
  StreamSubscription<DocumentSnapshot> subscription;
  File imageFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _messages = [];
  Map<String, DocumentSnapshot> _cacheMap = Map();

  @override
  void initState() {
    super.initState();
    print("RCID : ${widget.receiverUid}");
    _repository.getCurrentUser().then((user) {
      setState(() {
        _senderuid = user.uid;
      });
      _repository.fetchUserDetailsById(_senderuid).then((user) {
        setState(() {
          senderPhotoUrl = user.photoUrl;
          senderName = user.displayName;
        });
      });
      _repository.fetchUserDetailsById(widget.receiverUid).then((user) {
        setState(() {
          receiverPhotoUrl = user.photoUrl;
          receiverName = user.displayName;
        });
      });
      //getMessages();
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  void getMessages() async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .doc(_senderuid)
        .collection("messages")
        .doc(widget.receiverUid)
        .collection("messages")
        .orderBy('timestamp', descending: false)
        .get();
    print(snapshot.docs.length);
    print(' is the amount of messages');
    for (var i = 0; i < snapshot.docs.length; i++) {
      _messages.add(snapshot.docs[i]);
      print('whasaaaaa');
      /*if(snapshot.docs[i].data()['type'] =='post'){
        DocumentReference ref =snapshot.docs[i].data()['reference'];
        ref.get().then((value) => {
          _cacheMap.putIfAbsent(snapshot.docs[i].id, () => value)
        });
      }*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
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
          backgroundColor: new Color(0xff1a1a1a),
          elevation: 1,
          toolbarHeight: 40.0,
          title: GestureDetector(
            child: Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xff00ffff)),
                    image: DecorationImage(
                      image: ProgressiveImage(
                        placeholder: AssetImage('assets/no_image.png'),
                        // size: 1.87KB
                        //thumbnail:NetworkImage(list[index].data()['postOwnerPhotoUrl']),
                        thumbnail: AssetImage('assets/grey.png'),
                        // size: 1.29MB
                        image: NetworkImage(widget.photoUrl),
                        fit: BoxFit.cover,
                        width: 30,
                        height: 30,
                      ).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: 30,
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                        fontFamily: 'Muli', color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: _senderuid == null
              ? Container(
                  child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Color(0xff00ffff))),
                )
              : Column(
                  children: <Widget>[
                    ChatMessagesListWidget(),
                    //ChatMessages(),
                    chatInputWidget(),
                    SizedBox(
                      height: 20.0,
                    )
                  ],
                ),
        ));
  }

  Widget chatInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        style: TextStyle(fontFamily: 'Muli', color: Colors.white),
        validator: (String input) {
          if (input.isEmpty) {
            return "Please enter message";
          }
        },
        controller: _messageController,
        decoration: InputDecoration(
            hintText: "Enter message...",
            hintStyle: TextStyle(fontFamily: 'Muli', color: Colors.grey),
            //labelText: "Message", labelStyle: TextStyle( fontFamily: 'Muli', color: Colors.white),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                /*Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.image),
                    color: Colors.white,
                    onPressed: () {
                      pickImage(source: 'Gallery');
                    },
                  ),
                ),*/
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    child: SvgPicture.asset(
                      "assets/send.svg",
                      color: Color(0xff00ffff),
                      width: 20,
                      height: 20,
                    ),
                    onTap: () {
                      if (_formKey.currentState.validate()) {
                        sendMessage();
                      }
                    },
                  ),
                ),
              ],
            ),
            /*prefixIcon: IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                pickImage(source: 'Camera');
              },
              color: Colors.white,
            ),*/
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(40.0))),
        onFieldSubmitted: (value) {
          _messageController.text = value;
        },
      ),
    );
  }

  Future<void> pickImage({String source}) async {
    var selectedImage = await ImagePicker.pickImage(
        source: source == 'Gallery' ? ImageSource.gallery : ImageSource.camera);

    setState(() {
      imageFile = selectedImage;
    });
    compressImage();
    _repository.uploadImageToStorage(imageFile).then((url) {
      print("URL: $url");
      _repository.uploadImageMsgToDb(url, widget.receiverUid, _senderuid);
    });
    return;
  }

  void compressImage() async {
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
  }

  void sendMessage() {
    print("Inside send message");
    var text = _messageController.text;
    print(text);
    FocusScope.of(context).unfocus();
    Message _message = Message(
        receiverUid: widget.receiverUid,
        senderUid: _senderuid,
        message: text,
        timestamp: FieldValue.serverTimestamp(),
        type: 'text');
    print(
        "receiverUid: ${widget.receiverUid} , senderUid : ${_senderuid} , message: ${text}");
    print(
        "timestamp: ${DateTime.now().millisecond}, type: ${text != null ? 'text' : 'image'}");
    _repository.addMessageToDb(_message, widget.receiverUid).then((v) {
      _messageController.text = "";
      print("Message added to db");
    });
  }

  Widget ChatMessagesListWidget() {
    print("SENDERUID : $_senderuid");
    return Flexible(
      child: StreamBuilder(
        stream: _firestore
            .collection("users")
            .doc(_senderuid)
            .collection("messages")
            .doc(widget.receiverUid)
            .collection("messages")
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Color(0xff00ffff))),
            );
          } else {
            //listItem = snapshot.data.documents;
            return ScrollablePositionedList.builder(
              padding: EdgeInsets.all(5.0),
              initialScrollIndex: snapshot.data.documents.length - 1,
              itemBuilder: (context, index) =>
                  chatMessageItem(snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
            );
          }
        },
      ),
    );
  }

  Widget ChatMessages() {
    return Flexible(
        child: _messages.length == 0
            ? Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Color(0xff00ffff))))
            : ScrollablePositionedList.builder(
                padding: EdgeInsets.all(5.0),
                initialScrollIndex: _messages.length - 1,
                itemBuilder: (context, index) =>
                    chatMessageItem(_messages[index]),
                itemCount: _messages.length,
              ));
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 12.0, right: 12.0, top: 7, bottom: 7),
          child: Row(
            mainAxisAlignment: snapshot['senderUid'] == _senderuid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: <Widget>[
              snapshot['senderUid'] == _senderuid
                  ? senderLayout(snapshot)
                  : receiverLayout(snapshot)
            ],
          ),
        )
      ],
    );
  }

  Widget senderLayout(DocumentSnapshot snapshot) {
    if (snapshot['type'] == 'post') {
      Map snap = snapshot.data()['reference'];
      return Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Color(0xff00ffff))
              /*gradient: LinearGradient(colors: [Color(0xff00ffff), Color(0xff009999)],
                begin: Alignment.center,
                end: Alignment.bottomCenter,)*/
              ),
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 10),
                  child: Row(
                    children: <Widget>[
                      Center(),
                      SizedBox(
                        width: 10,
                        height: 5,
                      ),
                      Text(
                        snap['postOwnerName'],
                        style: TextStyle(
                            fontFamily: 'Muli',
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Center()),
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Text(snap['caption'],
                      style: TextStyle(
                          fontFamily: 'Muli',
                          fontWeight: FontWeight.normal,
                          color: Colors.white)),
                )
              ],
            ),
          ));
    } else {
      return snapshot['type'] == 'text'
          ? Flexible(
              child: Container(
              padding: EdgeInsets.all(10.0),
              constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
              decoration: BoxDecoration(
                color: Color(0xff00ffff),
                borderRadius: BorderRadius.circular(15.0),
                /*gradient: LinearGradient(colors: [Color(0xff00ffff), Color(0xff009999)],
                begin: Alignment.center,
                end: Alignment.bottomCenter,)*/
              ),
              child: Text(
                snapshot['message'],
                style: TextStyle(
                    fontFamily: 'Muli', color: Colors.black, fontSize: 16.0),
                overflow: TextOverflow.clip,
                //textAlign: TextAlign.justify,
              ),
            ))
          : FadeInImage(
              fit: BoxFit.cover,
              image: NetworkImage(snapshot['photoUrl']),
              placeholder: AssetImage('assets/blankimage.png'),
              width: 250.0,
              height: 300.0,
            );
    }
  }

  Widget receiverLayout(DocumentSnapshot snapshot) {
    if (snapshot['type'] == 'post') {
      Map snap = snapshot.data()['reference'];
      return Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Color(0xff00ffff))),
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 10),
                  child: Row(
                    children: <Widget>[
                      Center(),
                      SizedBox(
                        width: 10,
                        height: 5,
                      ),
                      Text(
                        snap['postOwnerName'],
                        style: TextStyle(
                            fontFamily: 'Muli',
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Center()),
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Text(snap['caption'],
                      style: TextStyle(
                          fontFamily: 'Muli',
                          fontWeight: FontWeight.normal,
                          color: Colors.white)),
                )
              ],
            ),
          ));
    } else {
      return snapshot['type'] == 'text'
          ? Flexible(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    //constraints: BoxConstraints(minWidth: 10, maxWidth: 20),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(color: Color(0xff00ffff))),
                    child: Text(
                      snapshot['message'],
                      style: TextStyle(
                          fontFamily: 'Muli',
                          color: Colors.white,
                          fontSize: 16.0),
                      overflow: TextOverflow.clip,
                      //textAlign: TextAlign.justify,
                    ),
                  )))
          : FadeInImage(
              fit: BoxFit.cover,
              image: NetworkImage(snapshot['photoUrl']),
              placeholder: AssetImage('assets/blankimage.png'),
              width: 250.0,
              height: 300.0,
            );
    }
  }
}
