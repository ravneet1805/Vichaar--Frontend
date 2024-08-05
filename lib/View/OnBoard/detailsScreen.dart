import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Components/myNavBar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:vichaar/View/chooseSkills.dart';
import 'dart:convert';
import 'dart:io';
import '../../Services/apiServices.dart';
import '../../constant.dart';

class DetailsScreen extends StatefulWidget {
  String gitHubLink;
  String linkedinLink;

  DetailsScreen({Key? key,

  required this.linkedinLink,
  required this.gitHubLink

  }) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<File> getDefaultImageFile() async {
  final byteData = await rootBundle.load('assets/icons/default_profile.png');

  final file = File('${(await getTemporaryDirectory()).path}/default_profile.png');
  await file.writeAsBytes(byteData.buffer.asUint8List());

  return file;
}

  Future<void> saveDetails(String fullName, String bio, BuildContext context) async {
    print(fullName);
    print('image file printing: ${getDefaultImageFile()}');

    final imageFile = _image ?? await getDefaultImageFile();

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChooseSkillsScreen(
            image: imageFile,
            fullName: fullName,
            bio: bio,
            linkedinLink: widget.linkedinLink,
            gitHubLink: widget.gitHubLink)),
          );

    
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // String fullName = '';
    // String bio = '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Your Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Complete your profile to help others know you better.',
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: GestureDetector(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: kGreyColor,
                        backgroundImage: _image == null
                            ? AssetImage('assets/icons/default_profile.png')
                            : FileImage(_image!) as ImageProvider,
                        child: _image == null
                            ? Icon(
                                Icons.add_a_photo,
                                size: 30,
                                color: kGreyColor,
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Full Name: *",
                              style: TextStyle(color: kGreyHeadTextcolor, fontSize: 14),
                            ),
                            TextFormField(
                              controller: fullNameController ,
                              validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                              cursorColor: kPurpleColor,
                              style: TextStyle(color: kGreyHeadTextcolor),
                              decoration: InputDecoration(
                                hintText: 'Enter your full name',
                                filled: true,
                                hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                                fillColor: kGreyColor,
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.white24,
                                  size: 18,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bio: *",
                          style: TextStyle(color: kGreyHeadTextcolor, fontSize: 14),
                        ),
                        TextFormField(
                          controller: bioController,
                          cursorColor: kPurpleColor,
                          maxLines: 5,
                          maxLength: 150,
                          validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your bio';
                          }
                          return null;
                        },
                          style: TextStyle(color: kGreyHeadTextcolor),
                          decoration: InputDecoration(
                            hintText: 'Tell us about yourself',
                            filled: true,
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            fillColor: kGreyColor,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                      ],
                    ),
                  ),
                  
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Full Name: " + fullNameController.text + "   " + "Bio: " + fullNameController.text);
                      if (_formKey.currentState?.validate() ?? false) {
                      saveDetails(fullNameController.text.trim(), bioController.text.trim(), context);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        gradient: kPurpleGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
