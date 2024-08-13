import 'package:flutter/material.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/services/course_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import '../models/course.dart';
import 'package:video_player/video_player.dart';
import '../utils/constants.dart';

class CoursesScreen extends StatefulWidget {
  @override
  _CoursesScreenState createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses available'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                Course course = snapshot.data![index];
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15.0),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Constants.lightPink, // Replace with your color
                  ),
                  child: Column(
                    children: [
                      ExpansionTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(course.poster.url),
                          radius: 30,
                        ),
                        title: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          course.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        children: [
                          for (var i = 0; i < course.lectures.length; i++)
                            LectureTile(
                              lecture: course.lectures[i],
                              isFree: i == 0,
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            '${course.lectures.length} Videos',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}

class LectureTile extends StatefulWidget {
  final Lecture lecture;
  final bool isFree;

  LectureTile({required this.lecture, required this.isFree});

  @override
  _LectureTileState createState() => _LectureTileState();
}

class _LectureTileState extends State<LectureTile> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.lecture.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isSubscribed = user.subscription?.status == 'active';

    return Column(
      children: [
        ListTile(
          title: Text(widget.lecture.title),
          subtitle: Text(widget.lecture.description),
          trailing: !widget.isFree && !isSubscribed
              ? Icon(Icons.lock,
                  color: Colors.red) // Show a lock icon for paid lectures
              : null,
          onTap: !widget.isFree && !isSubscribed
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Subscribe to unlock this lecture')),
                  );
                }
              : null,
        ),
        if (widget.isFree || isSubscribed)
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  height: 200, // Set your preferred height
                  width: double.infinity, // Make it as wide as possible
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        if (widget.isFree || isSubscribed)
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
              ),
              Text(
                _controller.value.isPlaying ? 'Pause' : 'Play',
              ),
            ],
          ),
      ],
    );
  }
}
