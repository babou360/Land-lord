import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String authorId;
  final bool saved;
  final String code;
  final String currency;
  final String description;
  final String email;
  final List imageUrls;
  final String phone;
  final String price;
  final String region;
  final String district;
  final String ward;
  final String street;
  final String category;
  final String purpose;
  final String name;
  final Timestamp addedAt;
  final Timestamp timestamp;
  

  Post({
  this.email,
  this.addedAt,
  this.saved,
  this.code,
  this.currency,
  this.purpose,
  this.price,
  this.phone,
  this.category,
  this.region,
  this.district,
  this.ward,
  this.street,
  this.name,
  this.description,
  this.authorId,
  this.imageUrls,
  this.timestamp
  });
  factory Post.fromDoc(DocumentSnapshot doc){
    return Post(
      authorId: doc.documentID,
      currency: doc['currency'],
      addedAt: doc['addedAt'],
      saved: doc['saved'],
      code: doc['code'],
      imageUrls: doc['imageUrls'],
      email: doc['email'],
      description: doc['description'],
      name: doc['name'],
      region: doc['region'],
      district: doc['district'],
      ward: doc['ward'],
      street: doc['street'],
      timestamp: doc['timestamp'],
      purpose: doc['for'],
      price: doc['price'],
      phone: doc['phone'],
      category: doc['category'],
    );
  }
}