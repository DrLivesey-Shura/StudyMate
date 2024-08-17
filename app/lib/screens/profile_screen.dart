import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:test/providers/user_provider.dart';
import 'package:test/utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CardFieldInputDetails _cardDetails = CardFieldInputDetails(complete: false);

  void handleSubscription(
      BuildContext context, String action, String userId) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    var token = user.user.token;
    try {
      if (action == "subscribe") {
        if (!_cardDetails.complete) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please complete the card details')),
          );
          return;
        }

        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                email: user.user.email,
              ),
            ),
          ),
        );

        print('Payment Method: $paymentMethod');

        final response = await http.post(
          Uri.parse('${Constants.uri}/api/subscribe'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'paymentMethodId': paymentMethod.id,
            'userId': userId,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subscription successful')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subscription failed: ${response.body}')),
          );
        }
      } else if (action == "cancel") {
        final response = await http.post(
           Uri.parse('${Constants.uri}/api/subscribe/cancel'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'userId': userId}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subscription canceled')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cancellation failed: ${response.body}')),
          );
        }
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);

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
              SizedBox(height: 30),
              if (user.user.role == 'Student')
                if (user.user.subscription != null &&
                    user.user.subscription?.status == 'active')
                  ElevatedButton(
                    onPressed: () =>
                        handleSubscription(context, "cancel", user.user.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("Cancel Subscription"),
                  )
                else
                  Column(
                    children: [
                      CardField(
                        onCardChanged: (details) {
                          setState(() {
                            _cardDetails = details!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => handleSubscription(
                            context, "subscribe", user.user.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text("Subscribe"),
                      ),
                    ],
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
      ),
    );
  }
}
