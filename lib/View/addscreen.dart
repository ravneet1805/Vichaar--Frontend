import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:vichaar/Components/skillsChips.dart';
import 'package:vichaar/SnackBar/errorSnackBar.dart';
import 'package:vichaar/SnackBar/successSnackbar.dart';
import 'package:vichaar/View/chooseSkills.dart';
import 'package:vichaar/constant.dart';

import '../Provider/skillsProvider.dart';
import '../Services/apiServices.dart';

class AddScreen extends StatefulWidget {
  AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController titleController = TextEditingController();

  bool loader = false;

  Future<void> saveNote() async {
    final String noteTitle = titleController.text;


    final selectedSkills = context.read<SkillsProvider>().selectedSkills;


    ApiService apiService = ApiService();
    setState(() {
      loader = true;
    });
    print(loader);

    final bool success = await apiService.saveNote(
      noteTitle,
      selectedSkills,
      _imageFile,
    );

    if (success) {
      setState(() {
        loader = false;
        context.read<SkillsProvider>().clearSkills();
      });

      // Note saved successfully, you can navigate back or perform other actions
      titleController.clear();
      _removeImage();

      SuccessSnackbar.show(context, 'Posted Successfully.');
    } else {
      // Handle errors, you can show an error message to the user
      setState(() {
        loader = false;
      });

      ErrorSnackbar.show(context, 'Failed to save note. Please try again.');
    }
  }

  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = pickedFile;
      print(_imageFile.toString());
    });
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("Create"),
        actions: [Container(), postButton(context)],
        centerTitle: false,
        backgroundColor: kGreyColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(gradient: kBgGradient),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description: *',
                      style: TextStyle(color: kGreyHeadTextcolor, fontSize: 18),
                    ),
                    Container(
                      height: 200,
                      child: TextField(
                        controller: titleController,
                        textAlignVertical: TextAlignVertical.top,
                        maxLength: 500,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        onTapOutside: (PointerDownEvent event) {
                          FocusScope.of(context).unfocus();
                        },
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          counterStyle: TextStyle(),
                          //filled: true,
                          //fillColor: kGreyColor,
                          hintText:
                              'A brief, compelling summary of your idea...',
                          hintStyle: TextStyle(
                              color: Colors.white24,
                              fontSize: 14,
                              overflow: TextOverflow.visible),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    if (_imageFile != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.contain,
                                height: 200,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.black87,
                                  size: 24,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20.0,
                        //horizontal: 16
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            CupertinoIcons.photo,
                            color: Colors.white24,
                            size: 30,
                            weight: 0.8,
                          ),
                          onPressed: () => _pickImage(),
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Required Skills:',
                        style:
                            TextStyle(color: kGreyHeadTextcolor, fontSize: 18)),
                    SizedBox(height: 16),
                     Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hard skills:',
                        style: TextStyle(
                          fontSize: 14,
                         
                          color: kGreyHeadTextcolor,
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
                         
                          color: kGreyHeadTextcolor,
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
                TextButton(onPressed: (){
                  final selectedSkills = context.read<SkillsProvider>().selectedSkills;
                      print('Selected Skills: $selectedSkills');
                }, child: Text("button"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget postButton(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: SizedBox(
        height: 32,
        child: Container(
          decoration: BoxDecoration(
              gradient: kPurpleGradient,
              borderRadius: BorderRadius.circular(12)),
          child: ElevatedButton(
            onPressed: () {
              // Call the function to save the note
              if (!loader) {
                saveNote();
              }

              FocusScope.of(context).unfocus();
            },
            style: ButtonStyle(
              shadowColor: WidgetStateColor.transparent,
              backgroundColor: WidgetStateColor.transparent,
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            child: loader
                ? CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                : Text(
                    'Post',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
