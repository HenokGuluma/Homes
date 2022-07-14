
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {

   String currentUserUid;
   DocumentReference mainReference;
   String imgUrl;
   String thumbnailUrl;
   String postID;
   String caption;
   String location;
   int time;
   String postOwnerName;
   String trendOwnerName;
   String postOwnerPhotoUrl;
   String type;
   int likeCount;
   int commentCount;
   int shareCount;
   int boltCount;
   int trendCount;
   int initial;
   int trending;
   double aspectRatio;
   bool original;
   DocumentReference trendReference;

  Post({this.currentUserUid, this.mainReference, this.imgUrl, this.thumbnailUrl, this.caption, this.location, this.time, this.postOwnerName, this.trendOwnerName, this.postOwnerPhotoUrl
    ,this.type, this.likeCount, this.trending, this.boltCount, this.commentCount, this.shareCount, this.initial, this.aspectRatio,
    this.trendCount, this.postID, this.original, this.trendReference});

   Map toMap(Post post) {
    var data = Map<String, dynamic>();
    data['ownerUid'] = post.currentUserUid;
    data['mainReference'] = post.mainReference;
    data['imgUrl'] = post.imgUrl;
    data['caption'] = post.caption;
    data['location'] = post.location;
    data['time'] = post.time;
    data['postOwnerName'] = post.postOwnerName;
    data['trendOwnerName'] = post.trendOwnerName;
    data['postOwnerPhotoUrl'] = post.postOwnerPhotoUrl;
    data['type'] = post.type;
    data['likeCount'] = post.likeCount;
    data['trending'] = post.trending;
    data['boltCount'] = post.boltCount;
    data['commentCount'] = post.commentCount;
    data['shareCount'] = post.shareCount;
    data['trendCount'] = post.trendCount;
    data['postID'] = post.postID;
    data['aspectRatio'] = post.aspectRatio;
    data['trendReference'] = post.trendReference;
    data['original'] = post.original;
    data['thumbnailUrl'] = post.thumbnailUrl;
    data['initial'] = post.initial;

    return data;
  }

  Post.fromMap(Map<String, dynamic> mapData) {
    this.currentUserUid = mapData['ownerUid'];
    this.mainReference = mapData['mainReference'];
    this.imgUrl = mapData['imgUrl'];
    this.caption = mapData['caption'];
    this.location = mapData['location'];
    this.time = mapData['time'];
    this.postOwnerName = mapData['postOwnerName'];
    this.trendOwnerName = mapData['trendOwnerName'];
    this.postOwnerPhotoUrl = mapData['postOwnerPhotoUrl'];
    this.type = mapData['type'];
    this.likeCount = mapData['likeCount'];
    this.commentCount = mapData['commentCount'];
    this.shareCount = mapData['shareCount'];
    this.trendCount = mapData['trendCount'];
    this.trending = mapData['trending'];
    this.postID = mapData['postID'];
    this.boltCount = mapData['boltCount'];
    this.aspectRatio = mapData['aspectRatio'];
    this.trendReference = mapData['trendReference'];
    this.original = mapData['original'];
    this.thumbnailUrl = mapData['thumbnailUrl'];
    this.initial = mapData['initial'];
   }

  Post.fromDoc(DocumentSnapshot doc){
     this.mainReference = doc['mainReference'];
     this.currentUserUid = doc['ownerUid'];
     this.caption = doc['caption'];
     this.postID = doc['postID'];
     this.imgUrl = doc['imgUrl'];
     this.thumbnailUrl = doc['thumbnailUrl'];
     this.likeCount = doc['likeCount'];
     this.time = doc['time'];
     this.postOwnerName = doc['postOwnerName'];
     this.trendOwnerName = doc['trendOwnerName'];
     this.type = doc['type'];
     this.caption = doc['caption'];
     this.postOwnerPhotoUrl = doc['postOwnerPhotoUrl'];
     this.commentCount = doc['commentCount'];
     this.shareCount = doc['shareCount'];
     this.boltCount = doc['boltCount'];
     this.trending = doc['trending'];
     this.trendCount = doc['trendCount'];
     this.aspectRatio = doc['aspectRatio'];
     this.trendReference = doc['trendReference'];
     this.original = doc['original'];
     this.initial = doc['initial'];

  }
}
