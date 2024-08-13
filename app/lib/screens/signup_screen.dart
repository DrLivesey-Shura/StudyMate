import 'package:flutter/material.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_node_auth/custom_textfield.dart';
import 'package:flutter_node_auth/screens/login_screen.dart';
import 'package:flutter_node_auth/services/auth_services.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final AuthService authService = AuthService();
  File? _image;
  Uint8List? _imageBytes;
  String? _fileName;

  Future<void> _pickImage() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _imageBytes = reader.result as Uint8List;
          _fileName = files[0].name;
        });
      });
    });
  }

  Future<void> signupUser() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an avatar image')),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.uri}/api/register'),
    );

    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    request.fields['name'] = nameController.text;
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      _imageBytes!,
      filename: _fileName,
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      showSnackBar(
          context, 'Account created! Login with the same credentials!');
    } else {
      showSnackBar(context, 'Error: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Signup",
            style: TextStyle(fontSize: 30),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage:
                  _imageBytes != null ? MemoryImage(_imageBytes!) : null,
              child: _imageBytes == null
                  ? const Icon(Icons.camera_alt, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: nameController,
              hintText: 'Enter your name',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: emailController,
              hintText: 'Enter your email',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: passwordController,
              hintText: 'Enter your password',
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: signupUser,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              textStyle: MaterialStateProperty.all(
                const TextStyle(color: Colors.white),
              ),
              minimumSize: MaterialStateProperty.all(
                Size(MediaQuery.of(context).size.width / 2.5, 50),
              ),
            ),
            child: const Text(
              "Sign up",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Login User?'),
          ),
        ],
      ),
    );
  }
}
