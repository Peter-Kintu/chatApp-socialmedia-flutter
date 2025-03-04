// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/controllers/controllers.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  FilePickerResult? _filePickerResult;

  late String? imageId = "";
  late String? userId = "";
  final _namekey = GlobalKey<FormState>();

  @override
  void initState() {
    // try to load data from local data base
    Future.delayed(Duration.zero, () {
      userId = Provider
          .of<UserDataProvider>(context, listen: false)
          .getUserId;
      Provider.of<UserDataProvider>(context, listen: false)
          .loadUserData(userId!);
      imageId = Provider
          .of<UserDataProvider>(context, listen: false)
          .getUserProfile;
    });
    super.initState();
  }

  //to open file picker
  void _openFilePicker() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(type: FileType.image);

    setState(() {
      _filePickerResult = result;
    });
  }

  //upload user profile image and save it to the bucket database
  Future uploadProfileImage() async {
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty){
      PlatformFile file = _filePickerResult!.files.first;
      final fileBytes = await File(file.path!).readAsBytes();
      final inputfile = InputFile.fromBytes(
          bytes: fileBytes, filename: file.name);

      // if image already exist for the user profile or not
      if (imageId != null && imageId != "") {
        //then update the image
        await updateImageOnBucket(image: inputfile, oldImageId: imageId!).then((
            value) {
          if (value != null) {
            imageId = value;
          }
        });
      }
      //create new image and upload to bucket
      else{
        await saveImageToBucket(image: inputfile).then(
         (value) {
            if (value != null) {
            imageId = value;
              }
        });
      }
    }
      else{
        print("something went wrong");
      }
  }
  catch(e){
      print("error on uploading image :$e");
  }
}
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> datapassed =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Consumer<UserDataProvider>(
      builder : (context, value, child) {
        _nameController.text=value.getUserName;
        _phoneController.text=value.getUserPhoneNumber;

      return Scaffold(
        appBar: AppBar(
          title: Text(
              datapassed["title"]=="edit"? "Update": "Add Details"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: (){
                    _openFilePicker();
                  },
                  child: Stack(
                    children:[
                      CircleAvatar(
                      radius: 120,
                        backgroundColor: Colors.black12,
                        backgroundImage:
                            _filePickerResult != null
                               ? Image(
                                image: FileImage(File(
                                    _filePickerResult!.files.first.path!)))
                                .image
                        : value.getUserProfile != "" &&
                                value.getUserProfile != null?
                        CachedNetworkImageProvider("${value.getUserProfile}") //3h:10mi
                        : null,
                      ),
                      Positioned(
                        bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                           decoration: BoxDecoration(
                             color: Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                        )
                      ))

                    ],
                  ),
                ),
          
                const SizedBox(
                    height: 20
                ),
          
                Container(
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Form(
                    key: _namekey,
                    child: TextFormField(
                      validator: (value) {
                        if(value!.isEmpty) return "cannot be empty";
                        return null;
                      },
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your name"
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextFormField(
                    controller: _phoneController,
                    enabled: false,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your phone number"
                    ),
                  ),
                ),
               const SizedBox(
                 height: 10,
               ),
          
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ()async{
                      if(_namekey.currentState!.validate()) {
                        //upload the image if file is picked
                        if(_filePickerResult!=null){
                          await uploadProfileImage();
                        }
                        //save the data to database user collection
                        await updateUserDetails(
                            imageId??"",
                            userId: userId!,
                            name: _nameController.text);
                        //navigate the user to the home route
                        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    child: Text(datapassed["title"]=="edit"
                        ? "Update"
                        : "Continue"
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
       }
    );
  }
}