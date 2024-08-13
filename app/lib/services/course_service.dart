import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/course.dart';
import '../utils/constants.dart';

class CourseService {
  static Future<List<Course>> fetchCourses(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.uri}/api/courses'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['courses'];
      List<Course> courses =
          data.map((course) => Course.fromMap(course)).toList();

      // Fetch lectures for each course
      for (Course course in courses) {
        course.lectures = await fetchLectures(course.id, token);
      }

      return courses;
    } else {
      throw Exception('Failed to load courses');
    }
  }

  static Future<List<Lecture>> fetchLectures(
      String courseId, String token) async {
    final response = await http.get(
      Uri.parse('${Constants.uri}/api/course/$courseId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['lectures'];
      return data.map((lecture) => Lecture.fromMap(lecture)).toList();
    } else {
      throw Exception('Failed to load lectures');
    }
  }
}
