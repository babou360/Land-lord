//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:landlord/main.dart';
import 'package:landlord/pages/cart.dart';
import 'package:landlord/pages/details.dart';
import 'package:landlord/pages/login.dart';
import 'package:landlord/pages/my-ads.dart';
import 'package:landlord/pages/owner-ads.dart';
import 'package:landlord/pages/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>  {
  List<String> regions = [
   'All', 'Arusha','Dar-es-salam'
  ,'Manyara','Kilimanjaro','Kigoma'
  ,'Tabora','Pwani','Lindi'
  ,'Mtwara','Ruvuma','Morogoro'
  ,'Tanga','Dodoma','Singida'
  ,'Mbeya','Iringa','Mara'
  ,'Zanzibar','Kagera','Shinyanga'
  ,'Simiyu','Rukwa','Njombe'
  ,'Katavi','Geita','Mwanza'
  ];
  String _selectedRegions;
  Stream stream;
  bool isSearch=true;
   
   Stream<QuerySnapshot> getData(){
      if(_selectedRegions=='All'){
       return Firestore.instance.collection('posts').orderBy('timestamp',descending: true).snapshots();
      }else if(_selectedRegions!=null){
       return  Firestore.instance.collection('posts')
       .orderBy('timestamp',descending: true)
        .where('region',isEqualTo: _selectedRegions)
        .snapshots(); 
      }else if(_selectedRegions==null){
        return Firestore.instance.collection('posts').orderBy('timestamp',descending: true).snapshots();
      }else{
        return null;
      }
    }
   Future<bool> _onBackPressed() {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to exit an App'),
              actions: <Widget>[
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            );
          },
        ) ?? false;
      }
