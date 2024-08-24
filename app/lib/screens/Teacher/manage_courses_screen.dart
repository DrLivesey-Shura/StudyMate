import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/models/course.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/Teacher/add_lecture_screen.dart';
import 'package:test/screens/Teacher/edit_course_screen.dart';
import 'package:test/services/course_service.dart';

class ManageCoursesScreen extends StatefulWidget {
  @override
  _ManageCoursesScreenState createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  Future<List<Course>> _fetchCourses() async {
    User user = Provider.of<UserProvider>(context, listen: false).user;

    return await CourseService.fetchCourses(user.token);
  }

  void deleteCourse(String courseId) async {
    User user = Provider.of<UserProvider>(context, listen: false).user;

    await CourseService.deleteCourse(courseId, user.token);
    setState(() {
      _coursesFuture = _fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Courses'),
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No courses available'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Course course = snapshot.data![index];
                return ListTile(
                  title: Text(course.title),
                  subtitle: Text(course.description),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditCourseScreen(course: course),
                          ),
                        );
                      } else if (value == 'delete') {
                        deleteCourse(course.id);
                      } else if (value == 'add_lecture') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddLectureScreen(courseId: course.id),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'add_lecture',
                        child: Text('Add Lecture'),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
