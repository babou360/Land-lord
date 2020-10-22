import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Reset extends StatefulWidget {
  @override
  _ResetState createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  String _email;
  @override

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
}
  void initState(){
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login Help')
      ),
      body: Column(
        children: [
          SizedBox(height: 10,),
          Text("Find Your Account"),
          SizedBox(height: 10,),
          Text("Enter Your LandLord Email to find your Account"),
          Form(
            child: Column(
              children: [
                TextFormField(
                  onChanged: (input)=>_email=input,
                  decoration: InputDecoration(
                    hintText: 'Email'
                  ),
                  validator: (value){
                    if(value.isEmpty){
                      return 'Email cannot be Empty';
                    }else{
                      return null;
                    }
                  },
                ),
                FlatButton(
                  onPressed: ()=>resetPassword(_email),
                  child: Text("Reset Password"))
              ],
            ))
        ],
      )
    );
  }
}