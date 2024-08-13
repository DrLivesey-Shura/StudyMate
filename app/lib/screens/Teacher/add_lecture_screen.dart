import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_node_auth/services/course_service.dart';

class AddLectureScreen extends StatefulWidget {
  final String courseId;

  AddLectureScreen({required this.courseId});

  @override
  _AddLectureScreenState createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  Uint8List? _video;

  void pickVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedVideo =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      // Ensure correct typing with Uint8List
      _video = Uint8List.fromList(await pickedVideo.readAsBytes());
      setState(() {});
    } else {
      // If no video is picked
      showSnackBar(context, 'No video selected');
    }
  }

  void addLecture() async {
    if (_formKey.currentState!.validate()) {
      if (_video == null) {
        showSnackBar(context, 'Please select a video');
        return;
      }

      await CourseService.addLecture(
        context: context,
        courseId: widget.courseId,
        title: title,
        description: description,
        video: _video!,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Lecture'),
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: pickVideo,
                child: _video != null
                    ? Text('Video selected')
                    : Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey[200],
                        child: Icon(Icons.add_to_photos),
                      ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: addLecture,
                child: Text('Add Lecture'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
