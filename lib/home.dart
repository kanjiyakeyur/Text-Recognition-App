import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File pickedImg;
  bool fatched = false;
  List<String> text = [];

  VisionText ans;
  void pickTheImage() async {
    File pickimge = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      pickedImg = pickimge;
    });
  }

  void mainFunction() async {
    //select the file
    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFilePath(pickedImg.path);

    //chose the option
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

    //send the data to server
    VisionText visionText = await textRecognizer.processImage(visionImage);
    ans = visionText;
    // print(visionText.blocks);

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          if (word.text.isEmpty) {
            continue;
          }
          //print(word.text);
          text.add(word.text.toString());
        }
      }
    }
    textRecognizer.close();

    setState(() {
      fatched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          fatched
              ? Expanded(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(48),
                      child: ListView.builder(
                        itemCount: text.length,
                        itemBuilder: (ctx, index) {
                          return Text(
                            text[index],
                            style: TextStyle(fontSize: 28),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: pickedImg != null
                      ? Container(
                          child: Image.file(
                            File(pickedImg.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: IconButton(
                            icon: Icon(Icons.camera_alt),
                            onPressed: pickTheImage,
                          ),
                        ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search), onPressed: mainFunction),
    );
  }
}
