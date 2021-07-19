import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './Animation/fade_animation.dart';
import '../circular_loading_spinner.dart';
import '../pickers/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
  ) submitFn;

  final isLoading;

  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var formData = {
    'userEmail': '',
    'userName': '',
    'userPassword': '',
  };
  var _fadeController;
  var _fadeAnimation;
  var _slideAnimation;
  var _userImageFile;
  var showPassword = false;

  bool isValidMail(String mailId) {
    return RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(mailId);
  }

  Future<bool> _showAlertDialogMessage(
    String titleMessage,
    String contentMessage,
  ) async {
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
              child: Text('No, Set default.'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: Text('Yes, Let me choose.'),
            ),
          ],
        ),
      );
    } else {
      return showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(titleMessage),
          content: Text(
            contentMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
              child: Text('No, Set default.'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: Text('Yes, Let me choose.'),
            ),
          ],
        ),
      );
    }
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState.validate();

    FocusScope.of(context)
        .unfocus(); //This will close the softkeyboard if it is open.

    //check profile picture only when user is SIGNINGUP.
    if (!_isLogin && _userImageFile == null) {
      var setPicture = await _showAlertDialogMessage(
        'Set Profile Picture',
        'Wanna set a cool profile picture for your account?',
      );
      if (setPicture) {
        //let user choose the profile picture.
        print('user choosed to chose image on own..');
        return;
      } else {
        //set default proflie picture.
        print('setting default profile picture.');
        // return;
      }
    }

    if (isValid) {
      _formKey.currentState.save();
      // print(formData['userEmail']);
      // print(formData['userName']);
      // print(formData['userPassword']);
      //Use the formdata to send our auth request to firebase...
      print(
          'AUTH SIGN IN DATA : ${formData['userEmail'].trim()} ${formData['userPassword'].trim()}  ${formData['userName'].trim()} $_userImageFile $_isLogin');
      widget.submitFn(
        formData['userEmail'].trim(),
        formData['userPassword'].trim(),
        formData['userName'].trim(),
        _userImageFile,
        _isLogin,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(_fadeController);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeAnimation(
                          1,
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-1.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(
                          1.3,
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-2.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(
                          1.5,
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/clock.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: FadeAnimation(
                          1.6,
                          Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Text(
                                  _isLogin ? "Login" : "SignUp",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!_isLogin)
                        //PROFILE PIC
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: UserImagePicker(_pickedImage),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  // padding: EdgeInsets.all(
                  //   30.0,
                  // ),
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 30.0,
                    left: 30.0,
                    right: 30.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(
                        1.8,
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Color.fromRGBO(143, 148, 251, .2),
                                        blurRadius: 20.0,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[100],
                                        ),
                                      ),
                                    ),
                                    //EMAIL
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: TextFormField(
                                        autocorrect:
                                            false, //can be annoying for some user!
                                        textCapitalization: TextCapitalization
                                            .none, //not capitalize characters.
                                        enableSuggestions:
                                            false, //turn off suggestions.
                                        key: ValueKey('email'),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Email address',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Enter Email!';
                                          } else if (!isValidMail(value)) {
                                            return 'Invalid Email';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          formData['userEmail'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  if (!_isLogin)
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey[100],
                                          ),
                                        ),
                                      ),
                                      //USERNAME
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: TextFormField(
                                          autocorrect: true,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          enableSuggestions: false,
                                          key: ValueKey('username'),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Username",
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Enter Username!';
                                            } else if (value.length < 4) {
                                              return 'Please enter atleast 4 characters';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            formData['userName'] = value;
                                          },
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    //PASSWORD
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: TextFormField(
                                        obscureText:
                                            !showPassword, //hides the text entered by the user.
                                        key: ValueKey('password'),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Password",
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              print(
                                                  'password show : $showPassword');
                                              setState(() {
                                                showPassword = !showPassword;
                                              });
                                            },
                                            icon: showPassword
                                                ? Icon(
                                                    Icons.visibility_off,
                                                    color: Colors.blue,
                                                  )
                                                : Icon(
                                                    Icons.visibility,
                                                    color: Colors.blue,
                                                  ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Enter Password!';
                                          } else if (value.length < 8) {
                                            return 'Password must be atleast 8 characters long';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          formData['userPassword'] = value;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // if (!_isLogin)
                            //   //PROFILE PIC
                            //   Positioned(
                            //     // top: 0,
                            //     top: -50,
                            //     child: UserImagePicker(),
                            //   ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                        2,
                        InkWell(
                          onTap: _trySubmit,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(143, 148, 251, 1),
                                  Color.fromRGBO(143, 148, 251, .6),
                                ],
                              ),
                            ),
                            child: Center(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                //SUBMIT BUTTON
                                child: widget.isLoading
                                    ? AdaptiveCircularProgressIndicator()
                                    : Text(
                                        _isLogin ? 'Login' : 'SignUp',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                        1.5,
                        InkWell(
                          onTap: () {
                            _fadeController.forward();

                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              setState(() {
                                _isLogin = !_isLogin;
                                // _fadeController.reverse();
                              });
                              _fadeController.reverse();
                            });
                          },
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              _isLogin
                                  ? 'Create a new account'
                                  : 'I already have an account',
                              style: TextStyle(
                                color: Color.fromRGBO(143, 148, 251, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    //END
  }
}





/*
OLDER IMPLEMENTATION : 
return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, //take the space as much as needed.
                children: [
                  //Email
                  TextFormField(
                    key: ValueKey('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Email!';
                      } else if (!isValidMail(value)) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      formData['userEmail'] = value;
                    },
                  ),
                  //UserName
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('username'),
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Username!';
                        } else if (value.length < 4) {
                          return 'Please enter atleast 4 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        formData['userName'] = value;
                      },
                    ),
                  //Password
                  TextFormField(
                    key: ValueKey('password'),
                    obscureText: true, //hides the text entered by the user.
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Password!';
                      } else if (value.length < 8) {
                        return 'Password must be atleast 8 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      formData['userPassword'] = value;
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  //Login
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(_isLogin ? 'Login' : 'SignUp'),
                  ),
                  //SignUp
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Theme.of(context)
                          .primaryColor, //ensures that button has primary color.
                    ),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin
                        ? 'Creat a new account'
                        : 'I already have an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
*/