navigateToDetail( DocumentSnapshot post) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Details(
                  posts: post,
    )));
  }
  Future refresh() async{
    setState(() {
      stream=getData();
    });
  }
  @override
  initState(){
    super.initState();
    // _controller = AnimationController(
    //   // vsync: this, // the SingleTickerProviderStateMixin
    //   duration: Duration(seconds: 1),
    // );
    getData();
  }

  void dispose(){
    super.dispose();
  }
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    final height=MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Color(0xFFFFC107),
          icon: Icon(Icons.add),
          onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=>PostPage())),
           label: Text('Add Post',style: GoogleFonts.robotoSlab(
             textStyle: TextStyle(fontWeight: FontWeight.bold)
           ),)),
        drawer: Drawer(
          child: Container(
            color:Color(0xFF80E1D1),
            child: ListView(
              children: [
                FutureBuilder(
                  future: FirebaseAuth.instance.currentUser(),
                  builder:(BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
                    if(snapshot.connectionState==ConnectionState.done){
                      print(snapshot.data.uid);
                      return Container(
                        color: Color(0xFFFFC107),
                        child: UserAccountsDrawerHeader(
                          currentAccountPicture: CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF80E1D1),
                            backgroundImage: ExactAssetImage('assets/images/place.jpg')),
                          accountName: Text(snapshot.data.displayName,style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold)),
                          accountEmail: Text(snapshot.data.email,style: GoogleFonts.robotoSlab(fontWeight: FontWeight.bold,color: Colors.grey)),
                      ));
                    }else{
                      return Center(
                        child: Row(
                         children: [
                           CircularProgressIndicator(),
                           SizedBox(width: 5,),
                           Text('Please wait')
                         ], 
                        ),
                      );
                    }
                  }),
                  GestureDetector(
                    onTap: ()=>auth.signOut().then((onValue) {
                      // Navigator.of(context).pushReplacementNamed('/login');
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>Login()));
                    }),
                    child: ListTile(
                      title: Text('Log Out',style: GoogleFonts.robotoSlab(
                      textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)
                    )),
                      trailing: Icon(Icons.power_settings_new,color: Colors.black,size: 35,),
                    ),
                  ),
                  GestureDetector(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=>OwnerAds())),
                    child: ListTile(
                      title: Text('My Ads',style: GoogleFonts.robotoSlab(
                              textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)
                            )),
                      trailing: Icon(Icons.apps,color: Colors.black,size: 35),
                    ),
                  ),
                  GestureDetector(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=>Cart())),
                    child: ListTile(
                      title: Text('Saved',style: GoogleFonts.robotoSlab(
                        textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)
                      )),
                      trailing: Icon(Icons.bookmark,color: Colors.black,size: 35),
                    ),
                  ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          actions: <Widget>[],
          elevation: 1.5,
          centerTitle: true,
          title: isSearch?
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width/2,
                child: Text('Land Lord',style: GoogleFonts.pacifico(
                  fontSize: 25
                ),)),
              GestureDetector(
                onTap: (){
                  setState(() {
                    isSearch=false;
                  });
                },
                child: Icon(Icons.search,size: 40,color: Colors.white,))
            ],
          ): Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
            // color: Colors.teal[200],
            width: MediaQuery.of(context).size.width/1.5,
            child: DropdownButton<String>(
              hint: Text(" Select City",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey),),
            dropdownColor: Colors.white,
            value: _selectedRegions,
            // icon: Icon(Icons.arrow_drop_down,color: Color(0xFF80E1D1)),
            icon: Icon(Icons.arrow_drop_down,color: Colors.white),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey
            // color: Color(0xFF80E1D1)
            ),
            onChanged: (String newValue) {
            setState(() {
            _selectedRegions = newValue;
            });
            },
            items: regions.map((regions) {
            return DropdownMenuItem(
        child: new Text(regions),
        value: regions,
        );
       }).toList(),
        ),
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                isSearch=true;
              });
            },
            child: Icon(Icons.cancel,size: 40,color: Colors.white,))
            ],
          )
        ),
        body:Container(
          child: LiquidPullToRefresh(
            onRefresh: refresh,
            child: StreamBuilder(
              stream: getData(),
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.active){
                    final posts = snapshot.data.documents;
                    List<Container> postWidgets = [];
                    for( var post in posts){
                      DateTime dob = DateTime.parse(post.data['timestamp'].toDate().toString());
                      Duration dur =  DateTime.now().difference(dob);
                      String mins = (dur.inMinutes).floor().toString();
                      String hours = (dur.inHours).floor().toString();
                      String differenceInYears = (dur.inDays).floor().toString();

                      _displayDate(){
                        if(mins.length/60>24){
                          return Text(mins + ' day ago');
                        }else if(mins.length/60==24){
                          return Text(mins + ' day ago');
                        }else if(mins.length/60>1 && mins.length/60<12){
                          return Text(mins+ ' hours ago');
                        }if(mins.length<=1){
                          // return Text(differenceInYears + ' Day(s) ago');
                          return Text('just now');
                        }else if(mins.length>1 ){
                          return Text(mins +' Minutes ago');
                        }else if(mins.length/60==1){
                          return Text(mins + ' hour ago');
                        }
                      }
                      // String differenceInYears = (dur.inDays/365).floor().toString();
                      String image=post.data['imageUrls'].elementAt(0);
                        final postList=Container(
                        child: GestureDetector(
                              onTap: ()=>navigateToDetail(post),
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
                                              )
                                                // TextStyle(fontWeight: FontWeight.w500,fontSize: 18,color: Colors.black54)
                                                ,),
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
                                             Text(post.data['currency'],style: GoogleFonts.robotoSlab(
                                              textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)
                                            ))
                                           ], 
                                          ),
                                          SizedBox(height: 20,),
                                            // _displayDate(),
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
                                      )
                                    ],
                                  ),
                                  Divider()
                                  ],
                                ),
                              ),
                            ),
                      );
                      postWidgets.add(postList);
                    }return ListView(
                      children: postWidgets
                    );
                }else if(snapshot.connectionState==ConnectionState.waiting){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10,),
                        Text("Loading....!")
                      ],
                    ),
                  );
                }else if(snapshot.data == null || snapshot.data.documents.length == 0){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Error 404"),
                        SizedBox(height: 10,),
                        Text("Ooops! No Data Found")
                      ],
                    ),);
                }
                else if(snapshot.hasError){
                  return Text("Error 404");
                }else{
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Loading....")
                      ],
                    ),
                  );
                }
              }),
          ),
        )
      ),
    );
  }
}