import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String authorId;
  final String password;
  final String name;
  final String email;
  final String profileImage;
  final Timestamp timestamp;
  

  User({
  this.email,
  this.authorId,
  this.profileImage,
  this.password,
  this.name,
  this.timestamp
  });
  factory User.fromDoc(DocumentSnapshot doc){
    return User(
      authorId: doc.documentID,
      email: doc['email'],
      name: doc['name'],
      password: doc['name'],
      profileImage: doc['name'],
      timestamp: doc['timestamp'],
    );
  }
}