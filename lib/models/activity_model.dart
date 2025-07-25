import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  //final String id;
  final String fromUserId;
  final String postId;
  final String postImageUrl;
  final String comment;
  final Timestamp timestamp;
  final int type;
  //final String caption;

  Activity({
    //this.id,
    this.fromUserId,
    this.postId,
    this.postImageUrl,
    this.comment,
    this.timestamp,
    this.type,
    //this.caption
  });

  factory Activity.fromDoc(DocumentSnapshot doc) {
    return Activity(
      fromUserId: doc['fromUserId'],
      postId: doc['postId'],
      postImageUrl: doc['postImageUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      //caption: doc['caption']
    );
  }
}
