// ignore: avoid_web_libraries_in_flutter
//import 'dart:html';
import 'dart:io' as IO;
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/like.dart';
import 'package:instagram_clone/models/listings.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/models/activity_model.dart';

class FirebaseProvider {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User user;
  Post post;
  Like like;
  Message _message;
  Comment comment;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  StorageReference _storageReference;

  Future<void> addDataToDb(auth.User currentUser) async {
    user = User(
        recentActivity: DateTime.utc(2020).millisecondsSinceEpoch,
        uid: currentUser.uid,
        email: currentUser.email,
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoURL,
        followers: '0',
        following: '0',
        bio: '',
        posts: 0,
        phone: '',
        trending: 100,
        keys: 0,
        dailyTimer: DateTime.now().millisecondsSinceEpoch);

    //  Map<String, String> mapdata = Map<String, dynamic>();

    //  mapdata = user.toMap(user);
    String userExists = await fetchUidBySearchedName(currentUser.displayName);
    if (userExists != null) {
      DocumentSnapshot users =
          await _firestore.collection("users").doc(userExists).get();
      if (users['displayName'] == user.displayName) {
        return;
      }
    }
    _firestore
        .collection("display_names")
        .doc(currentUser.displayName)
        .set({'displayName': currentUser.displayName, 'uid': currentUser.uid});
    _firestore
        .collection("users")
        .doc(currentUser.uid)
        .set({'displayName': currentUser.displayName});

    return _firestore
        .collection("users")
        .doc(currentUser.uid)
        .set(user.toMap(user));
  }

