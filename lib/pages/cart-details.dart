
import 'dart:math';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landlord/pages/cart.dart';
import 'package:landlord/pages/images.dart';
import 'package:landlord/pages/my-ads.dart';
import 'package:landlord/service/database.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class CartDetails extends StatefulWidget {
   DocumentSnapshot carter;
   CartDetails({Key key, this.carter}) : super(key: key);
  @override
  _CartDetailsState createState() => _CartDetailsState();
}

class _CartDetailsState extends State<CartDetails> {
  String image;
  bool saved=false;
  String currentUser;
  var random=new Random();
  String time;

  @override
  void initState() {
    super.initState();
    _isSaved();
    // save();
    // unsave();
  }
    save() async{
      FirebaseAuth auth=FirebaseAuth.instance;
     FirebaseUser user=await auth.currentUser();
     final userId=user.uid;
      Firestore.instance.collection("Cart")
      .document(userId)
      .collection('userCart')
      .document(widget.carter.documentID)
      .setData({
        'postId':widget.carter.documentID,
        'authorId':widget.carter.data['authorId'],
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'price': widget.carter.data['price'],
        'currency': widget.carter.data['currency'],
        'purpose': widget.carter.data['purpose'],
        'name':widget.carter.data['name'],
        'category':widget.carter.data['category'],
        'code':widget.carter.data['code'],
        'imageUrls':widget.carter.data['imageUrls'],
        'addedAt': Timestamp.fromDate(DateTime.now())
      });
      setState(() {
        saved=true;
      });
    }
    unsave() async{
    FirebaseAuth auth=FirebaseAuth.instance;
    FirebaseUser user=await auth.currentUser();
    final userId=user.uid;
      Firestore.instance.collection('Cart')
    .document(userId)
    .collection('userCart')
    .document(widget.carter.documentID)
    .get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
      setState(() {
        saved=false;
      });
    }
  @override
  // ignore: override_on_non_overriding_member
  navigatetoImages(){
    Navigator.push(context, MaterialPageRoute(builder: (_)=>Images(
      myImages: widget.carter,
    )));
  }

   _isSaved() async{
     FirebaseAuth auth=FirebaseAuth.instance;
     FirebaseUser user=await auth.currentUser();
     final userId=user.uid;
     bool isSavedPost=await DatabaseService.isSaved(userId,widget.carter.documentID);
     setState(() {
       saved=isSavedPost;
     });
   }

