import 'package:flutter/material.dart';

import '../widgets/circular_loading_spinner.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/chat_icon.png'),
          SizedBox(
            height: 10,
          ),
          AdaptiveCircularProgressIndicator(),
        ],
      ),
    );
  }
}
