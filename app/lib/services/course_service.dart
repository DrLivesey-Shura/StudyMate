import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test/utils/utils.dart';
import 'dart:typed_data';

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

  static Future<void> addCourse({
    required BuildContext context,
    required String title,
    required String description,
    required String category,
    required String createdBy,
    required String fileName,
    required String token,
    required Uint8List image,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.uri}/api/createcourse'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['createdBy'] = createdBy;
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      image,
      filename: fileName,
    ));
    var res = await request.send();
    if (res.statusCode == 201) {
      showSnackBar(context, 'Course created successfully!');
    } else {
      showSnackBar(context, 'Failed to create course');
    }
  }

  static Future<void> deleteCourse(String courseId, String token) async {
    final response = await http.delete(
      Uri.parse('${Constants.uri}/api/course/$courseId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete course');
    }
  }

  static Future<void> updateCourse({
    required BuildContext context,
    required String courseId,
    required String title,
    required String description,
    required String category,
    required String createdBy,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('${Constants.uri}/api/course/$courseId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'createdBy': createdBy,
      }),
    );

    if (response.statusCode == 200) {
      showSnackBar(context, 'Course updated successfully!');
    } else {
      showSnackBar(context, 'Failed to update course');
    }
  }

  static Future<void> addLecture({
    required BuildContext context,
    required String courseId,
    required String title,
    required String description,
    required Uint8List video,
    required String token,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.uri}/api/course/$courseId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.files.add(http.MultipartFile.fromBytes('file', video as List<int>,
        filename: 'lecture_video.mp4'));

    var res = await request.send();
    print('respo0nse : ${res.statusCode}');
    if (res.statusCode == 200) {
      showSnackBar(context, 'Lecture added successfully!');
    } else {
      showSnackBar(context, 'Failed to add lecture');
    }
  }

  static Future<Map<String, dynamic>> fetchCourseStats(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.uri}/api/course-stats'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('response ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load course stats');
    }
  }
}
