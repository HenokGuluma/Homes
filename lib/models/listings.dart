import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  String userID;
  List<dynamic> images;
  String listingID;
  String additionalNotes;
  String area;
  int time;
  String listingOwnerName;
  String listingOwnerPhotoUrl;
  String listingOwnerEmail;
  String listingOwnerPhone;
  String listingType;
  String listingDescription;
  int likeCount;
  int reviewCount;
  String rentCollection;
  String cost;
  String floor;
  String commonLocation;
  String preciseLocation;
  String emailAddress;
  String phoneNumber;
  bool isActive;
  bool isReviewed;
  bool approved;
  String forRent;

  Listing(
      {this.userID,
      this.images,
      this.listingID,
      this.additionalNotes,
      this.area,
      this.time,
      this.forRent,
      this.listingOwnerName,
      this.listingOwnerPhotoUrl,
      this.listingOwnerEmail,
      this.listingOwnerPhone,
      this.listingType,
      this.likeCount,
      this.reviewCount,
      this.rentCollection,
      this.cost,
      this.floor,
      this.commonLocation,
      this.preciseLocation,
      this.emailAddress,
      this.phoneNumber,
      this.isActive,
      this.approved,
      this.listingDescription,
      this.isReviewed});

  Map toMap(Listing listing) {
    var data = Map<String, dynamic>();
    data['userID'] = listing.userID;
    data['images'] = listing.images;
    data['listingID'] = listing.listingID;
    data['additionalNotes'] = listing.additionalNotes;
    data['area'] = listing.area;
    data['time'] = listing.time;
    data['floor'] = listing.floor;
    data['listingOwnerName'] = listing.listingOwnerName;
    data['listingOwnerPhotoUrl'] = listing.listingOwnerPhotoUrl;
    data['listingOwnerEmail'] = listing.listingOwnerEmail;
    data['listingOwnerPhone'] = listing.listingOwnerPhone;
    data['listingType'] = listing.listingType;
    data['listingDescription'] = listing.listingDescription;
    data['likeCount'] = listing.likeCount;
    data['reviewCount'] = listing.reviewCount;
    data['rentCollection'] = listing.rentCollection;
    data['cost'] = listing.cost;
    data['commonLocation'] = listing.commonLocation;
    data['preciseLocation'] = listing.preciseLocation;
    data['phoneNumber'] = listing.phoneNumber;
    data['emailAddress'] = listing.emailAddress;
    data['isActive'] = listing.isActive;
    data['approved'] = listing.approved;
    data['isReviewed'] = listing.isReviewed;
    data['forRent'] = listing.forRent;

    return data;
  }
}
