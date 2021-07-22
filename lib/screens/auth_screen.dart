import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _showAlertDialogMessage(
    String titleMessage,
    String contentMessage,
    String buttonTitle,
  ) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(buttonTitle),
            ),
          ],
        ),
      );
    }
  }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
  ) async {
    print('Data received : $email $password $username $isLogin');
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        var url;
        if (image == null) {
          url =
              'https://firebasestorage.googleapis.com/v0/b/mychat-theflutterapp.appspot.com/o/user_images%2Fperson_placeholder.png?alt=media&token=d731be98-e167-46fe-a5c1-52744d3fdf23';
        } else {
          //... perform image upload
          final ref = FirebaseStorage.instance.ref().child('user_images').child(
              '${authResult.user.uid}.jpg'); //this ref() will point at main root bucket. user_iamges folder will be created if not present.

          //NEWER APPROACH :
          //profile pic upload
          await ref.putFile(
              image); //uploads the image. we can also set meta data along with this. This returns a kind of future which StorageUploadTask. if we apply onComplete then we can await here!
          //profile pic upload

          //OLDER APPROACH :
          // await ref
          //     .putFile(image)
          //     .onComplete; //uploads the image. we can also set meta data along with this. This returns a kind of future which StorageUploadTask. if we apply onComplete then we can await here!

          //receiving url for just uploaded image.
          url = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
        }); //accessing already created userid with firestore! and adding username with this.Here we saved a map attached with user which contains useremail and username.
      }
      setState(() {
        _isLoading = false;
      });
    } on PlatformException catch (err) {
      //PlatformException is an error which can be thrown by FIREBASE.
      var message = 'An error occurred, please check you credentials!';
      if (err.message != null) {
        message = err.message;
      }
      setState(() {
        _isLoading = false;
      });
      _showAlertDialogMessage('Oops', message, 'Okay');
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