  Future<bool> authenticateUser(auth.User user) async {
    final QuerySnapshot result = await _firestore
        .collection("users")
        .where("email", isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    if (docs.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> fetchUidbyEmail(String email) async {
    final QuerySnapshot result = await _firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
    DocumentSnapshot doc = result.docs[0];
    return doc.data()['uid'];
  }

  Future<auth.User> getCurrentUser() async {
    auth.User currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<auth.User> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      accessToken: _signInAuthentication.accessToken,
      idToken: _signInAuthentication.idToken,
    );

    final auth.User user = (await _auth.signInWithCredential(credential)).user;
    return user;
  }

  Future<String> uploadImageToStorage(IO.File imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<String> uploadImagesToStorage(Uint8List imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putData(imageFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<String> uploadVideoToStorage(IO.File videoFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask storageUploadTask = _storageReference.putFile(videoFile);
    var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  Future<void> addListingToDb(
    List<dynamic> images,
    String userID,
    String additionalNotes,
    String area,
    String listingOwnerName,
    String listingOwnerPhotoUrl,
    String listingOwnerEmail,
    String listingOwnerPhone,
    String listingType,
    String listingDescription,
    String forRent,
    String rentCollection,
    String cost,
    String floor,
    String commonLocation,
    String preciseLocation,
    bool isActive,
  ) async {
    var time = DateTime.now().millisecondsSinceEpoch;
    Listing listing = Listing(
      userID: userID,
      images: images,
      additionalNotes: additionalNotes,
      area: area,
      listingOwnerEmail: listingOwnerEmail,
      listingOwnerName: listingOwnerName,
      listingOwnerPhone: listingOwnerPhone,
      listingOwnerPhotoUrl: listingOwnerPhotoUrl,
      listingType: listingType,
      listingDescription: listingDescription,
      rentCollection: rentCollection,
      phoneNumber: listingOwnerPhone,
      emailAddress: listingOwnerEmail,
      cost: cost,
      floor: floor,
      forRent: forRent,
      commonLocation: commonLocation,
      preciseLocation: preciseLocation,
      isActive: isActive,
      time: time,
      likeCount: 0,
      isReviewed: false,
      approved: false,
    );
    var docId = await _firestore
        .collection("users")
        .doc(userID)
        .collection('listings')
        .add(listing.toMap(listing));

    return _firestore
        .collection("listings")
        .doc(docId.id)
        .set(listing.toMap(listing));
  }

  Future<void> deleteListing(
    String userID,
    String id,
  ) {
    _firestore
        .collection("users")
        .doc(userID)
        .collection('listings')
        .doc(id)
        .delete();
    return _firestore.collection("listings").doc(id).delete();
  }

  Future<void> modifyListing(
    List<dynamic> images,
    String userID,
    String additionalNotes,
    String area,
    String listingOwnerName,
    String listingOwnerPhotoUrl,
    String listingOwnerEmail,
    String listingOwnerPhone,
    String listingType,
    String listingDescription,
    String forRent,
    String rentCollection,
    String cost,
    String floor,
    String commonLocation,
    String preciseLocation,
    bool isActive,
    bool updateImages,
    String id,
  ) {
    var time = DateTime.now().millisecondsSinceEpoch;
    Listing listings = Listing(
        userID: userID,
        additionalNotes: additionalNotes,
        area: area,
        listingOwnerName: listingOwnerName,
        listingOwnerPhotoUrl: listingOwnerPhotoUrl,
        listingType: listingType,
        listingDescription: listingDescription,
        rentCollection: rentCollection,
        phoneNumber: listingOwnerPhone,
        emailAddress: listingOwnerEmail,
        cost: cost,
        floor: floor,
        commonLocation: commonLocation,
        preciseLocation: preciseLocation,
        isActive: isActive,
        time: time,
        forRent: forRent,
        likeCount: 0);

    Map<String, dynamic> listing = {};
    if (isActive) {
      listing['isReviewed'] = false;
      listing['approved'] = false;
    }
    listing['userID'] = userID;
    listing['additionalNotes'] = additionalNotes;
    listing['area'] = area;
    listing['listingOwnerName'] = listingOwnerName;
    listing['listingOwnerPhotoUrl'] = listingOwnerPhotoUrl;
    listing['listingType'] = listingType;
    listing['listingDescription'] = listingDescription;
    listing['rentCollection'] = rentCollection;
    listing['phoneNumber'] = listingOwnerPhone;
    listing['emailAddress'] = listingOwnerEmail;
    listing['cost'] = cost;
    listing['floor'] = floor;
    listing['commonLocation'] = commonLocation;
    listing['preciseLocation'] = preciseLocation;
    listing['isActive'] = isActive;
    listing['time'] = time;

    if (updateImages) {
      listing['images'] = images;
    }
    _firestore
        .collection("users")
        .doc(userID)
        .collection('listings')
        .doc(id)
        .update(listing);
    return _firestore.collection("listings").doc(id).update(listing);
  }

  Future<void> unlockListing(String listing, String userId) {
    var increment = FieldValue.increment(1);
    _firestore.collection('users').doc(userId).update({'posts': increment});
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('unlockedListings')
        .doc(listing)
        .set({'listing': listing});
  }

  Future<List<DocumentSnapshot>> getUnlockedListings(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('unlockedListings')
        .get();
    return snapshot.docs;
  }



  Future<DocumentReference> addPicturePostToDb(
      User currentUser,
      String imgUrl,
      String thumbnailUrl,
      String caption,
      String location,
      int initial,
      double aspectRatio) async {
    CollectionReference _collectionRef =
        _firestore.collection("users").doc(currentUser.uid).collection("posts");
    CollectionReference _userRef = _firestore.collection("users");
    _userRef.doc(currentUser.uid).get().then((doc) {
      int posts = int.parse(doc['posts']) + 1;
      Map<String, dynamic> map = Map();
      map['posts'] = posts.toString();
      map['recentActivity'] = DateTime.now().millisecondsSinceEpoch;
      _userRef.doc(currentUser.uid).update(map);
    });

    post = Post(
        currentUserUid: currentUser.uid,
        imgUrl: imgUrl,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
        location: location,
        postOwnerName: currentUser.displayName,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: DateTime.now().millisecondsSinceEpoch,
        commentCount: 1,
        likeCount: 1,
        shareCount: 1,
        boltCount: 1,
        trendCount: 1,
        trending: initial,
        type: 'photo',
        initial: initial,
        postID: currentUser.displayName +
            Timestamp.fromDate(DateTime.now()).toString(),
        original: false,
        aspectRatio: aspectRatio);
    CollectionReference _everypost =
        _firestore.collection("posts").doc("pictures").collection("posts");
    post.mainReference = await _everypost.add(post.toMap(post));
    _collectionRef.doc(post.postID).set(post.toMap(post));
    DocumentReference ref = _collectionRef.doc(post.postID);
    post.mainReference.update({'originalReference': ref});
    /*var increment = FieldValue.increment(1);
    DocumentReference picturePosts = _firestore.collection("posts").doc("pictures");
    picturePosts.update({'total_posts': increment});*/
    //updateTrending(initial, 0, ref);
    return ref;
    //return _collectionRef.add(post.toMap(post));
  }

  Future<DocumentReference> addPictureTrendPostToDb(
      User currentUser,
      String imgUrl,
      String thumbnailUrl,
      String trendOwner,
      String caption,
      String location,
      int initial,
      DocumentReference reference,
      double aspectRatio) async {
    CollectionReference _collectionRef =
        _firestore.collection("users").doc(currentUser.uid).collection("posts");
    CollectionReference _userRef = _firestore.collection("users");
    _userRef.doc(currentUser.uid).get().then((doc) {
      int posts = int.parse(doc['posts']) + 1;
      Map<String, dynamic> map = Map();
      map['posts'] = posts.toString();
      map['recentActivity'] = DateTime.now().millisecondsSinceEpoch;
      _userRef.doc(currentUser.uid).update(map);
    });

    post = Post(
        currentUserUid: currentUser.uid,
        imgUrl: imgUrl,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
        location: location,
        postOwnerName: currentUser.displayName,
        trendOwnerName: trendOwner,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: DateTime.now().millisecondsSinceEpoch,
        commentCount: 1,
        likeCount: 1,
        shareCount: 1,
        boltCount: 1,
        trendCount: 1,
        trending: initial,
        initial: initial,
        type: 'photo',
        postID: currentUser.displayName +
            Timestamp.fromDate(DateTime.now()).toString(),
        original: true,
        trendReference: reference,
        aspectRatio: aspectRatio);

    CollectionReference _everypost =
        _firestore.collection("posts").doc("pictures").collection("posts");
    post.mainReference = await _everypost.add(post.toMap(post));
    _collectionRef.doc(post.postID).set(post.toMap(post));
    DocumentReference ref = _collectionRef.doc(post.postID);
    post.mainReference.update({'originalReference': ref});
    /* var increment = FieldValue.increment(1);
    DocumentReference picturePosts = _firestore.collection("posts").doc("pictures");
    picturePosts.update({'total_posts': increment});*/
    //updateTrending(initial, 0, ref);
    return ref;

    //return _collectionRef.add(post.toMap(post));
  }

  Future<DocumentReference> addVideoTrendPostToDb(
      User currentUser,
      String imgUrl,
      String thumbnailUrl,
      String trendOwner,
      String caption,
      String location,
      int initial,
      DocumentReference reference,
      double aspectRatio) async {
    CollectionReference _collectionRef =
        _firestore.collection("users").doc(currentUser.uid).collection("posts");
    CollectionReference _userRef = _firestore.collection("users");
    _userRef.doc(currentUser.uid).get().then((doc) {
      int posts = int.parse(doc['posts']) + 1;
      Map<String, dynamic> map = Map();
      map['posts'] = posts.toString();
      map['recentActivity'] = DateTime.now().millisecondsSinceEpoch;
      _userRef.doc(currentUser.uid).update(map);
    });

    post = Post(
        currentUserUid: currentUser.uid,
        imgUrl: imgUrl,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
        location: location,
        postOwnerName: currentUser.displayName,
        trendOwnerName: trendOwner,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: DateTime.now().millisecondsSinceEpoch,
        commentCount: 1,
        likeCount: 1,
        shareCount: 1,
        boltCount: 1,
        trendCount: 1,
        trending: initial,
        initial: initial,
        type: 'video',
        postID: currentUser.displayName +
            Timestamp.fromDate(DateTime.now()).toString(),
        original: true,
        trendReference: reference,
        aspectRatio: aspectRatio);

    CollectionReference _everypost =
        _firestore.collection("posts").doc("videos").collection("posts");
    post.mainReference = await _everypost.add(post.toMap(post));
    _collectionRef.doc(post.postID).set(post.toMap(post));
    DocumentReference ref = _collectionRef.doc(post.postID);
    post.mainReference.update({'originalReference': ref});
    /*var increment = FieldValue.increment(1);
    DocumentReference videoPosts = _firestore.collection("posts").doc("videos");
    videoPosts.update({'total_posts': increment});*/
    //updateTrending(initial, 0, ref);
    return ref;
    //return _collectionRef.add(post.toMap(post));
  }

  Future<DocumentReference> addTextTrendPostToDb(
      User currentUser,
      String imgUrl,
      String thumbnailUrl,
      String trendOwner,
      String caption,
      String location,
      int initial,
      DocumentReference reference,
      double aspectRatio) async {
    CollectionReference _collectionRef =
        _firestore.collection("users").doc(currentUser.uid).collection("posts");
    CollectionReference _userRef = _firestore.collection("users");
    _userRef.doc(currentUser.uid).get().then((doc) {
      int posts = int.parse(doc['posts']) + 1;
      Map<String, dynamic> map = Map();
      map['posts'] = posts.toString();
      map['recentActivity'] = DateTime.now().millisecondsSinceEpoch;
      _userRef.doc(currentUser.uid).update(map);
    });

    post = Post(
        currentUserUid: currentUser.uid,
        imgUrl: imgUrl,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
        location: location,
        postOwnerName: currentUser.displayName,
        trendOwnerName: trendOwner,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: DateTime.now().millisecondsSinceEpoch,
        commentCount: 1,
        likeCount: 1,
        shareCount: 1,
        boltCount: 1,
        trendCount: 1,
        trending: initial,
        initial: initial,
        type: 'text',
        postID: currentUser.displayName +
            Timestamp.fromDate(DateTime.now()).toString(),
        original: true,
        trendReference: reference,
        aspectRatio: aspectRatio);

    CollectionReference _everypost =
        _firestore.collection("posts").doc("texts").collection("posts");
    post.mainReference = await _everypost.add(post.toMap(post));
    _collectionRef.doc(post.postID).set(post.toMap(post));
    DocumentReference ref = _collectionRef.doc(post.postID);
    post.mainReference.update({'originalReference': ref});
    /* var increment = FieldValue.increment(1);
    DocumentReference textPosts = _firestore.collection("posts").doc("texts");
    textPosts.update({'total_posts': increment});*/
    //updateTrending(initial, 0, ref);
    return ref;
    //return _collectionRef.add(post.toMap(post));
  }

  Future<DocumentReference> addTextPostToDb(
      User currentUser,
      String caption,
      int initial,
      String trendOwner,
      DocumentReference reference,
      bool original) async {
    CollectionReference _collectionRef =
        _firestore.collection("users").doc(currentUser.uid).collection("posts");

    CollectionReference _userRef = _firestore.collection("users");
    _userRef.doc(currentUser.uid).get().then((doc) {
      int posts = int.parse(doc['posts']) + 1;
      Map<String, dynamic> map = Map();
      map['posts'] = posts.toString();
      map['recentActivity'] = DateTime.now().millisecondsSinceEpoch;
      _userRef.doc(currentUser.uid).update(map);
    });

    post = Post(
        currentUserUid: currentUser.uid,
        caption: caption,
        postOwnerName: currentUser.displayName,
        trendOwnerName: trendOwner,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: DateTime.now().millisecondsSinceEpoch,
        commentCount: 1,
        likeCount: 1,
        shareCount: 1,
        boltCount: 1,
        trendCount: 1,
        initial: initial,
        trendReference: reference,
        trending: initial,
        type: 'text',
        original: false,
        postID: currentUser.displayName +
            Timestamp.fromDate(DateTime.now()).toString());
    CollectionReference _everypost =
        _firestore.collection("posts").doc("texts").collection("posts");
    post.mainReference = await _everypost.add(post.toMap(post));
    _collectionRef.doc(post.postID).set(post.toMap(post));
    /* var increment = FieldValue.increment(1);
    DocumentReference textPosts = _firestore.collection("posts").doc("texts");
    textPosts.update({'total_posts': increment});*/
    DocumentReference ref = _collectionRef.doc(post.postID);
    post.mainReference.update({'originalReference': ref});
    //updateTrending(initial, 0, ref);
    return ref;
  }

  Future<DocumentSnapshot> getListingWithId(String id) async {
    DocumentSnapshot listing =
        await _firestore.collection('listings').doc(id).get();
    return listing;
  }

  Future<List<DocumentSnapshot>> getAllPhones() async {
       var phones = await _firestore
        .collection('phones')
        .get();
    return phones.docs;
  }

   void addPhone(String phone, String userId) async{
    await _firestore.collection('phones').doc(phone).set({'phone': phone, 'userId': userId});
  }

   Future<List<DocumentSnapshot>> getOrderHistory(String userId) async {
       var keys = await _firestore
        .collection('users').doc(userId).collection('orders')
        .get();
    return keys.docs;
  }

 Future<List<DocumentSnapshot>> getPendingOrders(String userId) async {
       var keys = await _firestore
        .collection('users').doc(userId).collection('orders').where('deposited', isEqualTo: false)
        .get();
    return keys.docs;
  }

  void addOrder(User user, int amount, int price, String remark, bool telebirr) async{
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> orderMap = {};
    orderMap['user'] = user.toMap(user);
    orderMap['time'] = currentTime;
    orderMap['amount'] = amount;
    orderMap['price'] = price;
    orderMap['remark'] = remark;
    orderMap['isTelebirr'] = telebirr;
    orderMap['deposited'] = false;
    orderMap['payment'] = false;
    await _firestore.collection('orders').doc(currentTime.toString() + user.uid).set(orderMap);
    return _firestore.collection('users').doc(user.uid).collection('orders').doc(currentTime.toString() + user.uid).set(orderMap);
  }

  void modifyOrder(User user, int amount, int price, String remark, String docId, bool telebirr) async{
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> orderMap = {};
    orderMap['user'] = user.toMap(user);
    orderMap['time'] = currentTime;
    orderMap['amount'] = amount;
    orderMap['price'] = price;
    orderMap['remark'] = remark;
    orderMap['isTelebirr'] = telebirr;
    await _firestore.collection('orders').doc(docId).update(orderMap);
    return _firestore.collection('users').doc(user.uid).collection('orders').doc(docId).set(orderMap);

  }
   void cancelOrder(User user, String docId) async{
    await _firestore.collection('orders').doc(docId).delete();
    return _firestore.collection('users').doc(user.uid).collection('orders').doc(docId).delete();
  }

  Future<DocumentReference> addVideoPostToDb(
      User currentUser,
      String imgUrl,
      String thumbnailUrl,
      String caption,
      String location,
      int initial,
      double aspectRatio) async {
    CollectionReference _collectionRef =
        _firestore.collection("users").doc(currentUser.uid).collection("posts");

    CollectionReference _userRef = _firestore.collection("users");
    _userRef.doc(currentUser.uid).get().then((doc) {
      int posts = int.parse(doc['posts']) + 1;
      Map<String, dynamic> map = Map();
      map['posts'] = posts.toString();
      map['recentActivity'] = DateTime.now().millisecondsSinceEpoch;
      _userRef.doc(currentUser.uid).update(map);
    });

    post = Post(
        currentUserUid: currentUser.uid,
        imgUrl: imgUrl,
        thumbnailUrl: thumbnailUrl,
        caption: caption,
        postOwnerName: currentUser.displayName,
        postOwnerPhotoUrl: currentUser.photoUrl,
        time: DateTime.now().millisecondsSinceEpoch,
        commentCount: 1,
        likeCount: 1,
        shareCount: 1,
        boltCount: 1,
        trendCount: 1,
        trending: initial,
        initial: initial,
        type: 'video',
        original: false,
        aspectRatio: aspectRatio,
        postID: currentUser.displayName +
            Timestamp.fromDate(DateTime.now()).toString());

    CollectionReference _everypost =
        _firestore.collection("posts").doc("videos").collection("posts");
    post.mainReference = await _everypost.add(post.toMap(post));
    _collectionRef.doc(post.postID).set(post.toMap(post));
    DocumentReference ref = _collectionRef.doc(post.postID);
    post.mainReference.update({'originalReference': ref});
    /*var increment = FieldValue.increment(1);
    DocumentReference videoPosts = _firestore.collection("posts").doc("videos");
    videoPosts.update({'total_posts': increment});*/
    // updateTrending(initial, 0, ref);
    return ref;
  }

  Future<User> retrieveUserDetails(auth.User user) async {
    DocumentSnapshot _documentSnapshot =
        await _firestore.collection("users").doc(user.uid).get();
    return User.fromMap(_documentSnapshot.data());
  }

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("posts")
        .orderBy("time", descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> retrieveUserPhotoPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("posts")
        .where('type', isEqualTo: 'photo')
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> retrieveUserTextPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("posts")
        .where('type', isEqualTo: 'text')
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> retrieveUserVideoPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("posts")
        .where('type', isEqualTo: 'video')
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> retrieveUserSavedPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("saved_posts")
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchPostCommentDetails(
      DocumentReference reference) async {
    QuerySnapshot snapshot = await reference.collection("comments").get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getListings() async {
    QuerySnapshot snapshot = await _firestore
        .collection('listings')
        .where('approved', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('likeCount', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getSearchListings() async {
    QuerySnapshot snapshot = await _firestore
        .collection('listings')
        .where('approved', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('time', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getNotifications(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('time', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getMoreListings(var startAfter) async {
    QuerySnapshot snapshot = await _firestore
        .collection('listings')
        .orderBy('likeCount', descending: true)
        .startAfter(startAfter)
        .limit(20)
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> getOwnListings(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('listings')
        .get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getListingDetails(String reference) async {
    var details = await _firestore.collection('listings').doc(reference).get();
    return details;
  }

  Future<List<DocumentSnapshot>> fetchPostLikeDetails(
      DocumentReference reference) async {
    QuerySnapshot snapshot = await reference.collection("likes").get();
    return snapshot.docs;
  }

  void likeListing(DocumentSnapshot item, String userId) async {
    CollectionReference _userRef =
        _firestore.collection('users').doc(userId).collection('likedListings');
    print('liked this listing');
    var increment = FieldValue.increment(1);
    item.reference.update({'likeCount': increment});
    _userRef.doc(item.id).set({'listing': item.id});
  }

  void unlikeListing(DocumentSnapshot item, String userId) async {
    CollectionReference _userRef =
        _firestore.collection('users').doc(userId).collection('likedListings');
    print('unliked this listing');
    var increment = FieldValue.increment(-1);
    item.reference.update({'likeCount': increment});
    _userRef.doc(item.id).delete();
  }

  Future<List<DocumentSnapshot>> getLikedListings(String userId) async {
    var likedListings = await _firestore
        .collection('users')
        .doc(userId)
        .collection('likedListings')
        .get();
    return likedListings.docs;
  }

  void likePost(String currentUserId, DocumentSnapshot postSnap) async {
    CollectionReference _likeRef = postSnap.reference.collection("likes");
    bool likeStatus = await didLikePost(currentUserId, postSnap.reference);
    if (likeStatus) {
      return;
    }
    postSnap.reference.get().then((doc) {
      var increment = FieldValue.increment(1);
      int likeCount = doc['likeCount'] + 1;
      int trending = calculateTrending(
          likeCount /*postSnap['likeCount']*/,
          doc['commentCount'],
          doc['boltCount'],
          doc['trendCount'],
          doc['initial']);
      DocumentReference mainReference = postSnap['mainReference'];
      if (mainReference == null) {
        mainReference = postSnap['originalReference'];
      }
      CollectionReference mainLikeRef = mainReference.collection("likes");
      postSnap.reference.update({'likeCount': increment});
      mainReference.update({'likeCount': increment});
      _likeRef
          .doc(currentUserId)
          .set({'Time': Timestamp.fromDate(DateTime.now())});
      mainLikeRef
          .doc(currentUserId)
          .set({'Time': Timestamp.fromDate(DateTime.now())});
      addActivityItem(
          currentUserId: currentUserId,
          postRef: postSnap.reference,
          comment: null,
          type: 1);
      updateTrending(trending, doc['trending'], postSnap.reference);
      updateTrending(trending, doc['trending'], mainReference);
    });
  }

  void unlikePost(String currentUserId, DocumentSnapshot postSnap) {
    postSnap.reference.get().then((doc) {
      var increment = FieldValue.increment(-1);
      int likeCount = doc['likeCount'] - 1;
      int trending = calculateTrending(
          likeCount /*postSnap['likeCount']*/,
          doc['commentCount'],
          doc['boltCount'],
          doc['trendCount'],
          doc['initial']);
      DocumentReference mainReference = doc['mainReference'];
      if (mainReference == null) {
        mainReference = doc['originalReference'];
      }
      postSnap.reference.update({'likeCount': increment});
      mainReference.update({'likeCount': increment});
      postSnap.reference
          .collection('likes')
          .doc(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      mainReference.collection('likes').doc(currentUserId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      updateTrending(trending, doc['trending'], postSnap.reference);
      updateTrending(trending, doc['trending'], mainReference);
    });
  }

  Future<bool> didLikePost(String userId, DocumentReference reference) async {
    CollectionReference _likeRef = reference.collection("likes");
    DocumentSnapshot snapshot = await _likeRef.doc(userId).get();
    return snapshot.exists;
  }

  void boltPost(String currentUserId, DocumentSnapshot postSnap) async {
    CollectionReference _boltRef = postSnap.reference.collection("bolts");
    bool boltStatus = await didBoltPost(currentUserId, postSnap.reference);
    if (boltStatus) {
      return;
    }
    postSnap.reference.get().then((doc) {
      int boltCount = doc['boltCount'] + 1;
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          boltCount, doc['trendCount'], doc['initial']);
      var increment = FieldValue.increment(1);
      DocumentReference mainReference = postSnap['mainReference'];
      if (mainReference == null) {
        mainReference = postSnap['originalReference'];
      }
      CollectionReference mainboltRef = mainReference.collection("bolts");
      postSnap.reference.update({'boltCount': increment});
      mainReference.update({'boltCount': increment});
      _boltRef
          .doc(currentUserId)
          .set({'Time': Timestamp.fromDate(DateTime.now())});
      mainboltRef
          .doc(currentUserId)
          .set({'Time': Timestamp.fromDate(DateTime.now())});
      addActivityItem(
          currentUserId: currentUserId,
          postRef: postSnap.reference,
          comment: null,
          type: 3);
      updateTrending(trending, doc['trending'], postSnap.reference);
      updateTrending(trending, doc['trending'], mainReference);
    });
    DocumentReference userRef =
        _firestore.collection("users").doc(currentUserId);
    await userRef.get().then((doc) {
      userRef.update({'dailyTimer': DateTime.now().millisecondsSinceEpoch});
    });
  }

  void unboltPost(String currentUserId, DocumentSnapshot postSnap) async {
    bool boltStatus = await didBoltPost(currentUserId, postSnap.reference);
    if (!boltStatus) {
      return;
    }
    postSnap.reference.get().then((doc) {
      var increment = FieldValue.increment(-1);
      int boltCount = doc['boltCount'] - 1;
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          boltCount, doc['trendCount'], doc['initial']);
      DocumentReference mainReference = postSnap['mainReference'];
      if (mainReference == null) {
        mainReference = postSnap['originalReference'];
      }
      postSnap.reference.update({'boltCount': increment});
      mainReference.update({'boltCount': increment});
      postSnap.reference
          .collection('bolts')
          .doc(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      mainReference.collection('bolts').doc(currentUserId).get().then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
      updateTrending(trending, doc['trending'], postSnap.reference);
      updateTrending(trending, doc['trending'], mainReference);
    });
    DocumentReference userRef =
        _firestore.collection("users").doc(currentUserId);
    await userRef.get().then((doc) {
      userRef.update({'dailyTimer': 2});
    });
  }

  Future<bool> didBoltPost(String userId, DocumentReference reference) async {
    CollectionReference _boltRef = reference.collection("bolts");
    DocumentSnapshot snapshot = await _boltRef.doc(userId).get();
    return snapshot.exists;
  }

  void commentOnPost(User currentUserId, DocumentReference postRef,
      String comment, String imgUrl) async {
    //CollectionReference commentRef = postRef.collection('comments');
    await postRef.get().then((doc) {
      var increment = FieldValue.increment(1);
      //int commentCount = doc['commentCount']+1;
      DocumentReference mainReference = doc['mainReference'];
      if (mainReference == null) {
        mainReference = doc['originalReference'];
      }
      postRef.update({'commentCount': increment});
      mainReference.update({'commentCount': increment});
      postRef.collection('comments').add({
        'authorName': currentUserId.displayName,
        'content': comment,
        'authorId': currentUserId.uid,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'authorPhoto': imgUrl,
      });
      mainReference.collection('comments').add({
        'authorName': currentUserId.displayName,
        'content': comment,
        'authorId': currentUserId.uid,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'authorPhoto': imgUrl,
      });
      addActivityItem(
          currentUserId: currentUserId.uid,
          postRef: postRef,
          comment: comment,
          type: 2);
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          doc['boltCount'], doc['trendCount'], doc['initial']);
      updateTrending(trending, doc['trending'], postRef);
      updateTrending(trending, doc['trending'], mainReference);
    });
  }

  void followTrend(
      String currentUserId, DocumentReference postRef, Post trendFollow) {
    postRef.get().then((doc) {
      int trendCount = doc['trendCount'] + 1;
      var increment = FieldValue.increment(1);
      postRef.update({'trendCount': increment});
      postRef.collection('trendFollows').add({
        'postID': trendFollow.postID,
        'authorId': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
      addActivityItem(
          currentUserId: currentUserId,
          postRef: postRef,
          comment: null,
          type: 4);
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          doc['boltCount'], trendCount, doc['initial']);
      updateTrending(trending, doc['trending'], postRef);
    });
  }

  void followPictureTrend(
      User currentUser, DocumentReference postRef, DocumentReference ref) {
    postRef.get().then((doc) {
      var increment = FieldValue.increment(1);
      int trendCount = doc['trendCount'] + 1;
      DocumentReference mainReference = doc['mainReference'];
      if (mainReference == null) {
        mainReference = doc['originalReference'];
      }
      postRef.update({'trendCount': increment});
      mainReference.update({'trendCount': increment});
      ref.get().then((docs) {
        String postID = docs['postID'];
        var data = Map<String, dynamic>();
        data['reference'] = ref;
        postRef
            .collection('trend_follows')
            .doc(postID)
            .set(data)
            .then((value) => null);
        mainReference
            .collection('trend_follows')
            .doc(postID)
            .set(data)
            .then((value) => null);
      });
      //addPicturePostToDb(currentUser, trendFollow.imgUrl, trendFollow.caption, trendFollow.location, doc['trending']*0.2+20);
      addActivityItem(
          currentUserId: currentUser.uid,
          postRef: postRef,
          comment: null,
          type: 4);
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          doc['boltCount'], trendCount, doc['initial']);
      updateTrending(trending, doc['trending'], postRef);
      updateTrending(trending, doc['trending'], mainReference);
    });
  }

  void followVideoTrend(
      User currentUser, DocumentReference postRef, DocumentReference ref) {
    postRef.get().then((doc) {
      int trendCount = doc['trendCount'] + 1;
      var increment = FieldValue.increment(1);
      DocumentReference mainReference = doc['mainReference'];
      if (mainReference == null) {
        mainReference = doc['originalReference'];
      }
      postRef.update({'trendCount': increment});
      mainReference.update({'trendCount': increment});
      ref.get().then((docs) {
        String postID = docs['postID'];
        var data = Map<String, dynamic>();
        data['reference'] = ref;
        postRef
            .collection('trend_follows')
            .doc(postID)
            .set(data)
            .then((value) => null);
        mainReference
            .collection('trend_follows')
            .doc(postID)
            .set(data)
            .then((value) => null);
      });
      //addPicturePostToDb(currentUser, trendFollow.imgUrl, trendFollow.caption, trendFollow.location, doc['trending']*0.2+20);
      addActivityItem(
          currentUserId: currentUser.uid,
          postRef: postRef,
          comment: null,
          type: 4);
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          doc['boltCount'], trendCount, doc['initial']);
      updateTrending(trending, doc['trending'], postRef);
      updateTrending(trending, doc['trending'], mainReference);
    });
  }

  void followTextTrend(
      User currentUser, DocumentReference postRef, DocumentReference ref) {
    postRef.get().then((doc) {
      int trendCount = doc['trendCount'] + 1;
      var increment = FieldValue.increment(1);
      DocumentReference mainReference = doc['mainReference'];
      if (mainReference == null) {
        mainReference = doc['originalReference'];
      }
      postRef.update({'trendCount': increment});
      mainReference.update({'trendCount': increment});
      ref.get().then((docs) {
        String postID = docs['postID'];
        var data = Map<String, dynamic>();
        data['reference'] = ref;
        postRef
            .collection('trend_follows')
            .doc(postID)
            .set(data)
            .then((value) => null);
        mainReference
            .collection('trend_follows')
            .doc(postID)
            .set(data)
            .then((value) => null);
      });
      //addTextPostToDb(currentUser, trendFollow.caption, doc['trending']+20);
      addActivityItem(
          currentUserId: currentUser.uid,
          postRef: postRef,
          comment: null,
          type: 4);
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          doc['boltCount'], trendCount, doc['initial']);
      updateTrending(trending, doc['trending'], postRef);
      updateTrending(trending, doc['trending'], mainReference);
    });
  }

  void unfollowTrend(String currentUserId, DocumentReference postRef,
      DocumentReference trendFollow) {
    postRef.get().then((doc) {
      int trendCount = doc['trendCount'] - 1;
      var increment = FieldValue.increment(-1);
      DocumentReference mainReference = doc['mainReference'];
      if (mainReference == null) {
        mainReference = doc['originalReference'];
      }
      postRef.update({'trendCount': increment});
      mainReference.update({'trendCount': increment});
      trendFollow.get().then((docs) {
        postRef
            .collection('trendFollows')
            .doc(docs['postID'])
            .get()
            .then((trend) {
          if (trend.exists) {
            trend.reference.delete();
          }
        });
        mainReference
            .collection('trendFollows')
            .doc(docs['postID'])
            .get()
            .then((trend) {
          if (trend.exists) {
            trend.reference.delete();
          }
        });
      });
      int trending = calculateTrending(doc['likeCount'], doc['commentCount'],
          doc['boltCount'], trendCount, doc['initial']);
      updateTrending(trending, doc['trending'], postRef);
      updateTrending(trending, doc['trending'], mainReference);
      deletePost(postRef, currentUserId);
      deletePost(mainReference, currentUserId);
    });
  }

  void deletePost(DocumentReference postRef, String user) async {
    await postRef.delete();
  }

  int calculateTrending(int likeCount, int commentCount, int boltCount,
      int trendCount, int initial) {
    int trending = (((log(likeCount) / log(2)) * 20) +
            ((log(commentCount) / log(2)) * 20) +
            ((log(boltCount) / log(2)) * 40) +
            ((log(trendCount) / log(2)) * 60) +
            initial)
        .toInt();
    return trending;
  }

  Future<void> updateTrending(
      int newtrending, int oldtrending, DocumentReference postRef) async {
    CollectionReference usersRef = _firestore.collection("users");
    postRef.get().then((doc) {
      postRef.update({'trending': newtrending});
      String ownerID = doc['ownerUid'];

      usersRef.doc(ownerID).get().then((doc) {
        int newTrending = doc['trending'] - oldtrending + newtrending;
        usersRef.doc(ownerID).update({'trending': newTrending});
      });
    });
  }

  Future<List<DocumentSnapshot>> retrievePosts(auth.User user) async {
    List<DocumentSnapshot> list = List<DocumentSnapshot>();
    List<DocumentSnapshot> updatedList = List<DocumentSnapshot>();
    QuerySnapshot querySnapshot;
    QuerySnapshot snapshot = await _firestore.collection("users").get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      /*if (snapshot.docs[i].id != user.uid) {
        list.add(snapshot.docs[i]);
      }*/
      list.add(snapshot.docs[i]);
    }
    for (var i = 0; i < list.length; i++) {
      querySnapshot = await list[i].reference.collection("posts").get();
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        updatedList.add(querySnapshot.docs[i]);
      }
    }
    // fetchSearchPosts(updatedList);
    return updatedList;
  }

  Future<List<DocumentSnapshot>> retrieveTopPosts(auth.User user) async {
    List<DocumentSnapshot> list = List<DocumentSnapshot>();
    List<DocumentSnapshot> updatedList = List<DocumentSnapshot>();
    List<DocumentSnapshot> updatedLists = List<DocumentSnapshot>();
    QuerySnapshot querySnapshot;
    QuerySnapshot snapshot = await _firestore.collection("users").get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      list.add(snapshot.docs[i]);
    }
    for (var i = 0; i < list.length; i++) {
      querySnapshot = await list[i].reference.collection("posts").get();
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        updatedList.add(querySnapshot.docs[i]);
      }
    }
    updatedList.sort((a, b) =>
        a.data()['trending'].hashCode.compareTo(b.data()['trending'].hashCode));
    for (var i = 0; i < updatedList.length; i++) {
      updatedLists.add(updatedList[i]);
    }
    // fetchSearchPosts(updatedList);
    return updatedLists;
  }

  Future<List<String>> fetchAllUserNames(auth.User user) async {
    List<String> userNameList = List<String>();
    QuerySnapshot querySnapshot = await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        userNameList.add(querySnapshot.docs[i].data()['displayName']);
      }
    }
    return userNameList;
  }

  Future<String> fetchUidBySearchedName(String name) async {
    DocumentSnapshot snapshot =
        await _firestore.collection("display_names").doc(name).get();
    if (snapshot.data() != null) {
      return snapshot.data()['uid'];
    }
    return null;
  }

  Future<String> fetchUidBySearchedEmail(String email) async {
    DocumentSnapshot snapshot =
        await _firestore.collection("display_names").doc(email).get();
    if (snapshot.data() != null) {
      return snapshot.data()['uid'];
    }
    return null;
  }

  Future<User> fetchUserDetailsById(String uid) async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection("users").doc(uid).get();
    return User.fromMap(documentSnapshot.data());
  }

  Future<void> followUser(
      {String currentUserId, String followingUserId}) async {
    var followingMap = Map<String, String>();
    followingMap['uid'] = followingUserId;
    DocumentReference userRef =
        _firestore.collection("users").doc(currentUserId);
    userRef.get().then((doc) {
      int following = int.parse(doc['following']) + 1;
      Map<String, dynamic> map = Map();
      map['following'] = following.toString();
      print('the following amount is ');
      print(map['following']);
      userRef.update(map);
    });
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .set(followingMap);

    var followersMap = Map<String, String>();
    followersMap['uid'] = currentUserId;
    await _firestore
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .set(followersMap);

    addActivitiesItem(currentUserId: currentUserId, userID: followingUserId);
    DocumentReference usersRef =
        _firestore.collection("users").doc(followingUserId);
    usersRef.get().then((doc) {
      int follower = int.parse(doc['followers']) + 1;
      Map<String, dynamic> map = Map();
      map['followers'] = follower.toString();
      usersRef.update(map);
    });
  }

  Future<void> unFollowUser(
      {String currentUserId, String followingUserId}) async {
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .delete();
    DocumentReference userRef =
        await _firestore.collection("users").doc(currentUserId);
    userRef.get().then((doc) {
      int following = int.parse(doc['following']) - 1;
      Map<String, dynamic> map = Map();
      map['following'] = following.toString();
      userRef.update(map);
    });
    DocumentReference usersRef =
        await _firestore.collection("users").doc(followingUserId);
    usersRef.get().then((docs) {
      int follower = int.parse(docs['followers']) - 1;
      Map<String, dynamic> maps = Map();
      maps['followers'] = follower.toString();
      usersRef.update(maps);
    });

    return _firestore
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .delete();
  }

  Future<bool> checkIsFollowing(String name, String currentUserId) async {
    bool isFollowing = false;
    String uid = await fetchUidBySearchedName(name);
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id == uid) {
        isFollowing = true;
      }
    }
    return isFollowing;
  }

  Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) async {
    QuerySnapshot querySnapshot =
        await _firestore.collection("users").doc(uid).collection(label).get();
    return querySnapshot.docs;
  }

  Future<void> updatePhoto(String photoUrl, String uid) async {
    Map<String, dynamic> map = Map();
    map['photoUrl'] = photoUrl;
    return _firestore.collection("users").doc(uid).update(map);
  }

  Future<void> updateDetails(
      String uid, String name, String bio, String email, String phone) async {
    Map<String, dynamic> map = Map();
    map['displayName'] = name;
    map['bio'] = bio;
    map['email'] = email;
    map['phone'] = phone;
    _firestore.collection('phones').doc(phone).set({'phone': phone, 'userId': uid});
    return _firestore.collection("users").doc(uid).update(map);
  }

  Future<List<String>> fetchUserNames(auth.User user) async {
    DocumentReference documentReference =
        _firestore.collection("messages").doc(user.uid);
    List<String> userNameList = List<String>();
    List<String> chatUsersList = List<String>();
    QuerySnapshot querySnapshot = await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        userNameList.add(querySnapshot.docs[i].id);
        //querySnapshot.documents[i].reference.collection("collectionPath");
        //userNameList.add(querySnapshot.documents[i].data['displayName']);
      }
    }

    for (var i = 0; i < userNameList.length; i++) {
      if (documentReference.collection(userNameList[i]) != null) {
        if (documentReference.collection(userNameList[i]).get() != null) {
          chatUsersList.add(userNameList[i]);
        }
      }
    }

    return chatUsersList;
  }

  Future<List<User>> fetchSuggestedUsers(auth.User user) async {
    List<User> userList = List<User>();
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .orderBy("uid", descending: true)
        .limit(30)
        .get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].data()['uid'] != user.uid) {
        userList.add(User.fromMap(querySnapshot.docs[i].data()));
      }
    }

    return userList;
  }

  Future<List<User>> fetchAllUsers(auth.User user) async {
    List<User> userList = List<User>();
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .orderBy("uid", descending: true)
        .get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      userList.add(User.fromMap(querySnapshot.docs[i].data()));
    }

    return userList;
  }

