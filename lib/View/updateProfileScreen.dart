import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/SnackBar/successSnackbar.dart';
import 'dart:convert';
import 'dart:io';

import '../Components/skillsChips.dart';
import '../Provider/skillsProvider.dart';
import '../Services/apiServices.dart';
import '../SnackBar/errorSnackBar.dart';
import '../constant.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _githubLinkController = TextEditingController();
  TextEditingController _linkedinLinkController = TextEditingController();

  late var localName;
  late var localUserName;
  late var localBio;
  late var localGithub;
  late var localLinkedin;
  late String localImage;
  late var skills;

  File? image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      localName = prefs.getString('name') ?? '';
      localUserName = prefs.getString('userName') ?? '';
      localBio = prefs.getString('bio') ?? '';
      localGithub = prefs.getString('githubLink') ?? '';
      localLinkedin = prefs.getString('linkedinLink') ?? '';
      localImage = prefs.getString('image') ?? '';
      skills = prefs.getStringList('skills'); 
      _fullNameController.text = prefs.getString('name') ?? '';
      _userNameController.text = prefs.getString('userName') ?? '';
      _bioController.text = prefs.getString('bio') ?? '';
      _githubLinkController.text = prefs.getString('githubLink') ?? '';
      _linkedinLinkController.text = prefs.getString('linkedinLink') ?? '';
      context.read<SkillsProvider>().setSelectedSkills(skills);
    });
  }

  Future<File> getDefaultImageFile() async {
    final byteData = await rootBundle.load('assets/icons/default_profile.png');
    final file =
        File('${(await getTemporaryDirectory()).path}/default_profile.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');

    print("entered update");
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${ApiService.baseUrl}/users/updateprofile'));
    request.headers['Authorization'] = 'bearer $token';

    // Add only non-empty fields to the request
    if (_fullNameController.text != localName) {
      request.fields['fullName'] = _fullNameController.text;
    }
    if (_userNameController.text != localUserName) {
      print("printing username controler: "+ _userNameController.text);
      print("printing username local: "+ localUserName);
      request.fields['userName'] = _userNameController.text;
    }
    if (_bioController.text != localBio) {
      request.fields['bio'] = _bioController.text;
    }
    if (_githubLinkController.text != localGithub) {
      request.fields['githubLink'] = _githubLinkController.text;
    }
    if (_linkedinLinkController.text != localLinkedin) {
      request.fields['linkedinLink'] = _linkedinLinkController.text;
    }

    

    

    if ( context.read<SkillsProvider>().selectedSkills != prefs.getStringList('skills')) {
      request.fields['skills'] = json.encode(context.read<SkillsProvider>().selectedSkills);
    }

    if (image != null) {
      var stream = new http.ByteStream(image!.openRead());
      stream.cast();

      var length = await image!.length();
      final imageFile = await http.MultipartFile('photo', stream, length);
      request.files.add(imageFile);
    }

    var response = await request.send();

    print("Status Code: ${response.statusCode}");
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    if (response.statusCode == 200) {
      print("message: ${jsonResponse}");
      SuccessSnackbar.show(context, jsonResponse["message"]);
      print("Update successful");
      prefs.setString('name', jsonResponse['user']['fullName']);
      prefs.setString('image', jsonResponse['user']['image']);
      prefs.setString('userName', jsonResponse['user']['userName']);
      prefs.setString('bio', jsonResponse['user']['bio']);
      prefs.setString('githubLink', jsonResponse['user']['githubLink']);
      prefs.setString('linkedinLink', jsonResponse['user']['linkedinLink']);
       List<String> skillsList =
          (jsonResponse['user']['skills'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
       prefs.setStringList('skills', skillsList);
    } else {
      print("message: ${jsonResponse}");
      ErrorSnackbar.show(context, jsonResponse["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
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
                  // SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                            radius: 30,
                            backgroundColor: kGreyColor,
                            backgroundImage: image != null
                                ? FileImage(image!)
                                : localImage != null
                                    ? NetworkImage(localImage!)
                                        as ImageProvider<Object>?
                                    : AssetImage(
                                            'assets/icons/default_profile.png')
                                        as ImageProvider<Object>?,
                            child: Icon(
                              Icons.add_a_photo,
                              size: 20,
                              color: kGreyColor,
                            )),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Full Name:",
                              style: TextStyle(
                                  color: kGreyHeadTextcolor, fontSize: 14),
                            ),
                            TextFormField(
                              controller: _fullNameController,
                              cursorColor: kPurpleColor,
                              style: TextStyle(color: kGreyHeadTextcolor),
                              decoration: InputDecoration(
                                hintText: 'Enter your full name',
                                filled: true,
                                hintStyle: TextStyle(
                                    color: Colors.white24, fontSize: 14),
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
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Username:",
                        style:
                            TextStyle(color: kGreyHeadTextcolor, fontSize: 14),
                      ),
                      TextFormField(
                        controller: _userNameController,
                        cursorColor: kPurpleColor,
                        style: TextStyle(color: kGreyHeadTextcolor),
                        decoration: InputDecoration(
                          hintText: 'Enter your username',
                          filled: true,
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
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
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bio:",
                        style:
                            TextStyle(color: kGreyHeadTextcolor, fontSize: 14),
                      ),
                      TextFormField(
                        controller: _bioController,
                        cursorColor: kPurpleColor,
                        textInputAction: TextInputAction.done,
                        maxLines: 5,
                        maxLength: 150,
                        style: TextStyle(color: kGreyHeadTextcolor),
                        decoration: InputDecoration(
                          hintText: 'Tell us about yourself',
                          filled: true,
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
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
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GitHub Link:",
                        style:
                            TextStyle(color: kGreyHeadTextcolor, fontSize: 14),
                      ),
                      TextFormField(
                        controller: _githubLinkController,
                        cursorColor: kPurpleColor,
                        style: TextStyle(color: kGreyHeadTextcolor),
                        decoration: InputDecoration(
                          hintText: 'Enter your GitHub link',
                          filled: true,
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
                          fillColor: kGreyColor,
                          prefixIcon: Icon(
                            Icons.link,
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
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LinkedIn Link:",
                        style:
                            TextStyle(color: kGreyHeadTextcolor, fontSize: 14),
                      ),
                      TextFormField(
                        controller: _linkedinLinkController,
                        cursorColor: kPurpleColor,
                        style: TextStyle(color: kGreyHeadTextcolor),
                        decoration: InputDecoration(
                          hintText: 'Enter your LinkedIn link',
                          filled: true,
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
                          fillColor: kGreyColor,
                          prefixIcon: Icon(
                            Icons.link,
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
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hard Skills:',
                              style: TextStyle(
                                  color: kGreyHeadTextcolor, fontSize: 14)),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkillsChips(availableSkills: hardSkillsGroup1),
                                SkillsChips(availableSkills: hardSkillsGroup2),
                                SkillsChips(availableSkills: hardSkillsGroup3),
                                SkillsChips(availableSkills: hardSkillsGroup4),
                                SkillsChips(availableSkills: hardSkillsGroup5),
                                SkillsChips(availableSkills: hardSkillsGroup6),
                                SkillsChips(availableSkills: hardSkillsGroup7),
                                SkillsChips(availableSkills: hardSkillsGroup8),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Soft skills:',
                              style: TextStyle(
                                color: kGreyHeadTextcolor, fontSize: 14
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkillsChips(availableSkills: softSkillsGroup1),
                                SkillsChips(availableSkills: softSkillsGroup2),
                                SkillsChips(availableSkills: softSkillsGroup3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextButton(onPressed: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    print(context.read<SkillsProvider>().selectedSkills);
                    print("skills${prefs.getStringList('skills')}");
                  }, child: Text("data")),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _updateProfile(),
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        gradient: kPurpleGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Update Profile',
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
