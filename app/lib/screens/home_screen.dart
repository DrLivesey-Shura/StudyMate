import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/models/course.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/Teacher/add_course_screen.dart';
import 'package:test/screens/Teacher/manage_courses_screen.dart';
import 'package:test/screens/Teacher/teacher_stats_screen.dart';
import 'package:test/screens/chatscreen.dart';
import 'package:test/screens/courses_screen.dart';
import 'package:test/screens/profile_screen.dart';
import 'package:test/services/auth_services.dart';
import 'package:test/services/course_service.dart';

import '../utils/constants.dart';
import '../widgets/card_courses.dart';
import '../widgets/header.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchControl = TextEditingController();
  late FocusNode myFocusNode;
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchControl.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  Future<List<Course>> _fetchCourses() async {
    User user = Provider.of<UserProvider>(context, listen: false).user;
    return await CourseService.fetchCourses(user.token);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 100),
        child: SafeArea(
          child: Builder(
            builder: (BuildContext context) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    height: 44,
                    width: 44,
                    child: TextButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _buildDrawerItems(user.role, context),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Header(),
          Padding(
            padding: EdgeInsets.all(Constants.mainPadding),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                SizedBox(height: Constants.mainPadding * 2),
                Text(
                  "Welcome back ${user.name}\n ${user.role}!",
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: Constants.mainPadding),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  child: TextField(
                    focusNode: myFocusNode,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Constants.textDark,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      hintText: "Search courses",
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Constants.textDark,
                        ),
                        onPressed: () {
                          debugPrint("Search pressed");
                        },
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    maxLines: 1,
                    controller: _searchControl,
                  ),
                ),
                SizedBox(height: Constants.mainPadding),
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: const Color(0xFFFEF3F3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Start Learning \nNew Stuff!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Constants.textDark,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            width: 150,
                            child: TextButton(
                              onPressed: () {
                                debugPrint("Pressed here");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CoursesScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Constants.salmonMain,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "Let's Begin",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward,
                                      color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        "assets/images/researching.png",
                        width: 200,
                        height: 104,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Text(
                  "Courses Overview",
                  style: TextStyle(
                    color: Constants.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                FutureBuilder<List<Course>>(
                  future: _coursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error fetching courses"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No courses available"));
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final course = snapshot.data![index];
                          return CardCourses(
                            image: Image.network(
                              course.poster.url,
                              width: 80,
                              height: 80,
                            ),
                            color: Constants.lightPink,
                            title: course.title,
                            hours: "${course.lectures.length} lessons",
                            key: GlobalKey(),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _buildDrawerItems(String role, BuildContext context) {
  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }

  if (role == 'Student') {
    return [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Constants.blueDark,
        ),
        child: const Center(
          child: Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.book),
        title: const Text('Courses'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CoursesScreen()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Profile'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.chat),
        title: const Text('Chat'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () {
          signOutUser(context);
        },
      ),
    ];
  } else if (role == 'Teacher') {
    return [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Constants.blueDark,
        ),
        child: Center(
          child: Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.book),
        title: const Text('Manage Courses'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageCoursesScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.add_box),
        title: const Text('Create Course'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCourseScreen()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Profile'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.bar_chart),
        title: Text('Course Statistics'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherStatsScreen(),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.chat),
        title: const Text('Chat'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () {
          signOutUser(context);
        },
      ),
    ];
  } else {
    return [const Center()];
  }
}
