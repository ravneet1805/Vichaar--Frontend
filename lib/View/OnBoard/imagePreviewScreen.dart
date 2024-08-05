import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vichaar/constant.dart';

class PreviewScreen extends StatefulWidget {
  final XFile file;

  PreviewScreen({Key? key, required this.file}) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String? croppedImagePath;

  Future<void> _cropImage() async {
    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.green,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    );

    if (croppedFile != null) {
      setState(() {
        croppedImagePath = croppedFile.path;
      });
    }
  }

  void _proceedToNextScreen() {
    String imagePath = croppedImagePath ?? widget.file.path;
    // Proceed to the next screen with the cropped image
    // Example: Navigator.push(...)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          croppedImagePath != null
              ? Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.file(
                      File(croppedImagePath!),
                      height: MediaQuery.of(context).size.height / 1.2,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.center,
                  child: Image.file(
                    File(widget.file.path),
                    width: double.maxFinite,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Preview Your Image Before Proceeding.',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: _cropImage,
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: kPurpleColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(Icons.crop, size: 30),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _proceedToNextScreen,
                            child: Container(
                              height: 70,
                              width: 260,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Proceed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
