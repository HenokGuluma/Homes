import 'package:cloud_firestore/cloud_firestore.dart';

class Message {

  String senderUid;
  String receiverUid;
  String type;
  String message;
  FieldValue timestamp;
  String photoUrl;
  DocumentSnapshot reference;

  Message({this.senderUid, this.receiverUid, this.type, this.message, this.timestamp, this.photoUrl, this.reference});
  Message.withoutMessage({this.senderUid, this.receiverUid, this.type, this.timestamp, this.photoUrl, this.reference});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderUid'] = this.senderUid;
    map['receiverUid'] = this.receiverUid;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    return map;
  }

  Map toMaps() {
    var map = Map<String, dynamic>();
    var _map = Map<String, dynamic>();
    _map['ownerUid'] = reference['ownerUid'];
    _map['caption'] = reference['caption'];
    _map['postID'] = reference['postID'];
    _map['imgUrl'] = reference['imgUrl'];
    _map['likeCount'] = reference['likeCount'];
    _map['time'] = reference['time'];
    _map['postOwnerName'] = reference['postOwnerName'];
    _map['type'] = reference['type'];
    _map['caption'] = reference['caption'];
    _map['postOwnerPhotoUrl'] = reference['postOwnerPhotoUrl'];
    _map['commentCount'] = reference['commentCount'];
    _map['shareCount'] = reference['shareCount'];
    _map['boltCount'] = reference['boltCount'];
    _map['trending'] = reference['trending'];
    _map['trendCount'] = reference['trendCount'];
    _map['reference'] = reference.reference;
   /* _map['aspectRatio'] = reference['aspectRatio'];
    _map['trendReference'] = reference['trendReference'];
    _map['original'] = reference['original'];*/

    map['senderUid'] = this.senderUid;
    map['receiverUid'] = this.receiverUid;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photoUrl;
    map['reference'] = _map;
    return map;
  }

  Message fromMap(Map<String, dynamic> map) {
    Message _message = Message();
    _message.senderUid = map['senderUid'];
    _message.receiverUid = map['receiverUid'];
    _message.type = map['type'];
    _message.message = map['message'];
    _message.timestamp = map['timestamp'];
    _message.photoUrl = map['photoUrl'];
    _message.reference = map['reference'];
    return _message;
  }

  

}