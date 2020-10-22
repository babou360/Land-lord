import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:landlord/models/post.dart';
import 'package:landlord/models/user.dart';

class DatabaseService{
    static void createPost(Post post){
    //postRef.document(post.authorId).collection('usersPosts').add({
      Firestore.instance.collection('posts').add({
      'imageUrls': post.imageUrls,
      'saved': post.saved,
      'currency': post.currency,
      'code': post.code,
      'descrption':post.description,
      'name': post.name,
      'email':post.email,
      'authorId':post.authorId,
      'price': post.price,
      'region':post.region,
      'phone': post.phone,
      'category': post.category,
      'purpose': post.purpose,
      'addedAt': post.addedAt,
      'timestamp':post.timestamp
    });
  }
     static Future<List<Post>> getUserData() async{
      // FirebaseAuth auth=FirebaseAuth.instance;
      // FirebaseUser user=await auth.currentUser();
      // final userId=user.uid;
     QuerySnapshot feedSnapShot=await 
     Firestore
     .instance
     .collection('posts')
     .getDocuments();
     List<Post> posts=
    //  feedSnapShot.documents.map((doc) => Post.fromDoc(doc));
     feedSnapShot.documents.map((doc)=>Post.fromDoc(doc)).toList();
     return posts;
   }
   static Future<List<User>> getUser(String currentUserId) async{
     QuerySnapshot userSnapShot=await 
     Firestore
     .instance
     .collection('users')
     .where('authorId',isEqualTo: currentUserId)
     .getDocuments();
     List<User> users=
     userSnapShot.documents.map((doc)=>User.fromDoc(doc)).toList();
     return users;
   }
   static Future<List<Post>> getCurrentPosts(String currentUserId) async{
     QuerySnapshot userSnapShot=await 
     Firestore
     .instance
     .collection('posts')
     .where('authorId',isEqualTo: currentUserId)
     .getDocuments();
     List<Post> posts=
     userSnapShot.documents.map((doc)=>Post.fromDoc(doc)).toList();
     return posts;
   }

   static Future<bool> isSaved(String userId,String postId) async{
    DocumentSnapshot savedDoc=await Firestore.instance.collection('Cart')
    .document(userId)
    .collection('userCart')
    .document(postId)
    .get();
    return savedDoc.exists;
  }

  static void save(String userId,String postId){
    Firestore.instance.collection('Cart')
    .document(userId)
    .collection('userCart')
    .document(postId)
    .setData({});
  }

  static void unsave(String userId,String postId){
    Firestore.instance.collection('Cart')
    .document(userId)
    .collection('userCart')
    .document(postId)
    .get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }
}