import 'package:flutter/material.dart';
import 'package:flutter_node_auth/providers/user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  child: SvgPicture.network(
                    user.user.avatar.url,
                    placeholderBuilder: (BuildContext context) =>
                        CircularProgressIndicator(),
                    height: 100,
                    width: 100,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  user.user.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  user.user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  user.user.role,
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text("Logout"),
                ),
              ],
            ),
          ),
        ));
  }
}
