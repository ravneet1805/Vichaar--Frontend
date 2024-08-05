import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vichaar/Services/apiServices.dart';
import 'package:vichaar/SnackBar/errorSnackBar.dart';
import '../../constant.dart';
import '../Components/myNavBar.dart';
import '../Components/skillsChips.dart';
import '../Provider/skillsProvider.dart';
import '../SnackBar/successSnackbar.dart';
 // Import your provider

class ChooseSkillsScreen extends StatefulWidget {
  File? image;
  String fullName;
  String bio;
  String linkedinLink;
  String gitHubLink;

  ChooseSkillsScreen({Key? key,

    required this.image,
    required this.fullName,
  required this.bio,
  required this.linkedinLink,
  required this.gitHubLink
    

  }): super(key: key);

  @override
  State<ChooseSkillsScreen> createState() => _ChooseSkillsScreenState();
}

class _ChooseSkillsScreenState extends State<ChooseSkillsScreen> {
  bool loading = false;
  Future<void> saveDetails(BuildContext context, List<String> selectedSkills) async {
    setState(() {
      loading = true;
    });

    const url = '${ApiService.baseUrl}/users/updatesignup'; 

    String? token;
  
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('user_token') ?? '';
  


    final request = http.MultipartRequest('POST', Uri.parse(url));
    print('tokennnnnnnnnnnnn:'+ token);

    request.headers['Authorization'] = 'bearer $token';
    request.headers['Content-Type'] = 'application/json';

    print("fullName: "+ widget.fullName);
    print("bio: "+ widget.bio);
    print("github: "+ widget.gitHubLink);
    print("linkedin: "+ widget.linkedinLink);
    print("image: "+ widget.image.toString());
    print("skills: "+ selectedSkills.toString());
    

    request.fields.addAll({
      'fullName': widget.fullName,
      'bio': widget.bio,
      'githubLink': widget.gitHubLink,
      'linkedinLink': widget.linkedinLink,
      'skills': json.encode(selectedSkills),
    });

    if (widget.image != null) {
      var stream = new http.ByteStream(widget.image!.openRead());
      stream.cast();

      var length = await widget.image!.length();
      final imageFile = await http.MultipartFile('photo', stream, length);
      request.files.add(imageFile);
    }

    var response = await request.send();
    
    

    // Upload image logic here
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {

      setState(() {
        loading = false;
      });
      
      final responseData = json.decode(responseBody);


      SuccessSnackbar.show(context, responseData['message']);


      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('name', responseData['user']['fullName']?? '');
      prefs.setString('bio', responseData['user']['bio']);
      prefs.setString('githubLink', responseData['user']['githubLink'] ?? '');
        prefs.setString('linkedinLink', responseData['user']['linkedinLink'] ?? '');
        List<String> skillsList =
            (responseData['user']['skills'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
        prefs.setStringList('skills', skillsList);
        prefs.setString('image', responseData['user']['image'] ?? '');

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyNavbar()),
          (Route<dynamic> route) => false);

      print(responseData);
    } else {

      setState(() {
        loading = false;
      });
      final responseData = json.decode(responseBody);

      ErrorSnackbar.show(context, responseData['message']);

      
      print('Error: ${response.statusCode}');
      print('Response: ${responseBody}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          'Choose Your Skills',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Select any 5 skills that best describe you.',
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hard skills:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      if(loading == false){
                      final selectedSkills = context.read<SkillsProvider>().selectedSkills;
                      print('Selected Skills: $selectedSkills');
                      saveDetails(context, selectedSkills);
                      }
                      // Implement save logic here
                    },
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        gradient: kPurpleGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child:
                        loading
                        ? CupertinoActivityIndicator(
                          color: Colors.white
                        )
                         :Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
