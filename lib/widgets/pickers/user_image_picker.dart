import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  UserImagePicker(this.imagePickFn);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  var isProfilePicSet = false;

  Future<bool> _showPickerDialogMessage() async {
    var title = 'Profile Picture';
    var subtitle = 'Choose your profile picture';
    var takePhoto = 'Take Photo';
    var chooseFromGallery = 'Choose from Gallery';
    if (Platform.isAndroid) {
      return await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(
            subtitle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
                // return ImageSource.camera;
              },
              child: Text(takePhoto),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
                // return ImageSource.gallery;
              },
              child: Text(chooseFromGallery),
            ),
          ],
        ),
      );
    } else {
      return await showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(
            subtitle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
                // return ImageSource.camera;
              },
              child: Text(takePhoto),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
                // return ImageSource.gallery;
              },
              child: Text(chooseFromGallery),
            ),
          ],
        ),
      );
    }
  }

  void _pickImage() async {
    print('checking ...');
    var imagePicker = ImagePicker();
    bool isCamera = await _showPickerDialogMessage();
    var _pickedImageFile = await imagePicker.getImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality:
          50, //compresses image. here 50 means 50% quality. 100% means original image! We are doing this to save some space in firebase and also making image uploading fast when user signup.
      maxWidth: 150,
    );
    if (_pickedImageFile != null) {
      setState(() {
        _pickedImage = File(_pickedImageFile.path);
        isProfilePicSet = true;
      }); 

      widget.imagePickFn(_pickedImage); //forwarding image file.
    } else {
      print('No image chosen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('picker1 called.');
        _pickImage();
      },
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 8.0,
              offset: Offset(0.0, 5.0),
            ),
          ],
        ),
        child: isProfilePicSet
            ? CircleAvatar(
                backgroundImage: FileImage(_pickedImage),
              )
            : Padding(
                padding: EdgeInsets.all(4.0),
                child: Center(
                  child: Container(
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      color: Colors.blue,
                    ),

                    // child: Icon(Icons.person),
                  ),
                ),
              ),
      ),
    );
  }
}
