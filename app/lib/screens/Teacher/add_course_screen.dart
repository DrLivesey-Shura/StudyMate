import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/services/course_service.dart';
import 'dart:typed_data';
// import 'dart:html' as html;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
        _fileName = image.name;
      });
    }
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
