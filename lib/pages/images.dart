import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Images extends StatefulWidget {
  DocumentSnapshot myImages;
  Images({this.myImages});
  @override
  _ImagesState createState() => _ImagesState();
}

class _ImagesState extends State<Images> { 
//   void downloadImages(){
//     islandRef = storageRef.child("images/island.jpg");

// File localFile = File.createTempFile("images", "jpg");

// islandRef.getFile(localFile).addOnSuccessListener(new OnSuccessListener<FileDownloadTask.TaskSnapshot>() {
//     @Override
//     public void onSuccess(FileDownloadTask.TaskSnapshot taskSnapshot) {
//         // Local temp file has been created
//     }
// }).addOnFailureListener(new OnFailureListener() {
//     @Override
//     public void onFailure(@NonNull Exception exception) {
//         // Handle any errors
//     }
// });
//   } 
  @override
  Widget build(BuildContext context) {
    List list =widget.myImages.data['imageUrls'];
    return Container(
      child:Carousel(
      dotSize: 7.0,
      dotSpacing: 15.0,
      dotColor: Colors.lightGreenAccent,
      indicatorBgPadding: 5.0,
      dotBgColor: Colors.transparent,
      borderRadius: false,
      moveIndicatorFromBottom: 180.0,
      noRadiusForIndicator: true,
      overlayShadow: true,
      overlayShadowColors: Colors.green,
      overlayShadowSize: 0.7,
      autoplay: false,
      images: list.map((item) =>
      CachedNetworkImage(imageUrl: item.toString(),
      imageBuilder:(context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fitWidth)
        ),
      ),
      placeholder:  (context, url) => 
      Icon(Icons.image,size: MediaQuery.of(context).size.height/2,),
      errorWidget: (context, url, error) => Icon(Icons.error),),
        ).toList(),
    ),
    );
  }
}