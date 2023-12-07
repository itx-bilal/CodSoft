import 'dart:io';
import 'package:ToDoApp/main.dart';
import 'package:ToDoApp/task_success_dialogue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool loading = false;
  final GlobalKey<FormState> _editusernamekey = GlobalKey<FormState>();
  final GlobalKey<FormState> _editemailkey = GlobalKey<FormState>();
  var _editusernameController = TextEditingController();
  var _editemailController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  File? image;
  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage == null) return;
    setState(() {
      image = File(pickedImage.path);
    });
  }
  Future<String> uploadImage(File imageFile) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('user_profile_images')
          .child(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());

      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
      final String downloadUrl = await storageReference.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }
  bool isImageSelected() {
    return image != null;
  }
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  String? imageUrl;
  void getUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;


    if (user != null) {
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('users_accounts')
          .doc(user.uid)
          .get();

      Map<String, dynamic> userData = userDataSnapshot.data() as Map<String, dynamic>;

      _editusernameController.text = userData['Name'] ?? '';
      _editemailController.text = userData['Email'] ?? '';
      if (userData['Image'] != null) {
        setState(() {
          imageUrl = userData['Image'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        title: Text('Edit Profile',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              child: Image.asset('assets/images/edit_task.png'),
            ),
            SizedBox(height: 10,),
            Stack(
              children: [
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text('Profile Picture'),
                                elevation: 0,
                              ),
                              body: Center(
                                child: image != null ?
                                Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                ) :imageUrl != null
                                    ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: double.infinity,
                                )
                                    : Image.asset(
                                  'assets/images/pic8.png',
                                  fit: BoxFit.contain,
                                  height: double.infinity,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Hero(
                        tag: 'profile',
                        child: ClipOval(
                          child: image != null ? Image.file(image!,fit: BoxFit.cover,) :imageUrl != null
                              ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/pic8.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        
                Positioned(
                    top: MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 0,
                    left: MediaQuery.of(context).orientation == Orientation.portrait ? 190 : 370,
                    child: InkWell(
                      onTap: () {
                        showCustomImageModalBottomSheet(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: Colors.grey.shade900
                        ),
                        child: Icon(Icons.camera_alt,color: Colors.white,),
                      ),
                    )
                )
              ],
            ),
            SizedBox(height: 10,),
            Container(
              color: Colors.black,
              width: double.infinity,
              child: Form(
                key: _editusernamekey,
                child: TextFormField(
                  cursorColor: Colors.green,
                  controller: _editusernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    //focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    prefixIcon: Icon(Icons.drive_file_rename_outline,color: Colors.white,),
                    labelText: "Full Name",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  validator: (value) {
                    if(value!.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              color: Colors.black,
              width: double.infinity,
              child: Form(
                key: _editemailkey,
                child: TextFormField(
                  cursorColor: Colors.green,
                  controller: _editemailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    //focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    prefixIcon: Icon(Icons.email,color: Colors.white,),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  validator: (value) {
                    if(value!.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.065,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green
                  ),
                  onPressed: () async{
                    if(_editusernamekey.currentState!.validate()&&_editemailkey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      if(user!=null) {
                        try {
                          String newImageUrl = imageUrl!;
                          if (image != null) {
                            newImageUrl = await uploadImage(image!);
                          }
                          await FirebaseFirestore.instance.collection('users_accounts').doc(user?.uid).update({
                            'Name': _editusernameController.text,
                            'Email': _editemailController.text,
                            'Image': newImageUrl
                          }).then((value) {
                            showTaskSuccessDialog(context, 'Profile Updated', 'Your profile has been updated succcessfully');
                          }).onError((error, stackTrace) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.white,
                                content: Text('Updation failed: $error'),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(17.0),
                              ),
                            );
                          }).whenComplete(() {
                            setState(() {
                              loading = false;
                            });
                          });
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(),), (route) => false);
                        }
                        catch(e) {
                          print('Error updating user data: $e');
                        }
                      }
                    }
                  }, child: loading ? CircularProgressIndicator(color: Colors.white,) : Text('Edit',style: TextStyle(color: Colors.white),)),
            ),
          ],
        ),
      ),
    );
  }
  void showCustomImageModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25),topRight: Radius.circular(25))
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black,
          height: 240,
          child: Column(
            children: [
              SizedBox(height: 5,),
              Text('Select Image From',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 18),),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 15,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: Image.asset('assets/images/gallery.png',width: 80,height: 70,fit: BoxFit.fill,),
                            ),
                            Text('Gallery',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 15,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              child: Image.asset('assets/images/camm.png',width: 80,height: 70,fit: BoxFit.fill),
                            ),
                            Text('Camera',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }, child: Text('Cancel',style: TextStyle(color: Colors.white),)))
            ],
          ),
        );
      },
    );
  }
}