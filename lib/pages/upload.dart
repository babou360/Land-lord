import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:landlord/models/post.dart';
import 'package:landlord/pages/home.dart';
import 'package:landlord/service/database.dart';
import 'dart:async';

import 'package:multi_image_picker/multi_image_picker.dart';


class PostPage extends StatefulWidget {
  final Post userPost1;
  PostPage({this.userPost1});
  @override
  _PostPageState createState() => new _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _formKey = GlobalKey<FormState>();
  List<Asset> images = List<Asset>();
  bool isloading=false;
  Post post;
  String errorMessage;
  String _code;
  String _propertyFor;
  Iterable<Post> userPost=[];
  //User currentUser;
  TextEditingController descriptionController=TextEditingController();
  TextEditingController phoneController=TextEditingController();
  TextEditingController priceController=TextEditingController();
  TextEditingController nameController=TextEditingController();
  String _error = 'No Error Dectected';
  List<String> imageUrls = <String>[];
  String _description;
  String _phone;
  String _name;
  String _price;
  bool isUploading = false;
  String dropdownValue;
  List<String> regions = [
   'Arusha', 'Mwanza','Dar-es-salam'
  ,'Manyara','Kilimanjaro','Kigoma'
  ,'Tabora','Pwani','Lindi'
  ,'Mtwara','Ruvuma','Morogoro'
  ,'Tanga','Dodoma','Singida'
  ,'Mbeya','Iringa','Mara'
  ,'Zanzibar','Kagera','Shinyanga'
  ,'Simiyu','Rukwa','Njombe'
  ,'Katavi','Geita','All'
  ];
  String _selectedRegions;
  String currency;
  List<String> category = [
   'House', 'Plot','Farm','Hotel','Guest House'
  ];// Option 2
  List<String> _for = [
   'Rent', 'Sell'
  ];
  String _selectedCategory;
  String _selectedFor; 
    
    _setupFeed() async{
      FirebaseAuth auth=FirebaseAuth.instance;
      FirebaseUser user=await auth.currentUser();
      final userId=user.uid;
    QuerySnapshot userData=await Firestore.instance.collection('users').where('authorId',isEqualTo: userId).getDocuments();
  }

  @override
  void initState() {
    super.initState();
  }

