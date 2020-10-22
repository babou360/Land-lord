//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landlord/main.dart';
import 'package:landlord/pages/details.dart';
import 'package:landlord/pages/login.dart';
import 'package:landlord/pages/owner-ads.dart';
import 'package:landlord/pages/upload.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class Feed extends StatefulWidget {
  DocumentSnapshot posts;
  Feed({this.posts});
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
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
  var post;
  String _selectedRegions;
  String filter;
  bool isGrid=false;
  TextEditingController controller=TextEditingController();
  var stream;
  int _displayPosts=0; 
  bool isSearch=true;
   
   Stream<QuerySnapshot> getData(){
      if(_selectedRegions=='All'){
       return Firestore.instance.collection('posts').snapshots();
      }else if(_selectedRegions!=null){
       return  Firestore.instance.collection('posts')
        .where('region',isEqualTo: _selectedRegions)
        .snapshots(); 
      }else if(_selectedRegions==null){
        return Firestore.instance.collection('posts').snapshots();
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
    getData();
  }

  void dispose(){
    super.dispose();
    getData().drain();
  }
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    final height=MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Color(0xFF80E1D1),
          icon: Icon(Icons.add),
          onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=>PostPage())),
           label: Text('Add Post')),
        drawer: Drawer(
          child: Container(
            color: Colors.teal[200],
            child: ListView(
              children: [
                FutureBuilder(
                  future: FirebaseAuth.instance.currentUser(),
                  builder:(BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
                    if(snapshot.connectionState==ConnectionState.done){
                      print(snapshot.data.uid);
                      return Container(
                        child: UserAccountsDrawerHeader(
                          accountName: Text("Land lord"),
                          accountEmail: Text(snapshot.data.email)),
                      );
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
                      title: Text('Log Out'),
                      trailing: Icon(Icons.call_missed_outgoing),
                    ),
                  ),
                  GestureDetector(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=>OwnerAds())),
                    child: ListTile(
                      title: Text('Your Ads'),
                      trailing: Icon(Icons.queue_play_next),
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
                child: Image.asset('assets/images/land.png')),
              // Text("Land Lord",style: TextStyle(color: Colors.white,fontSize: 30,fontFamily:'StarellaTattoo_PERSONAL_USE.ttf' ),),
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
            color: Colors.teal[200],
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
        body:StreamBuilder(
          builder: (context,snapshot){
            if(snapshot.hasData){
             return  Text("data");
            }else{
              return ListView(
            children: [
           _buildTogleButtons(),
           _buildDisplayPosts()
         ], 
        );
            }
          })
      ),
    );
  }

  _buildDisplayPosts(){
    if(_displayPosts==0){
      return list();
    }else{
      return list();
    }
  }
  _buildTogleButtons(){
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
       children: <Widget>[
         IconButton(
           icon: Icon(Icons.grid_on,),
           iconSize: 30,
           color: _displayPosts==0
           ?Colors.blue
           :null,
           onPressed: ()=> setState((){
             _displayPosts=0;
           }) ,
         ),
         IconButton(
           icon: Icon(Icons.list,),
           iconSize: 30,
           color: _displayPosts==1
           ?Colors.blue
           :null,
           onPressed: ()=> setState((){
             _displayPosts=1;
           }) ,
         )
       ],
     );
   }
  Widget list(){
   return Container(
          child: LiquidPullToRefresh(
            onRefresh: refresh,
            child: StreamBuilder(
              stream: getData(),
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.active){
                  // if(snapshot.hasData){
                    final posts = snapshot.data.documents;
                    List<Container> postWidgets = [];
                    for( post in posts){
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
                                               Text(post.data['category'],style:
                                                TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: Colors.black54),),
                                               SizedBox(width: 3,),
                                               Text('For',style:
                                                TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: Colors.black54)),
                                               SizedBox(width: 3,),
                                               Text(post.data['purpose'],style:
                                                TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: Colors.black54))
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
                                             TextStyle(fontWeight: FontWeight.w500,color: Colors.brown))
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
                        Text("Loading....")
                      ],
                    ),
                  );
                }else if(!snapshot.hasData){
                  return Text('No data');
                }
                else if(snapshot.connectionState!=ConnectionState.done){
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
        );
  }
}