  Future<List<User>> getTopUsers(auth.User user) async {
    List<User> userList = List<User>();
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .orderBy("trending", descending: true)
        .limit(30)
        .get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      userList.add(User.fromMap(querySnapshot.docs[i].data()));
    }

    return userList;
  }

  void uploadImageMsgToDb(String url, String receiverUid, String senderuid) {
    _message = Message.withoutMessage(
        receiverUid: receiverUid,
        senderUid: senderuid,
        photoUrl: url,
        timestamp: FieldValue.serverTimestamp(),
        type: 'image');
    var map = Map<String, dynamic>();
    map['senderUid'] = _message.senderUid;
    map['receiverUid'] = _message.receiverUid;
    map['type'] = _message.type;
    map['timestamp'] = _message.timestamp;
    map['photoUrl'] = _message.photoUrl;

    _firestore
        .collection("users")
        .doc(_message.senderUid)
        .collection("messages")
        .doc(_message.receiverUid)
        .collection("messages")
        .add(map)
        .whenComplete(() {});

    _firestore
        .collection("users")
        .doc(_message.receiverUid)
        .collection("messages")
        .doc(_message.senderUid)
        .collection("messages")
        .add(map)
        .whenComplete(() {});
  }

  Future<void> addMessageToDb(Message message, String receiverUid) async {
    var map = message.toMap();

    await _firestore
        .collection("users")
        .doc(message.senderUid)
        .collection("messages")
        .doc(message.receiverUid)
        .collection("messages")
        .add(map);

    return _firestore
        .collection("users")
        .doc(message.receiverUid)
        .collection("messages")
        .doc(message.senderUid)
        .collection("messages")
        .add(map);
  }

  Future<void> addPostMessageToDb(Message message, String receiverUid) async {
    var map = message.toMaps();

    await _firestore
        .collection("users")
        .doc(message.receiverUid)
        .collection("messages")
        .doc(message.senderUid)
        .collection("messages")
        .add(map);

    return _firestore
        .collection("users")
        .doc(message.senderUid)
        .collection("messages")
        .doc(message.receiverUid)
        .collection("messages")
        .add(map);
  }

  Future<void> savePost(Map<String, dynamic> post, String currentuserId) async {
    await _firestore
        .collection("users")
        .doc(currentuserId)
        .collection("saved_posts")
        .add(post);
  }

  Future<List<DocumentSnapshot>> fetchFeed(auth.User user, int limit) async {
    List<String> followingUIDs = List<String>();
    List<DocumentSnapshot> list = List<DocumentSnapshot>();

    Query query = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("following")
        .limit(limit);
    QuerySnapshot querySnapshot = await query.get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id);
    }

    for (var i = 0; i < followingUIDs.length; i++) {
      //retrievePostByUID(followingUIDs[i]);
      // fetchUserDetailsById(followingUIDs[i]);
      Query posts = _firestore
          .collection("users")
          .doc(followingUIDs[i])
          .collection("posts")
          .orderBy("time")
          .limit(limit);
      QuerySnapshot postSnapshot = await posts.get();
      // postSnapshot.documents;
      for (var i = 0; i < postSnapshot.docs.length; i++) {
        list.add(postSnapshot.docs[i]);
      }
    }

    return list;
  }

  Future<List<String>> fetchFollowingUids(auth.User user, int limit) async {
    List<String> followingUIDs = List<String>();
    Query query = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("following")
        .limit(limit);
    QuerySnapshot querySnapshot = await query.get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id);
    }

    for (var i = 0; i < followingUIDs.length; i++) {}
    return followingUIDs;
  }

  Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .limit(40)
        .get();
    print('Activities retrieved ');
    print(userActivitiesSnapshot.docs.length);
    List<Activity> activity = userActivitiesSnapshot.docs
        .map((doc) => Activity.fromDoc(doc))
        .toList();
    print("It has been done");
    print(activity.length);
    return activity;
  }

  Future<User> getUserWithId(String userId) async {
    DocumentSnapshot userDocSnapshot =
        await _firestore.collection('users').doc(userId).get();
    if (userDocSnapshot.exists) {
      return User.fromDoc(userDocSnapshot);
    }
    return User();
  }

  Future<List<Post>> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnapshot = await _firestore
        .collection('posts')
        .doc(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts =
        userPostsSnapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
    return posts;
  }

  Future<DocumentSnapshot> getUserPost(String userId, String postId) async {
    DocumentSnapshot postDocSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('posts')
        .doc(postId)
        .get();
    return postDocSnapshot;
  }

  void addActivityItem(
      {String currentUserId,
      DocumentReference postRef,
      String comment,
      int type}) {
    postRef.get().then((doc) {
      if (currentUserId != doc['ownerUid']) {
        _firestore
            .collection('users')
            .doc(doc['ownerUid'])
            .collection('userActivities')
            .add({
          'postId': postRef.id,
          'comment': comment,
          'postImageUrl': doc['imgUrl'],
          'fromUserId': currentUserId,
          'userId': doc['ownerUid'],
          'timestamp': Timestamp.fromDate(DateTime.now()),
          'type': type,
        });
      }
    });
  }

  void addActivityPostItem(
      {String currentUserId,
      DocumentReference postRef,
      String comment,
      int type}) {
    postRef.get().then((doc) {
      if (currentUserId != doc['ownerUid']) {
        if (type == 1) {
          _firestore
              .collection('users')
              .doc(doc['ownerUid'])
              .collection('userActivities')
              .doc(doc['postID'])
              .collection('likes')
              .add({
            'postId': doc['postID'],
            'comment': comment,
            'postImageUrl': doc['imgUrl'],
            'fromUserId': currentUserId,
            'userId': doc['ownerUid'],
            'timestamp': Timestamp.fromDate(DateTime.now()),
            'type': type,
          });
        }
        if (type == 2) {
          _firestore
              .collection('users')
              .doc(doc['ownerUid'])
              .collection('userActivities')
              .doc(doc['postID'])
              .collection('comments')
              .add({
            'postId': doc['postID'],
            'comment': comment,
            'postImageUrl': doc['imgUrl'],
            'fromUserId': currentUserId,
            'userId': doc['ownerUid'],
            'timestamp': Timestamp.fromDate(DateTime.now()),
            'type': type,
          });
        }
        if (type == 3) {
          _firestore
              .collection('users')
              .doc(doc['ownerUid'])
              .collection('userActivities')
              .doc(doc['postID'])
              .collection('bolts')
              .add({
            'postId': doc['postID'],
            'comment': comment,
            'postImageUrl': doc['imgUrl'],
            'fromUserId': currentUserId,
            'userId': doc['ownerUid'],
            'timestamp': Timestamp.fromDate(DateTime.now()),
            'type': type,
          });
        }
        if (type == 4) {
          _firestore
              .collection('users')
              .doc(doc['ownerUid'])
              .collection('userActivities')
              .doc(doc['postID'])
              .collection('trendFollows')
              .add({
            'postId': doc['postID'],
            'comment': comment,
            'postImageUrl': doc['imgUrl'],
            'fromUserId': currentUserId,
            'userId': doc['ownerUid'],
            'timestamp': Timestamp.fromDate(DateTime.now()),
            'type': type,
          });
        }
        if (type == 6) {
          _firestore
              .collection('users')
              .doc(doc['ownerUid'])
              .collection('userActivities')
              .doc(doc['postID'])
              .collection('followers')
              .add({
            'postId': doc['postID'],
            'comment': comment,
            'postImageUrl': doc['imgUrl'],
            'fromUserId': currentUserId,
            'userId': doc['ownerUid'],
            'timestamp': Timestamp.fromDate(DateTime.now()),
            'type': type,
          });
        }
      }
    });
  }

  void addActivitiesItem({String currentUserId, String userID}) {
    _firestore
        .collection('users')
        .doc(userID)
        .collection('userActivities')
        .add({
      'postId': null,
      'comment': null,
      'postImageUrl': null,
      'fromUserId': currentUserId,
      'userId': userID,
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'type': 6,
    });
  }
}
