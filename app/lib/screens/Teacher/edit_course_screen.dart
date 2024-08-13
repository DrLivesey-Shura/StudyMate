import 'package:flutter/material.dart';
import 'package:flutter_node_auth/models/course.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_node_auth/services/course_service.dart';
import 'package:provider/provider.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;

  EditCourseScreen({required this.course});

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late String category;
  late String createdBy;

  @override
  void initState() {
    super.initState();
    title = widget.course.title;
    description = widget.course.description;
    category = widget.course.category;
    createdBy = widget.course.createdBy;
  }

  void updateCourse() async {
    User user = Provider.of<UserProvider>(context, listen: false).user;

    if (_formKey.currentState!.validate()) {
      await CourseService.updateCourse(
          context: context,
          courseId: widget.course.id,
          title: title,
          description: description,
          category: category,
          createdBy: createdBy,
          token: user.token);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
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
                initialValue: description,
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
                initialValue: category,
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
                initialValue: createdBy,
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
              ElevatedButton(
                onPressed: updateCourse,
                child: Text('Update Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
