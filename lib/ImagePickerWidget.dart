import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:base64/base64.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ImagePickerWidget(),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  final picker = ImagePicker();
  String? message = "";

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _uploadImage() async {
    if (_image == null) {
      print('No image selected. Please select an image first.');
      return;
    }

    // Send the image to your backend for processing
    /* final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/process-image'),
      body: jsonEncode(<String, dynamic>{
        'image': base64Encode(_image!.readAsBytesSync()),
      }),
    );*/

    final request = http.MultipartRequest("POST",
        Uri.parse("https://69fa-102-101-136-88.ngrok-free.app/process-image"));

    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile(
        'image', _image!.readAsBytes().asStream(), _image!.lengthSync(),
        filename: _image!.path.split("/").last));

    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    setState(() {
      
    });
    // Process the response from your backend
    /*if (response.statusCode == 200) {
      print('Image uploaded and processed successfully.');
    } else {
      print('Failed to upload and process the image.');
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child:
              _image == null ? Text('No image selected.') : Image.file(_image!),
        ),
        ElevatedButton(
          child: Text('Select an image'),
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
        ElevatedButton(
          child: const Text('Take a photo'),
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        ElevatedButton(
          child: Text('Send the image'),
          onPressed: _uploadImage,
        ),
      ],
    );
  }
}
