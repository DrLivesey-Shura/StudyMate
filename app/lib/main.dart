import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/home_screen.dart';
import 'package:test/screens/signup_screen.dart';
import 'package:test/services/auth_services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  Stripe.publishableKey =
      "pk_test_51Pnn3DC1JQ2VbTUTai7ZicwfvlYd1vCWirJBRut4XSsQIay9HYWbfr425VwHgy1NmH01rOXoUD8VU8Lw8fmPCUF900HOXIolbP";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Node Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider.of<UserProvider>(context).user.token.isEmpty
          ? const SignupScreen()
          : HomeScreen(),
    );
  }
}