   void _onCountryChange(CountryCode countryCode) {
     setState(() {
      _code = countryCode.toString(); 
     });
    print("New Country selected: " + countryCode.toString());
  }
    Future  _submit() async{
   final FormState form = _formKey.currentState;
   if(!_formKey.currentState.validate()){
     Scaffold.of(context).showSnackBar(
         SnackBar(content: Text("Please fill out all the fields"),
         duration: new Duration(seconds: 2),
        //  behavior: SnackBarBehavior.floating,
         elevation: 3.0,
         backgroundColor: Colors.green,)
       );
     }else{
       if(images.isNotEmpty && _selectedCategory.isNotEmpty
      && _description.isNotEmpty && _price.isNotEmpty 
      && currency.isNotEmpty && _propertyFor.isNotEmpty 
      && _selectedRegions.isNotEmpty){
        form.save();
        setState(() {
        isloading=true;
        });
        FirebaseAuth auth=FirebaseAuth.instance;
         FirebaseUser user=await auth.currentUser();
         final userId=user.uid;
         final userEmail=user.email;
         final userName=user.displayName;
                       // create post
              for(var imageFile in images){
          postImage(imageFile).then((downloadUrl){
            imageUrls.add(downloadUrl.toString());
            if(imageUrls.length==images.length){
              Post post=Post(
                imageUrls: imageUrls,
                description: _description,
                region: _selectedRegions,
                category: _selectedCategory,
                purpose: _propertyFor,
                saved: false,
                price: _price,
                email: userEmail,
                phone: _phone,
                code: _code,
                name: userName,
                authorId: userId,
                currency: currency,
                addedAt: Timestamp.fromDate(DateTime.now()),
                timestamp: Timestamp.fromDate(DateTime.now())
              );
              //  final progress = ProgressHUD.of(context);
              //  progress.showWithText('Loading...');
              DatabaseService.createPost(post);
              // reset Data
              descriptionController.clear();
              setState(() {
                isloading=false;
                images=null;
              _description='';
              _price='';
              _phone='';
              // _selectedRegions='';
              images = [];
              imageUrls = [];
              });
              Navigator.push(context, MaterialPageRoute(builder: (_)=>Home()));
            } 
          });
        }
     }
   }
  }
Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }
  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 1,
      scrollDirection: Axis.horizontal,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
            asset: asset,
            width: 450,
            height: 550,
          );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          //selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context).size.width;
    final height=MediaQuery.of(context).size.height;
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isloading
          ?Container(
            color: Color(0xFFFFC107),
            child: Center(
              child: Image.asset('assets/images/25.gif')),
          ):Scaffold(
                body: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                              child: Column(
                            children: <Widget>[
                        //Center(child: Text('Error: $_error')),
                        GestureDetector(
                                onTap: loadAssets,
                                child: Container(
                                color: Colors.grey[300],
                                height: height/2,
                                child: images.isEmpty
                                ?Icon(
                                      Icons.add_a_photo,
                                      color:Color(0xFFFFC107),
                                      size: MediaQuery.of(context).size.height/2,
                                      )
                                :buildGridView()
                            ),
                        ),
                        Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: TextFormField(
                                    cursorColor: Color(0xFFFFC107),
                                    style: TextStyle(
                                   fontWeight: FontWeight.w600,decorationColor: Color(0xFFFFC107), ),
                                    maxLines: 3,
                                    autovalidate: false,
                                    validator: (value){
                                      if(value.isEmpty){
                                        return 'Please enter Description';
                                      }
                                      else{
                                        return null;
                                      }
                                    },
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                       enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFFFC107),
                                                )
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFFFC107),
                                                )
                                              ),
                                      //labelText: "Description",
                                      hintText: "Description"
                                    ),
                                    onChanged: (input)=>_description=input
                                  ),
                                ),
                                 Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: TextFormField(
                                            autovalidate: false,
                                             cursorColor: Color(0xFFFFC107),
                                            style: TextStyle(
                                            fontWeight: FontWeight.w600,decorationColor: Color(0xFFFFC107), ),
                                            validator: (value){
                                              if(value.isEmpty){
                                                return "Please Enter the Price";
                                              }
                                              else if(value.length>15){
                                                return 'maxmum 16 characters';
                                              }
                                              else{
                                                return null;
                                              }
                                            },
                                            controller: priceController,
                                            decoration: InputDecoration(
                                               enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFFFC107)
                                                )
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFFFC107)
                                                )
                                              ),
                                              //labelText: "Price",
                                              hintText: "Price",
                                              fillColor: Color(0xFFFFC107),
                                              focusColor: Color(0xFFFFC107),
                                              hoverColor: Color(0xFFFFC107),
                                            ),
                                            obscureText: false,
                                            keyboardType: TextInputType.number,
                                            //validator: (input)=> input.length>10? "Not longer than 10" : null,
                                            onChanged: (input)=> _price=input
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Container(
                                                  width: width/3,
                                                  child: Text("Currency",style: TextStyle(fontSize: 20,color: Colors.grey,
                                                       fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                              Container(
                                                width: width/2,
                                               child: Row(
                                                children: [
                                                  Text('TZS',style: TextStyle(fontWeight: FontWeight.w600)),
                                              Radio(
                                                activeColor: Color(0xFFFFC107),
                                                value: "TZS",
                                                groupValue: currency,
                                                onChanged: (String value){
                                                  setState(() {
                                                    currency=value;
                                                  });
                                                }),
                                                Text("USD",style: TextStyle(fontWeight: FontWeight.w600)),
                                                Radio(
                                                activeColor: Color(0xFFFFC107),
                                                value: "USD",
                                                groupValue: currency,
                                                onChanged: (String value){
                                                  setState(() {
                                                    currency=value;
                                                  });
                                                }),
                                                ],
                                               ), 
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Container(
                                                  width: width/3,
                                                  child: Text("Property For?",style: TextStyle(fontSize: 20,color: Colors.grey,
                                                       fontWeight: FontWeight.w600)),
                                                ),
                                              ),
                                              Container(
                                                width: width/2,
                                               child: Row(
                                                children: [
                                                  Text('Sell',style: TextStyle(fontWeight: FontWeight.w600)),
                                              Radio(
                                                activeColor: Color(0xFFFFC107),
                                                value: "Sell",
                                                groupValue: _propertyFor,
                                                onChanged: (String value){
                                                  setState(() {
                                                    _propertyFor=value;
                                                  });
                                                }),
                                                Text("Rent",style: TextStyle(fontWeight: FontWeight.w600)),
                                                Radio(
                                                activeColor: Color(0xFFFFC107),
                                                value: "Rent",
                                                groupValue: _propertyFor,
                                                onChanged: (String value){
                                                  setState(() {
                                                    _propertyFor=value;
                                                  });
                                                }),
                                                ],
                                               ), 
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                            child: Row(
                                              children: [     
                                                Container(
                                                  width: MediaQuery.of(context).size.width/3,
                                                  child: CountryCodePicker(
                                                    onChanged: _onCountryChange,
                                                    //onChanged: (e) => print(e.toString()),
                                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                                    initialSelection: 'TZ',
                                                    favorite: ['+255','TZ'],
                                                    // optional. Shows only country name and flag
                                                    showCountryOnly: false,
                                                    // optional. Shows only country name and flag when popup is closed.
                                                    showOnlyCountryWhenClosed: false,
                                                    // optional. aligns the flag and the Text left
                                                    alignLeft: false,
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context).size.width/2,
                                                  child: TextFormField(
                                                  autovalidate: false,
                                                  cursorColor: Color(0xFFFFC107),
                                                  style: TextStyle(color:Color(0xFFFFC107),
                                                  fontWeight: FontWeight.w600,decorationColor: Color(0xFF80E1D1) ),
                                                  validator: (value){
                                                    if(value.isEmpty){
                                                      return 'Phone Cannot be Empty';
                                                    }else if(value.length>9){
                                                      return 'Please Enter valid number like 786554433 with no 0';
                                                    }else if(value.length<9){
                                                      return 'Please Enter valid number like 786554433';
                                                    }else if(value.startsWith('0')){
                                                      return "Don't start with 0";
                                                    }
                                                    else{
                                                      return null;
                                                    }
                                                  },
                                                  controller: phoneController,
                                                  decoration: InputDecoration(
                                                     enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(0xFFFFC107)
                                                      )
                                                    ),
                                                    focusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Color(0xFFFFC107),
                                                      )
                                                    ),
                                                    //labelText: "Phone",
                                                    hintText: "Phone",
                                                    fillColor: Color(0xFFFFC107),
                                                    focusColor: Color(0xFFFFC107),
                                                    hoverColor: Color(0xFFFFC107),
                                                  ),
                                                  obscureText: false,
                                                  keyboardType: TextInputType.number,
                                                  //validator: (input)=> input.length>10? "Not longer than 10" : null,
                                                  onChanged: (input)=> _phone=input
                                              ),
                                                ),
                                              ],
                                            ),
                                          ),
                                         Container(
                                           child: Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                             children: [
                                               Container(
                                                 width: MediaQuery.of(context).size.width/2,
                                                 child: Padding(
                                                   padding: const EdgeInsets.only(left: 10),
                                                   child: Text("Select City",style: TextStyle(fontSize: 20,color: Colors.grey,
                                                   fontWeight: FontWeight.w600),),
                                                 ),
                                               ),
                                   Container(
                                     width: MediaQuery.of(context).size.width/2,
                                     child: DropdownButton<String>(
                                     value: _selectedRegions,
                                  icon: Icon(Icons.arrow_drop_down,color: Color(0xFFFFC107),),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(
                                      fontSize: 20,
                                  color: Color(0xFFFFC107),
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
                                             ],
                                           ),
                                         ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width/2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text('Category',style: TextStyle(fontSize: 20,color: Colors.grey,
                                                     fontWeight: FontWeight.w600)),
                                      )),
                                      Container(
                                        width: MediaQuery.of(context).size.width/2,
                                        child: DropdownButton<String>(
                                         value: _selectedCategory,
                                        icon: Icon(Icons.arrow_drop_down,color: Color(0xFFFFC107),),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(
                                          fontSize: 20,
                                        color: Color(0xFFFFC107),
                                        ),
                                        onChanged: (String newValue) {
                                        setState(() {
                                        _selectedCategory = newValue;
                                        });
                                        },
                                 items: category.map((category) {
                                 return DropdownMenuItem(
                                child: new Text(category),
                                value: category,
                            );
                        }).toList(),
                                ),
                                      ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                     padding: const EdgeInsets.all(16.0),
                                     child: Container(
                                       width: width/2,
                                       child: FlatButton(
                                         onPressed: ()=>_submit(),
                                         child: Text("Upload")),
                                       decoration: BoxDecoration(
                                         border: Border.all(color: Color(0xFFFFC107),),
                                         borderRadius: BorderRadius.circular(10)
                                       ),
                                     ),
                                   )
                      ],
                    ),
                   ),
                  ),
          ),
    );
  }
}