//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:landlord/pages/cart-details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:landlord/service/database.dart';

// ignore: must_be_immutable
class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  var stream;
  bool saved=false;
  String currentUser;

  @override
  initState(){
    super.initState();
  }

  void dispose(){
    super.dispose();
  }
    navigateToCartDetail( DocumentSnapshot post) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CartDetails(
                      carter: post,
        )));
      }
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.add_shopping_cart),
            Text('Cart')
          ],
        ),
      ),
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder:(BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
            if(snapshot.hasData){
              return StreamBuilder(
              stream:Firestore.instance
              .collection('Cart')
              .document(snapshot.data.uid)
              .collection('userCart')
              .orderBy('addedAt',descending: true)
              .snapshots(),
              builder: (context, snapshot){
                // if(snapshot.connectionState==ConnectionState.active){
                   if(snapshot.hasData){
                    final posts = snapshot.data.documents;
                    List<Container> postWidgets = [];
                    for(var post in posts){
                      String image=post.data['imageUrls'].elementAt(0);
                        final postList=Container(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GestureDetector(
                                onTap: ()=>navigateToCartDetail(post),
                                child: Dismissible(
                                  key: ValueKey(AlertDialog),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction){},
                                    confirmDismiss: (direction) async{
                                      FirebaseAuth auth=FirebaseAuth.instance;
                                      FirebaseUser user=await auth.currentUser();
                                      final userId=user.uid;
                                      final result=await showDialog(
                                        context: context,
                                        builder: (_) =>AlertDialog(
                                          title: Text("Warning"),
                                          content: Text("Are you sure You want to delete?"),
                                          actions: [
                                            FlatButton(
                                              onPressed:(){
                                               Firestore
                                              .instance.collection('Cart')
                                              .document(userId)
                                              .collection('userCart')
                                              .document(post.data['postId'])
                                              .get().then((doc){
                                              if(doc.exists){
                                                doc.reference.delete();
                                              }
                                            });
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
                                           child: Card(
                                             child: CachedNetworkImage(imageUrl: image,
                                             imageBuilder:(context, imageProvider) => Container(
                                               decoration: BoxDecoration(
                                                 image: DecorationImage(
                                                   image: imageProvider,
                                                   fit: BoxFit.cover
                                                 )),
                                             ),
                                             placeholder: (context, url) => Icon(Icons.image,size: 100,),
                                             errorWidget: (context, url, error) => Icon(Icons.error),),
                                           )
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
                                                   SizedBox(width: 3,),
                                                   Text('For',style: GoogleFonts.robotoSlab(
                                                    textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                                                  )),
                                                      SizedBox(width: 3,),
                                                   Text(post.data['purpose'],style: GoogleFonts.robotoSlab(
                                                    textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                                                  ))
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
                                                 Text('TZS',style: 
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
                                                  TextStyle(color: Color(0xFF80E1D1),fontWeight: FontWeight.w500)),
                                               ],
                                             ),
                                            ],
                                          ),
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
            }else if(!snapshot.hasData){
              return Center(
                child:Text('No Data found')
              );
            }
          }
        ),
      );
  }
}