import 'package:flutter/material.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:krima_practical/util/country_list.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  CountryCode _selectedCountry;
  final mobileController=TextEditingController();


  FirebaseAuth _auth = FirebaseAuth.instance;
  List<CountryCode> elements = countriesEnglish
      .map((s) => CountryCode(
            name: s['name'],
            code: s['code'],
            dialCode: s['dial_code'],
            flagUri: 'flags/${s['code'].toLowerCase()}.png',
          ))
      .toList();

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      Navigator.of(context).pushReplacementNamed('/otpscreen');
      // smsOTPDialog(context).then((value) {
      //   print('sign in');
      // });
    };
    print('phone number--->${phoneNo}');
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo,
          // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent: smsOTPSent,
          // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (Exception exceptio) {
            print('${exceptio.toString()}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  if (_auth.currentUser != null) {
                    if (_auth.currentUser.displayName != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/homepage');
                    }
                  } else {
                    signIn();
                  }


                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );

      _auth.signInWithCredential(credential).then((value) {
        // Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/homepage');
      }).catchError((e) {
        print(e);
      });
    } catch (e) {
      print(e);
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        // Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/otpscreen');
        // smsOTPDialog(context).then((value) {
        //   print('sign in');
        // });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body:
     baseBodyWidget()
    );
  }

  @override
  void initState() {
    mobileController.text=_selectedCountry!=null?_selectedCountry.dialCode:"+91";
  }

  Widget countryDropDownWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: DropdownButton<CountryCode>(
        isExpanded: true,
        value: _selectedCountry,
        hint: Text('India'),

        items: elements.map((value) {
          return new DropdownMenuItem(
            value: value,
            child: new Text(value.name),
          );
        }).toList(),
        onChanged: (name) {
          setState(() {
            _selectedCountry = name;
            mobileController.text=_selectedCountry!=null?_selectedCountry.dialCode:"+91";
          });
        },


      ),
    );
  }

  Widget countryCodeTextWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 10, top: 20),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Country Code: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              '${_selectedCountry != null && _selectedCountry.code != null ? _selectedCountry.code : 'IN'}',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  phoneTextInputWidget() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: TextField(
        controller: mobileController,
        decoration: InputDecoration(
            hintText: 'Enter Mobile Number'),
        onChanged: (value) {
          this.phoneNo = value;
        },
      ),
    );
  }

 Widget errorTextWidget() {
    return  (errorMessage != ''
        ? Text(
      errorMessage,
      style: TextStyle(color: Colors.red),
    )
        : Container());
  }

 Widget baseBodyWidget() {
    return  Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              countryDropDownWidget(),
              countryCodeTextWidget(),
              phoneTextInputWidget(),
              errorTextWidget(),
              SizedBox(
                height: 10,
              ),

            ],
          ),
        ),
        verifyOtpButtonWidget()
      ],
    );
  }

Widget verifyOtpButtonWidget() {
    return  Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.only(bottom: 30,left: 25,right: 25),
      child: RaisedButton(
        onPressed: () {
          verifyPhone();
        },
        child: Text('Login',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        textColor: Colors.white,
        color: Colors.blue,
        elevation: 0,
      ),
    );
}
}
