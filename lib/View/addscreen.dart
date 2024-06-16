import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vichaar/constant.dart';

import '../Services/apiServices.dart';

class AddScreen extends StatelessWidget {
  AddScreen({Key? key}) : super(key: key);
  final TextEditingController titleController = TextEditingController();

  Future<void> saveNote(BuildContext context) async {
    final String noteTitle = titleController.text;

    ApiService apiService = ApiService();

    final bool success = await apiService.saveNote(noteTitle);

    if (success) {
      // Note saved successfully, you can navigate back or perform other actions
      titleController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Posted Successfully.'),
        ),
      );
    } else {
      // Handle errors, you can show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save note. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Text(
                'Share Your Vichaar',
                style: TextStyle(
                  color: Colors.white,
                  // fontSize: 30,
                  // fontWeight: FontWeight.bold,
                ),
              ),
        ),
            centerTitle: false,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Let your thoughts take shape.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                //fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: TextField(
                controller: titleController,
                maxLength: 500,
                expands: true,
                maxLines: null,
                minLines: null,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kGreyColor,
                  hintText: 'Write your post here',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Call the function to save the note
                saveNote(context);
                FocusScope.of(context).unfocus();
              },
              style: ButtonStyle(
                backgroundColor:MaterialStatePropertyAll(Colors.white) ,

                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12.0),)),
                fixedSize: MaterialStatePropertyAll(Size(double.maxFinite, 50))
              ),
              child: Text(
                'POST',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
