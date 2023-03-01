import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
//import 'package:fluttericon/elusive_icons.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/firebase_provider.dart';
import 'package:instagram_clone/models/activity_model.dart';

class Repository {
  final _firebaseProvider = FirebaseProvider();

  Future<void> addDataToDb(auth.User user) =>
      _firebaseProvider.addDataToDb(user);

  Future<auth.User> signIn() => _firebaseProvider.signIn();

  Future<bool> authenticateUser(auth.User user) =>
      _firebaseProvider.authenticateUser(user);

  Future<auth.User> getCurrentUser() => _firebaseProvider.getCurrentUser();

  Future<void> signOut() => _firebaseProvider.signOut();

  Future<String> uploadImageToStorage(File imageFile) =>
      _firebaseProvider.uploadImageToStorage(imageFile);

  Future<String> uploadImagesToStorage(Uint8List imageFile) =>
      _firebaseProvider.uploadImagesToStorage(imageFile);

  Future<String> uploadVideoToStorage(File imageFile) =>
      _firebaseProvider.uploadVideoToStorage(imageFile);

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
  ) =>
      _firebaseProvider.addListingToDb(
          images,
          userID,
          additionalNotes,
          area,
          listingOwnerName,
          listingOwnerPhotoUrl,
          listingOwnerEmail,
          listingOwnerPhone,
          listingType,
          listingDescription,
          forRent,
          rentCollection,
          cost,
          floor,
          commonLocation,
          preciseLocation,
          isActive);

  Future<void> deleteListing(
    String userID,
    String id,
  ) =>
      _firebaseProvider.deleteListing(userID, id);

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
  ) =>
      _firebaseProvider.modifyListing(
          images,
          userID,
          additionalNotes,
          area,
          listingOwnerName,
          listingOwnerPhotoUrl,
          listingOwnerEmail,
          listingOwnerPhone,
          listingType,
          listingDescription,
          forRent,
          rentCollection,
          cost,
          floor,
          commonLocation,
          preciseLocation,
          isActive,
          updateImages,
          id);

  Future<DocumentReference> addPicturePostToDb(
          User currentUser,
          String imgUrl,
          String thumbnailUrl,
          String caption,
          String location,
          int initial,
          double aspectRatio) =>
      _firebaseProvider.addPicturePostToDb(currentUser, imgUrl, thumbnailUrl,
          caption, location, initial, aspectRatio);

  Future<DocumentReference> addPictureTrendPostToDb(
          User currentUser,
          String imgUrl,
          String thumbnailUrl,
          String trendOwner,
          String caption,
          String location,
          int initial,
          DocumentReference reference,
          double aspectRatio) =>
      _firebaseProvider.addPictureTrendPostToDb(
          currentUser,
          imgUrl,
          thumbnailUrl,
          trendOwner,
          caption,
          location,
          initial,
          reference,
          aspectRatio);

  Future<DocumentReference> addVideoTrendPostToDb(
          User currentUser,
          String imgUrl,
          String thumbnailUrl,
          String trendOwner,
          String caption,
          String location,
          int initial,
          DocumentReference reference,
          double aspectRatio) =>
      _firebaseProvider.addVideoTrendPostToDb(currentUser, imgUrl, thumbnailUrl,
          trendOwner, caption, location, initial, reference, aspectRatio);

  Future<DocumentReference> addTextTrendPostToDb(
          User currentUser,
          String imgUrl,
          String thumbnailUrl,
          String trendOwner,
          String caption,
          String location,
          int initial,
          DocumentReference reference,
          double aspectRatio) =>
      _firebaseProvider.addTextTrendPostToDb(currentUser, imgUrl, thumbnailUrl,
          trendOwner, caption, location, initial, reference, aspectRatio);

  Future<DocumentReference> addTextPostToDb(
          User currentUser,
          String caption,
          int initial,
          String trendOwner,
          DocumentReference reference,
          bool original) =>
      _firebaseProvider.addTextPostToDb(
          currentUser, caption, initial, trendOwner, reference, original);

  Future<DocumentReference> addVideoPostToDb(
          User currentUser,
          String imgUrl,
          String thumbnailUrl,
          String caption,
          String location,
          int initial,
          double aspectRatio) =>
      _firebaseProvider.addVideoPostToDb(currentUser, imgUrl, thumbnailUrl,
          caption, location, initial, aspectRatio);

  Future<User> retrieveUserDetails(auth.User user) =>
      _firebaseProvider.retrieveUserDetails(user);

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) =>
      _firebaseProvider.retrieveUserPosts(userId);

  Future<List<DocumentSnapshot>> retrieveUserPhotoPosts(String userId) =>
      _firebaseProvider.retrieveUserPhotoPosts(userId);

  Future<List<DocumentSnapshot>> retrieveUserTextPosts(String userId) =>
      _firebaseProvider.retrieveUserTextPosts(userId);

  Future<List<DocumentSnapshot>> retrieveUserVideoPosts(String userId) =>
      _firebaseProvider.retrieveUserVideoPosts(userId);

  Future<List<DocumentSnapshot>> retrieveUserSavedPosts(String userId) =>
      _firebaseProvider.retrieveUserSavedPosts(userId);

  Future<List<DocumentSnapshot>> fetchPostComments(
          DocumentReference reference) =>
      _firebaseProvider.fetchPostCommentDetails(reference);

  Future<List<DocumentSnapshot>> getListings() =>
      _firebaseProvider.getListings();

  Future<List<DocumentSnapshot>> getSearchListings() =>
      _firebaseProvider.getSearchListings();

  Future<List<DocumentSnapshot>> getMoreSearchListings(var startAfter) =>
      _firebaseProvider.getMoreSearchListings(startAfter);

  Future<List<DocumentSnapshot>> getSearchFieldListings(String field, dynamic value) =>
      _firebaseProvider.getSearchFieldListings(field, value);

  Future<List<DocumentSnapshot>> getMoreSearchFieldListings(String field, dynamic value, var startAfter) =>
      _firebaseProvider.getMoreSearchFieldListings(field, value, startAfter);

   Future<List<dynamic>> getAllPhones() =>
      _firebaseProvider.getAllPhones();

  Future<int> appVersion() => _firebaseProvider.appVersion();

   void addPhone(String phone, String userId) =>
      _firebaseProvider.addPhone(phone, userId);

  Future<DocumentSnapshot> getListingDetails(String reference) =>
      _firebaseProvider.getListingDetails(reference);

  Future<List<DocumentSnapshot>> getMoreListings(var startAfter) =>
      _firebaseProvider.getMoreListings(startAfter);

  void addOrder(User user, int amount, int price, String remark, bool telebirr) =>
      _firebaseProvider.addOrder(user, amount, price, remark, telebirr);

  void modifyOrder(User user, int amount, int price, String remark, String docId, bool telebirr)=>
      _firebaseProvider.modifyOrder(user, amount, price, remark, docId, telebirr);
  
  void cancelOrder(User user, String docId) =>
      _firebaseProvider.cancelOrder(user, docId);

  Future<DocumentSnapshot> getListingWithId(String id) =>
      _firebaseProvider.getListingWithId(id);

   Future<List<DocumentSnapshot>> getOrderHistory(String userId) =>
      _firebaseProvider.getOrderHistory(userId);

  Future<List<DocumentSnapshot>> getPendingOrders(String userId) =>
      _firebaseProvider.getPendingOrders(userId);

  Future<List<DocumentSnapshot>> getOwnListings(String userId) =>
      _firebaseProvider.getOwnListings(userId);

  Future<List<DocumentSnapshot>> getNotifications(String userId) =>
      _firebaseProvider.getNotifications(userId);

  Future<List<DocumentSnapshot>> fetchPostLikes(DocumentReference reference) =>
      _firebaseProvider.fetchPostLikeDetails(reference);

  Future<List<DocumentSnapshot>> retrievePosts(auth.User user) =>
      _firebaseProvider.retrievePosts(user);

  Future<List<DocumentSnapshot>> retrieveTopPosts(auth.User user) =>
      _firebaseProvider.retrieveTopPosts(user);

  Future<void> unlockListing(String listing, String userId) =>
      _firebaseProvider.unlockListing(listing, userId);

  Future<List<DocumentSnapshot>> getUnlockedListings(String userId) =>
      _firebaseProvider.getUnlockedListings(userId);

  Future<List<String>> fetchAllUserNames(auth.User user) =>
      _firebaseProvider.fetchAllUserNames(user);

  Future<String> fetchUidBySearchedName(String name) =>
      _firebaseProvider.fetchUidBySearchedName(name);

  Future<User> fetchUserDetailsById(String uid) =>
      _firebaseProvider.fetchUserDetailsById(uid);

  Future<void> followUser({String currentUserId, String followingUserId}) =>
      _firebaseProvider.followUser(
          currentUserId: currentUserId, followingUserId: followingUserId);

  Future<void> unFollowUser({String currentUserId, String followingUserId}) =>
      _firebaseProvider.unFollowUser(
          currentUserId: currentUserId, followingUserId: followingUserId);

  Future<bool> checkIsFollowing(String name, String currentUserId) =>
      _firebaseProvider.checkIsFollowing(name, currentUserId);

  Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) =>
      _firebaseProvider.fetchStats(uid: uid, label: label);

  Future<void> updatePhoto(String photoUrl, String uid) =>
      _firebaseProvider.updatePhoto(photoUrl, uid);

  Future<void> updateDetails(
          String uid, String name, String bio, String email, String phone) =>
      _firebaseProvider.updateDetails(uid, name, bio, email, phone);

  Future<List<String>> fetchUserNames(auth.User user) =>
      _firebaseProvider.fetchUserNames(user);

  Future<List<User>> fetchAllUsers(auth.User user) =>
      _firebaseProvider.fetchAllUsers(user);

  Future<List<User>> fetchSuggestedUsers(auth.User user) =>
      _firebaseProvider.fetchSuggestedUsers(user);

  Future<List<User>> getTopUsers(auth.User user) =>
      _firebaseProvider.getTopUsers(user);

  void uploadImageMsgToDb(String url, String receiverUid, String senderuid) =>
      _firebaseProvider.uploadImageMsgToDb(url, receiverUid, senderuid);

  Future<void> addMessageToDb(Message message, String receiverUid) =>
      _firebaseProvider.addMessageToDb(message, receiverUid);

  Future<void> addPostMessageToDb(Message message, String receiverUid) =>
      _firebaseProvider.addPostMessageToDb(message, receiverUid);

  Future<void> savePost(Map<String, dynamic> post, String currentuserId) =>
      _firebaseProvider.savePost(post, currentuserId);

  Future<List<DocumentSnapshot>> fetchFeed(auth.User user, int limit) =>
      _firebaseProvider.fetchFeed(user, limit);

  Future<List<String>> fetchFollowingUids(auth.User user, int limit) =>
      _firebaseProvider.fetchFollowingUids(user, limit);

  //Future<List<DocumentSnapshot>> retrievePostByUID(String uid) => _firebaseProvider.retrievePostByUID(uid);
  Future<List<Activity>> getActivities(String userId) =>
      _firebaseProvider.getActivities(userId);

  Future<User> getUserWithId(String userId) =>
      _firebaseProvider.getUserWithId(userId);

  Future<List<Post>> getUserPosts(String userId) =>
      _firebaseProvider.getUserPosts(userId);

  Future<DocumentSnapshot> getUserPost(String userId, String postId) =>
      _firebaseProvider.getUserPost(userId, postId);

  void likeListing(String currentUserId, DocumentSnapshot postRef) =>
      _firebaseProvider.likeListing(postRef, currentUserId);

  void unlikeListing(String currentUserId, DocumentSnapshot postRef) =>
      _firebaseProvider.unlikeListing(postRef, currentUserId);

  void likePost(String currentUserId, DocumentSnapshot postRef) =>
      _firebaseProvider.likePost(currentUserId, postRef);

  void unlikePost(String currentUserId, DocumentSnapshot postSnap) =>
      _firebaseProvider.unlikePost(currentUserId, postSnap);

  Future<List<DocumentSnapshot>> getLikedListings(String userId) =>
      _firebaseProvider.getLikedListings(userId);

  Future<bool> didLikePost(String currentUserId, DocumentReference postRef) =>
      _firebaseProvider.didLikePost(currentUserId, postRef);

  void boltPost(String currentUserId, DocumentSnapshot postRef) =>
      _firebaseProvider.boltPost(currentUserId, postRef);

  void unboltPost(String currentUserId, DocumentSnapshot postSnap) =>
      _firebaseProvider.unboltPost(currentUserId, postSnap);

  Future<bool> didBoltPost(String currentUserId, DocumentReference postRef) =>
      _firebaseProvider.didBoltPost(currentUserId, postRef);

  void commentOnPost(User currentUserId, DocumentReference postRef,
          String comment, String imgUrl) =>
      _firebaseProvider.commentOnPost(currentUserId, postRef, comment, imgUrl);

  void followTrend(
          String currentUserId, DocumentReference postRef, Post trendFollow) =>
      _firebaseProvider.followTrend(currentUserId, postRef, trendFollow);

  void followPictureTrend(User currentUser, DocumentReference postRef,
          DocumentReference trendFollow) =>
      _firebaseProvider.followPictureTrend(currentUser, postRef, trendFollow);

  void followVideoTrend(
          User currentUser, DocumentReference postRef, DocumentReference ref) =>
      _firebaseProvider.followVideoTrend(currentUser, postRef, ref);

  void followTextTrend(User currentUser, DocumentReference postRef,
          DocumentReference trendFollow) =>
      _firebaseProvider.followTextTrend(currentUser, postRef, trendFollow);

  void unfollowTrend(String currentUserId, DocumentReference postRef,
          DocumentReference trendFollow) =>
      _firebaseProvider.unfollowTrend(currentUserId, postRef, trendFollow);

  void deletePost(DocumentReference postRef, String user) =>
      _firebaseProvider.deletePost(postRef, user);

  int calculateTrending(int likeCount, int commentCount, int boltCount,
          int trendCount, int initial) =>
      _firebaseProvider.calculateTrending(
          likeCount, commentCount, boltCount, trendCount, initial);

  void updateTrending(
          int oldtrending, int newtrending, DocumentReference postRef) =>
      _firebaseProvider.updateTrending(oldtrending, newtrending, postRef);
}
