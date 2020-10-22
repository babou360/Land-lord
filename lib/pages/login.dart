import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landlord/pages/register-new.dart';
import 'package:landlord/pages/reset-password.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading=false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  String errorMsg = "";
  String _email;
  String _password;
  bool isVisible=false;
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
         // crossAxisAlignment: CrossAxisAlignment.center,
         children: [
            Form(
              key: _formKey,
               child: Column(
                children: [
                  Container(
                    // height: MediaQuery.of(context).size.height/4,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset('assets/images/land.png')),
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
                    padding: const EdgeInsets.only(left: 8),
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
                          icon: Icon(Icons.remove_red_eye,color: Colors.grey),
                          onPressed: (){
                            setState(() {
                              isVisible=true;
                            });
                          })
                      ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: ()=>_login(),
                      child: Container(
                        //color: Color(0xFF80E1D1),
                        width: MediaQuery.of(context).size.width/2,
                        decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(40),
                         border: Border.all(
                           color: Color(0xFFFFC107),
                         )
                        ),
                       child: FlatButton(
                         onPressed: ()=>_login(), 
                         child: Text("Login",style: GoogleFonts.robotoSlab(
                        textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                      ))), 
                      ),
                    ),
                  ),
                ], 
               )),
         ], 
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>Register())),
          child: Container(
            color: Color(0xFFFFC107),
           height: 50,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Text("You don't have account?",style: GoogleFonts.robotoSlab(
                                    textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)
                                  )),
               SizedBox(width: 7,),
               Text("Sign Up!",style: GoogleFonts.robotoSlab(
                  textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey)
                ))
             ],),
          ),
        ),
      ),
    );
  }
  void _login() async {
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        setState(() {
          isLoading=true;
        });
        try {
         // FirebaseUser user = await FirebaseAuth.instance
           AuthResult user = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password);
          Navigator.of(context).pushReplacementNamed('/home');
        } catch (error) {
          switch (error.code) {
            case "ERROR_USER_NOT_FOUND":
              {
                setState(() {
                  errorMsg =
                      "There is no user with such entries. Please try again.";

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
            case "ERROR_WRONG_PASSWORD":
              {
                setState(() {
                  errorMsg = "Password doesn\'t match your email.";
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
      // } else {
      //   setState(() {
      //     _autoValidate = true;
      //   });
      // }
    }
}