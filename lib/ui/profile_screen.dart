import 'dart:io';
import 'package:krima_practical/util/share_pref.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File _image;
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  // String _name,_mobile,_email;
  GlobalKey<FormState> _profileFormKey;

  @override
  void initState() {
    _profileFormKey = new GlobalKey<FormState>();
    // _getProfileDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: baseBodyWidget(),
    );
  }

  baseBodyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                profileCircleWidget(),
                Container(
                  margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                  child: Form(
                    key: _profileFormKey,
                    child: Column(
                      children: [
                        nameTextInputWidget(),
                        SizedBox(
                          height: 15,
                        ),
                        mobileTextInputWidget(),
                        SizedBox(
                          height: 15,
                        ),
                        emailTextInputWidget()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        saveButton()
      ],
    );
  }

  profileCircleWidget() {
    return Container(
        margin: EdgeInsets.only(top: 50),
        child: Center(
            child: Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey,
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50)),
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                        size: 45,
                      ),
                    ),
            ),
          ),
        )));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
    print('imagepath---->$_image');
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
    print('imagepath---->$_image');
  }

  nameTextInputWidget() {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: _nameController,
        validator: (input) => input.length == 0
            ? 'Please Enter Name'
            : input != null && input.length < 2
                ? 'Name should be more than 2 letter '
                : null,
        inputFormatters: [
          WhitelistingTextInputFormatter(RegExp('[a-zA-Z ]')),
        ],
        decoration: InputDecoration(
          hintText: 'Name',
          suffixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ));
  }

  mobileTextInputWidget() {
    return TextFormField(
        keyboardType: TextInputType.phone,
        controller: _mobileController,
        validator: (input) => input.length == 0
            ? 'Please Enter Mobile Number'
            : input.length < 10 || input.length > 10
                ? 'Please enter 10 digit mobile number '
                : null,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          hintText: 'Mobile Number',
          suffixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ));
  }

  emailTextInputWidget() {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        validator: (input) => input.length == 0
            ? 'Please Enter Email'
            : !(RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                    .hasMatch(input))
                ? 'Please Enter Valid Email'
                : null,
        controller: _emailController,
        decoration: InputDecoration(
          hintText: 'Email',
          suffixIcon: Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ));
  }

  saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.only(bottom: 30, left: 25, right: 20, top: 30),
      child: RaisedButton(
        onPressed: () {
          saveProfileDetail();
        },
        child: Text(
          'Save',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textColor: Colors.white,
        color: Colors.blue,
        elevation: 0,
      ),
    );
  }

  void saveProfileDetail() async {
    if (_profileFormKey.currentState.validate()) {
      _profileFormKey.currentState.save();
      if (_image != null && _image.path != null) {
        UserPreferences().saveUserEmail(_emailController.text);
        UserPreferences().saveUserName(_nameController.text);
        UserPreferences().saveMobileNumber(_mobileController.text);
        UserPreferences.saveImageToPreferences(
            UserPreferences.base64String(_image.readAsBytesSync()));
        UserPreferences().saveIsLogin(true);

        Toast.show("Profile Information Save Successfully", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        Toast.show("Please Select Profile Picture", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }
  }

//  _getProfileDetail()async {
//   bool isLogin=false;
//   isLogin=await UserPreferences().getLoginStatus();
//   if(isLogin!=null && isLogin)
//     {
//       _email=await UserPreferences().getUserEmail();
//       _mobile=await UserPreferences().getMobileNumber();
//       _name=await UserPreferences().getUserName();
//       _nameController.text=_name;
//       _emailController.text=_email;
//       _mobileController.text=_mobile;
//     }
//
// }

}
