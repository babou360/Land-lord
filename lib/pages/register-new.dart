import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landlord/pages/login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isLoading=false;
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  TextEditingController nameController=TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isVisible=false;
  String errorMsg = "";
  String _email;
  String _password;
  String _name;
  @override
  Widget build(BuildContext context) {
    return isLoading
    ?Container(
      color: Color(0xFFFFC107),
     child: Expanded(
       flex: 1,
       child: Image.asset('assets/images/25.gif')
     ),
    ): Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
            Form(
              key: _formKey,
               child: Column(
                children: [
                  // SizedBox(height: 15,),
                  Container(
                    // height: MediaQuery.of(context).size.height/5,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset('assets/images/land.png')),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: nameController,
                      onChanged: (input)=>_name=input,
                      validator: (value){
                        if(value.isEmpty){
                          return 'name cannot be empty';
                        }else if(value.length>15){
                          return 'Maximum 15 characters';
                        }else{
                          return null;
                        }
                      },
                     decoration: InputDecoration(
                       labelText: 'Username',
                     ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: emailController,
                      onChanged: (input)=>_email=input,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value){
                        if(value.isEmpty){
                          return 'email cannot be empty';
                        }else{
                          return null;
                        }
                      },
                     decoration: InputDecoration(
                       labelText: 'Email',
                     ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width/1.4,
                          child: TextFormField(
                          obscureText: isVisible?false:true,
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter password';
                            }else{
                              return null;
                            }
                          },
                          controller: passwordController,
                          onChanged: (input)=>_password=input,
                          keyboardType: TextInputType.visiblePassword,
                       decoration: InputDecoration( 
                           labelText: 'Password',
                       ),
                      ),
                        ),
                      Container(
                        width: MediaQuery.of(context).size.width/5,
                        child: isVisible
                        ?IconButton(
                          icon: Icon(Icons.remove_red_eye,color: Color(0xFFFFC107),),
                          onPressed: (){
                            setState(() {
                              isVisible=false;
                            });
                          }):IconButton(
                          icon: Icon(Icons.remove_red_eye,color: Colors.grey,),
                          onPressed: (){
                            setState(() {
                              isVisible=true;
                            });
                          })
                      ),
                      ],
                    ),
                  ),
                  Container(
                    //color: Color(0xFF80E1D1),
                    width: MediaQuery.of(context).size.width/2,
                    decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(40),
                     border: Border.all(
                       color: Color(0xFFFFC107),
                     )
                    ),
                   child: FlatButton(
                     onPressed: ()=>_register(), 
                     child: Text("Sign Up",style: GoogleFonts.robotoSlab(
                      textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                    ))), 
                  )
                ], 
               )),
         ], 
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>Login())),
          child: Container(
            color: Color(0xFFFFC107),
           height: 50,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Text("You already have account?",style: GoogleFonts.robotoSlab(
                                  textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                                )),
               SizedBox(width: 7,),
               Text("Login!",style: GoogleFonts.robotoSlab(
                  textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey)
                ))
             ],),
          ),
        ),
      ),
    );
  }
  void _register() async {
      FirebaseAuth auth=FirebaseAuth.instance;
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        setState(() {
         isLoading=true; 
        });
        try {
          await auth
          .createUserWithEmailAndPassword(
            email: _email, password: _password);

          FirebaseUser user = await auth.currentUser();
          String userId=user.uid;

          UserUpdateInfo updateInfo = UserUpdateInfo();
          updateInfo.displayName = _name;
          user.updateProfile(updateInfo);
          if(user!=null){
           await Firestore
            .instance
            .collection('users')
            .document()
            .setData({
              'name': _name,
              'email':_email,
              'password': _password,
              'authorId': userId
            }).then((value){
              setState((){
                isLoading=false;
                 Navigator.of(context).pushReplacementNamed('/home');
              });
            });
          }
        } catch (error) {
          switch (error.code) {
            case "ERROR_EMAIL_ALREADY_IN_USE":
              {
                setState(() {
                  errorMsg = "This email is already in use.";
                  isLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                        actions: [
                          FlatButton(
                            onPressed: ()=>Navigator.pop(context),
                             child: Text('Ok'))
                        ],
                      );
                    });
              }
              break;
            case "ERROR_WEAK_PASSWORD":
              {
               setState(() {
                  errorMsg = "The password must be 6 characters long or more.";
                  isLoading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                        actions: [
                          FlatButton(
                            onPressed: ()=>Navigator.pop(context),
                             child: Text('Ok'))
                        ],
                      );
                    });
              }
              break;
            default:
              {
                setState(() {
                  errorMsg = "";
                });
              }
          }
        }
      }
      //  else {
      //   setState(() {
      //     _autoValidate = true;
      //   });
      // }
    }
}