import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/services/course_service.dart';

class TeacherStatsScreen extends StatefulWidget {
  @override
  _TeacherStatsScreenState createState() => _TeacherStatsScreenState();
}

class _TeacherStatsScreenState extends State<TeacherStatsScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    User user = Provider.of<UserProvider>(context, listen: false).user;
    final response = await CourseService.fetchCourseStats(user.token);
    return response['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Statistics'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            final stats = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Total Subscribers: ${stats['subscription']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Total Views: ${stats['views']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Engagement: ${stats['users']} users',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // Add any charts or detailed statistics here
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
