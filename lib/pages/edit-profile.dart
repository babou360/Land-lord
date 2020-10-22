import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController usernameController=TextEditingController();
  TextEditingController emailController=TextEditingController();
  String username;
  String email;
  bool isEmailFocus = false;
  bool isUsernameFocus = false;
  bool isLoading=false;
  @override
  void initState(){
    super.initState();
    usernameController.addListener(() { });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: FutureBuilder(
        future:  FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
          if(snapshot.hasData){
           return Form(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Focus(
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onChanged: (input)=>username=input,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: snapshot.data.displayName
                        ),
                      ),
                      onFocusChange: (hasuserFocus){
                        setState(() {
                        isUsernameFocus = hasuserFocus;
                      });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Focus(
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onChanged: (input)=>email=input,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: snapshot.data.email
                        ),
                      ),
                      onFocusChange: (hasFocus){
                        setState(() {
                        isEmailFocus = hasFocus;
                      });
                      },
                    ),
                  ),
                  isLoading
                  ?showDialog(
                    context: context,
                    builder:(_)=> AlertDialog(
                      title: Text("Updating"),
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                           Text("Please wait")
                        ],
                    )),
                  ):Container(
                    color: isUsernameFocus || isEmailFocus
                    ?Colors.yellow
                    :Colors.grey,
                    child: FlatButton(
                      onPressed: ()=>updateUser(),
                      child: Text('Submit')),
                  )
                ],
              ));
          }
        }),
    );
  }
  void updateUser() async{
    setState(() {
      isLoading=true;
    });
  FirebaseUser user = await FirebaseAuth.instance.currentUser();

  UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
  userUpdateInfo.displayName = username;

  user.updateProfile(userUpdateInfo);
  setState(() {
      isLoading=false;
    });
  }
}