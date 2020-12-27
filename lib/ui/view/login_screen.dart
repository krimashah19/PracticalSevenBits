import 'package:flutter/material.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:krima_practical/util/country_list.dart';
import 'package:toast/toast.dart';
import 'otp_screen.dart';
import 'package:krima_practical/ui/component/button_widget.dart';
import 'package:krima_practical/util/share_pref.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNo;
  String smsOTP;
  String verificationId;
  bool _loading = true;
  String errorMessage = '';
  CountryCode _selectedCountry;
  final mobileController=TextEditingController();
  GlobalKey<FormState> _loginFormKey;


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
      Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => OtpScreen(mobileNumber: mobileController.text,),
      )).then((value) => mobileController.clear());

      // Navigator.of(context).pushReplacementNamed('/otpscreen');
      // smsOTPDialog(context).then((value) {
      //   print('sign in');
      // });
    };
    print('phone number--->${phoneNo}');
    UserPreferences().saveMobileNumber(phoneNo);

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
            _loading=false;
          },
          verificationFailed: (Exception exceptio) {
            Toast.show(exceptio.toString(), context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            print('${exceptio.toString()}');
          });
    } catch (e) {
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
    _loginFormKey = new GlobalKey<FormState>();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
    mobileController.text=_selectedCountry!=null?_selectedCountry.dialCode:"+91";
  }

  Widget countryDropDownWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Container(
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
    return Form(
      key: _loginFormKey,
      child: Padding(
        padding: EdgeInsets.all(30),
        child: TextFormField(
          validator: (input) => input.length == 3||  input.length == 4
              ? 'Please Enter Mobile Number'
              : null,
          controller: mobileController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
              hintText: 'Enter Mobile Number +911111111111'),
          onChanged: (value) {
            this.phoneNo = value;
          },
        ),
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
        ButtonWidget(onPressed:(){
          if(_loginFormKey.currentState.validate())
          {

            verifyPhone();

          }
        },text: 'Login',)
      ],
    );
  }


}
