import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveCircularProgressIndicator extends StatelessWidget {
  final lightTheme;
  AdaptiveCircularProgressIndicator([this.lightTheme = true]);
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      //this will make indicator bright!
      return Theme(
        data: ThemeData(
          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: lightTheme ? Brightness.dark : Brightness.light,
          ),
        ),
        child: CupertinoActivityIndicator(),
      );
      // return CupertinoActivityIndicator();
    }
    return CircularProgressIndicator(
      valueColor: lightTheme
          ? new AlwaysStoppedAnimation<Color>(Colors.white)
          : new AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }
}