  Widget build(BuildContext context) {
    List list =widget.carter.data['imageUrls'];
    String phone=widget.carter.data['phone'];
    String code=widget.carter.data['code'];
    String mail=widget.carter.data['email'];
    String phone1 = code==null? "+255" + phone: code+phone;

     _textMe() async {
    // Android
    String uri = 'sms:${(phone1)}?body=hello%20there';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      const uri = 'sms:0039-222-060-888';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }
    call() async {
  // String url = 'tel:${(code)}${(phone)}';
  String url = 'tel:${(phone1)}';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
    email() async {
  String url = 'mailto: ${(mail)}';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
               expandedHeight: 400,
              //expandedHeight: MediaQuery.of(context).size.height/2,
               flexibleSpace: FlexibleSpaceBar(
                 centerTitle: false,
                //Text("Details",style: TextStyle(color: Colors.white),), 
                background: GestureDetector(
                  onTap: ()=>navigatetoImages(),
                  child: Container(
                    child: Carousel(
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
                            fit: BoxFit.cover)
                        ),
                      ),
                      placeholder:  (context, url) => 
                      Icon(Icons.image,size: MediaQuery.of(context).size.height/2,),
                      errorWidget: (context, url, error) => Icon(Icons.error),),
                       ).toList(),
                    ),
                  ),
                ),
               ),
              ),
              SliverFillRemaining(
               child: SingleChildScrollView(
                 child: Container(
                   child: Column(
                    children: [
                      SizedBox(height: 10,),
                      Padding(padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width/1.5,
                            child:saved
                            ?Text("Saved")
                            :Text("Save")
                          ),
                          Container(
                           child: saved
                           ?IconButton(
                             icon: Icon(Icons.bookmark,color: Colors.black),
                             onPressed: ()=> unsave()
                          ):IconButton(
                             icon: Icon(Icons.bookmark_border),
                             onPressed: ()=> save()
                          )
                          //       // var jobskillQuery = Firestore.instance.collection('userCart')
                          //       // .where('carter',isEqualTo: userId);
                          //       //     jobskillQuery.getDocuments().then((value) => {
                          //       //       value.documents.forEach((doc) {
                          //       //         doc.reference.delete();
                          //       //        })
                          //       //     });
                          //       //     print(widget.carter.data['addedAt']);
                          //     })
                          //   ),
                          )],
                      )),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(widget.carter.data['descrption'],
                          style: TextStyle(color: Colors.black54,fontSize: 17,fontWeight: FontWeight.w500)),
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.5,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 8),
                               child: Text('Category',
                               style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.w500),),
                             ), 
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                width: MediaQuery.of(context).size.width*0.5,
                               child: Text(widget.carter.data['category'],maxLines: 20,
                               style: TextStyle(color: Color(0xFF80E1D1),fontSize: 20,fontWeight: FontWeight.w500)), 
                              ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.5,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 8),
                               child: Text('Location',
                               style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.w500),),
                             ), 
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width*0.5,
                               child: Row(
                                 children: [
                                  Icon(Icons.location_on,color: Color(0xFF80E1D1),),
                                  Text(widget.carter.data['region'],maxLines: 20,
                                 style: TextStyle(color: Color(0xFF80E1D1),fontSize: 20,fontWeight: FontWeight.w500)),
                                 ],
                               ), 
                          ),
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.5,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 8),
                               child: Text('Price',
                               style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.w500),),
                             ), 
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width*0.5,
                               child: Row(
                                 children: [
                                  Icon(Icons.bookmark_border,color: Color(0xFF80E1D1),),
                                  Text(widget.carter.data['price'],maxLines: 20,
                                 style: TextStyle(color: Color(0xFF80E1D1),fontSize: 20,fontWeight: FontWeight.w500)),
                                 SizedBox(width: 3,),
                                 Text(widget.carter.data['currency'],
                                 style: TextStyle(color: Color(0xFF80E1D1),fontSize: 20,fontWeight: FontWeight.w500))
                                 ],
                               ), 
                          ),
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.5,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 8),
                               child: Text('For',
                               style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.w500),),
                             ), 
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width*0.5,
                               child: Row(
                                 children: [
                                  //Icon(Icons.location_on),
                                  Text(widget.carter.data['purpose'],maxLines: 20,
                                 style: TextStyle(color: Color(0xFF80E1D1),fontSize: 20,fontWeight: FontWeight.w500)),
                                 ],
                               ), 
                          ),
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.5,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 8),
                               child: Text('Published on',
                               style: TextStyle(color: Colors.grey,fontSize: 20,fontWeight: FontWeight.w500),),
                             ), 
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width*0.5,
                               child: Row(
                                 children: [
                                  Text(DateFormat.yMMMMd().add_jm().format(widget.carter.data['timestamp'].toDate()),maxLines: 20,
                                 style: TextStyle(color: Color(0xFF80E1D1),fontSize: 12,fontWeight: FontWeight.w500)),
                                 ],
                               ), 
                          ),
                          ],
                        ),
                      ),
                      //Text(widget.carter.data['price'])
                    ], 
                   ),
                 ),
               ), 
              )
            ],
          ),
        ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
           children: [
            GestureDetector(
              onTap: ()=>call(),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/4,
                color: Colors.yellow,
                child: Text('Call',
                style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500)),
              ),
            ),
            GestureDetector(
              onTap: ()=>_textMe(),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/4,
                color: Colors.yellow[800],
                child: Text('Message',
                style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w500)),
              ),
            ), 
            GestureDetector(
              onTap: ()=>email(),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/4,
                color: Colors.yellow,
                child: Text('Email',
                style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500)),
              ),
            ),
            GestureDetector(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>Cart())),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/4,
                color: Colors.yellow[800],
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart,color: Colors.black,size: 40,),
                    FutureBuilder(
                      future: FirebaseAuth.instance.currentUser(),
                      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
                        if(snapshot.hasData){
                          return  StreamBuilder(
                       stream: Firestore.instance.collection('Cart').document(snapshot.data.uid).collection('userCart').snapshots(),
                       builder: (context, snapshot){
                         if(snapshot.hasData){
                           return Text(snapshot.data.documents.length.toString(),style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold ),);
                         }else{
                           return SizedBox.shrink();
                         }
                       });
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    )
                  ],)
              ),
            ),
           ], 
          ),
        ),
      ),
    );
  }
}