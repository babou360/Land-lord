import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:landlord/models/post.dart';
import 'package:landlord/models/user.dart';
import 'package:landlord/service/database.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Post> _posts=[];
  List<User> _user=[];
  @override
  void initState() {
    super.initState();
    _setupFeed();
    _setupUser();
  }
  _setupFeed() async{
    FirebaseAuth auth=FirebaseAuth.instance;
    FirebaseUser user=await auth.currentUser();
    final userId=user.uid;
    final userEmail=user.email;
    final userName=user.displayName;
    List<Post> posts=await DatabaseService.getCurrentPosts(userId);
    setState(() {
      _posts=posts;
    });
  }
  _setupUser() async{
    FirebaseAuth auth=FirebaseAuth.instance;
    FirebaseUser user=await auth.currentUser();
    final userId=user.uid;
    List<User> author=await DatabaseService.getUser(userId);
    setState(() {
      _user=author;
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Profile Page'),
          ),
          body: Container(
           child: _posts.length<1
           ?Center(
             child: CircularProgressIndicator(),
           ):ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (BuildContext context,int index){
            Post post=_posts[index];
            String image=post.imageUrls.elementAt(0);
            showUser();
            return  GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(4.0),
                crossAxisSpacing: 4.0,
                childAspectRatio: 1.0,
                mainAxisSpacing: 2.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                //children: tiles,
                // children: List.generate(1, (index){
                // return Image.network(image);
                // }),
                children: <String>[image].map((String url) {
               return GridTile(
                  child: Image.network(url, fit: BoxFit.cover));
              }).toList()
             );
          },
       )
      )
    );
  }
  showUser(){
    User user;
     return Row(
      children: [
       Text(user.email)
      ],
     );
   }
}