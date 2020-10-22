//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:landlord/main.dart';
import 'package:landlord/pages/details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:landlord/pages/login.dart';

// ignore: must_be_immutable
class OwnerAds extends StatefulWidget {
  DocumentSnapshot posts;
  OwnerAds({this.posts});
  @override
  _OwnerAdsState createState() => _OwnerAdsState();
}

class _OwnerAdsState extends State<OwnerAds> {
  var stream;
navigateToDetail( DocumentSnapshot post) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Details(
                  posts: post,
    )));
  }

  _setupFeed() async{
      FirebaseAuth auth=FirebaseAuth.instance;
      FirebaseUser user=await auth.currentUser();
      final userId=user.uid;
    QuerySnapshot userData=await Firestore.instance.collection('users').where('authorId',isEqualTo: userId).getDocuments();
  }
  @override
  initState(){
    super.initState();
    _setupFeed();
  }

  void dispose(){
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: ()=>auth.signOut().then((value) => 
              Navigator.push(context, MaterialPageRoute(builder: (_)=>Login()))),
              child: Icon(Icons.power_settings_new)),
          )
        ],
        title: Text("My Ads"),
      ),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder:(BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
            if(snapshot.hasData){
              return StreamBuilder(
              stream: 
              //_setupFeed(),
               Firestore.instance
              .collection('posts')
              .where('authorId',isEqualTo: snapshot.data.uid)
              .snapshots(),
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.active){
                  // if(snapshot.hasData){
                    final posts = snapshot.data.documents;
                    List<Container> postWidgets = [];
                    for(var post in posts){
                      String image=post.data['imageUrls'].elementAt(0);
                        final postList=Container(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GestureDetector(
                                onTap: ()=>navigateToDetail(post),
                                child: Dismissible(
                                  key: ValueKey(AlertDialog),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction){},
                                    confirmDismiss: (direction) async{
                                      final result=await showDialog(
                                        context: context,
                                        builder: (_) =>AlertDialog(
                                          title: Text("Warning"),
                                          content: Text("Are you sure You want to delete?"),
                                          actions: [
                                            FlatButton(
                                              onPressed:(){
                                               Firestore
                                              .instance.collection('posts')
                                              .document(post.documentID)
                                              .delete();
                                              print('deleted');
                                              Navigator.pop(context);
                                              },
                                               child: Text('Yes')),
                                               FlatButton(
                                                 onPressed:()=> Navigator.pop(context),
                                                  child: Text('No'))
                                          ],
                                        ));
                                        return result;
                                    },
                                  background: Container(
                                   color: Colors.red,
                                    padding: EdgeInsets.only(left: 16),
                                    child: Align(
                                      child: Icon(Icons.delete,
                                      color: Colors.white
                                      ),
                                      alignment: Alignment.centerLeft,
                                    ), 
                                  ),
                                  child: Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      children: [
                                         Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width/3,
                                            height: MediaQuery.of(context).size.height/4.5,
                                           child: CachedNetworkImage(imageUrl: image,
                                           imageBuilder:(context, imageProvider) => Container(
                                             decoration: BoxDecoration(
                                               image: DecorationImage(
                                                 image: imageProvider,
                                                 fit: BoxFit.cover
                                               )),
                                           ),
                                           placeholder: (context, url) => Icon(Icons.image,size: 100,),
                                           errorWidget: (context, url, error) => Icon(Icons.error),)
                                          ),
                                          SizedBox(width: 10,),
                                          Column(
                                            //mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                               child: Row(
                                                 //mainAxisAlignment: MainAxisAlignment.start,
                                                 children: [
                                                   Text(post.data['category'],style: GoogleFonts.robotoSlab(
                                                    textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                                                  ),),
                                                 ],
                                               ), 
                                              ),
                                              Row(
                                               children: [
                                                 Icon(Icons.bookmark_border,color: Color(0xFF80E1D1),),
                                                 SizedBox(width: 5,),
                                                 Text(post.data['price'],style: 
                                                 TextStyle(fontWeight: FontWeight.w500,color: Color(0xFF80E1D1)),),
                                                 SizedBox(width: 2,),
                                                 Text(post.data['currency'],style: 
                                                 TextStyle(fontWeight: FontWeight.w500,color: Color(0xFF80E1D1)))
                                               ], 
                                              ),
                                              SizedBox(height: 20,),
                                              Text(DateFormat.yMMMMd().add_jm().format(post.data['timestamp'].toDate()),maxLines: 20,
                                             style: TextStyle(color: Colors.grey,fontSize: 12,fontWeight: FontWeight.w500)),
                                             Divider(),
                                             Row(
                                               children: [
                                                 Text("Uploader",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500),),
                                                 SizedBox(width: 10,),
                                                 Text(post.data['name'],style:
                                                  TextStyle(color: Color(0xFF80E1D1),fontWeight: FontWeight.w500))
                                               ],
                                             ),
                                            ],
                                          ),
                                          Container(
                                           child: Row(
                                             children: [
                                               IconButton(
                                                 icon: Icon(Icons.delete),
                                                 onPressed: ()=>showDialog(
                                                   context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text("Warning",style: TextStyle(color: Color(0xFFFFC107)),),
                                          content: Text("Are you sure You want to delete?"),
                                          actions: [
                                            FlatButton(
                                              onPressed:(){
                                               Firestore
                                              .instance.collection('posts')
                                              .document(post.documentID)
                                              .delete();
                                              print('deleted');
                                              Navigator.pop(context);
                                              },
                                               child: Text('Yes',style: TextStyle(color: Color(0xFFFFC107)))),
                                               FlatButton(
                                                   onPressed:()=> Navigator.pop(context),
                                                    child: Text('No',style: TextStyle(color: Color(0xFFFFC107))))
                                          ],
                                        ),
                                                 ))
                                             ],
                                           ), 
                                          )
                                        ],
                                      ),
                                      Divider()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      );
                      postWidgets.add(postList);
                    } return ListView(
                      children: postWidgets
                    );
                }else if(snapshot.connectionState==ConnectionState.waiting){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading....")
                      ],
                    ),
                  );
                }
              });
            }else if(snapshot.data == null ){
              return Center(
                    child: Text('Ooops No data found')
                  );
            }
          }
        ),
      );
  }
}