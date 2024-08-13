import 'package:flutter/material.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_node_auth/screens/Teacher/add_course_screen.dart';
import 'package:flutter_node_auth/screens/Teacher/manage_courses_screen.dart';
import 'package:flutter_node_auth/screens/profile_screen.dart';
import 'package:flutter_node_auth/services/auth_services.dart';
import 'package:provider/provider.dart';

import '../utils/constants.dart';
import '../widgets/card_courses.dart';
import '../widgets/header.dart';
import 'category_screen.dart';
import 'courses_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchControl = TextEditingController();
  late FocusNode myFocusNode;

  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchControl.dispose();
    myFocusNode.dispose();
    super.dispose();
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
                        Scaffold.of(context).openDrawer(); // Opens the Drawer
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
          children: _buildDrawerItems(
              user.role, context), // Build drawer items based on user role
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
                                    builder: (context) => CategoryScreen(),
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
                                        "Categories",
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
                  "Courses in progress",
                  style: TextStyle(
                    color: Constants.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                ListView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    // Replace this with your CardCourses widget
                    CardCourses(
                      image: Image.asset("assets/images/icon_1.png",
                          width: 40, height: 40),
                      color: Constants.lightPink,
                      title: "Adobe XD Prototyping",
                      hours: "10 hours, 19 lessons",
                      progress: "25%",
                      percentage: 0.25,
                      key: GlobalKey(),
                    ),
                    CardCourses(
                      image: Image.asset("assets/images/icon_2.png",
                          width: 40, height: 40),
                      color: Constants.lightYellow,
                      title: "Sketch shortcuts and tricks",
                      hours: "10 hours, 19 lessons",
                      progress: "50%",
                      percentage: 0.5,
                      key: GlobalKey(),
                    ),
                    CardCourses(
                      image: Image.asset("assets/images/icon_3.png",
                          width: 40, height: 40),
                      color: Constants.lightViolet,
                      title: "UI Motion Design in After Effects",
                      hours: "10 hours, 19 lessons",
                      progress: "75%",
                      percentage: 0.75,
                      key: GlobalKey(),
                    ),
                  ],
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
  if (role == 'Student') {
    return [
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
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
        leading: const Icon(Icons.home),
        title: const Text('Home'),
        onTap: () {
          Navigator.pop(context);
        },
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
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () {
          // signOutUser(context);
        },
      ),
    ];
  } else if (role == 'Teacher') {
    return [
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
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
        leading: const Icon(Icons.home),
        title: const Text('Home'),
        onTap: () {
          Navigator.pop(context);
        },
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
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () {
          // signOutUser(context);
        },
      ),
    ];
  } else {
    return [const Center()];
  }
}
