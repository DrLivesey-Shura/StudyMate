import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_node_auth/services/course_service.dart';
import 'dart:html' as html;

import 'package:provider/provider.dart';

import '../../models/user.dart';

class AddCourseScreen extends StatefulWidget {
  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String category = '';
  String createdBy = '';
  Uint8List? _imageBytes;
  String? _fileName;

  // Method to pick image from gallery
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

  void addCourse() async {
    User user = Provider.of<UserProvider>(context, listen: false).user;

    if (_formKey.currentState!.validate()) {
      if (_imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an avatar image')),
        );
        return;
      }

      await CourseService.addCourse(
        context: context,
        title: title,
        description: description,
        category: category,
        createdBy: createdBy,
        token: user.token,
        image: _imageBytes!,
        fileName: _fileName!,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) => title = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                onChanged: (value) => category = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Created By'),
                onChanged: (value) => createdBy = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the creator\'s name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!,
                        height: 100, width: 100, fit: BoxFit.cover)
                    : Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey[200],
                        child: Icon(Icons.add_a_photo),
                      ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addCourse,
                child: Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
