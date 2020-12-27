import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:timer_button/timer_button.dart';
import 'package:toast/toast.dart';
import 'package:krima_practical/ui/component/button_widget.dart';

class OtpScreen extends StatefulWidget {

  final String mobileNumber;

  const OtpScreen({Key key, this.mobileNumber}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String smsOTP;
  String errorMessage = '';
  String verificationId;
  final otpController=TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Otp Screen'),

        ),
        body: baseBodyWidget());
  }

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      // Navigator.of(context).pushReplacementNamed('/otpscreen');
      // smsOTPDialog(context).then((value) {
      //   print('sign in');
      // });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber:widget.mobileNumber,
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

  baseBodyWidget() {
    return Container(
        margin: EdgeInsets.only(left: 25, right: 25, top: 25),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  otpTextInputWidget(),
                  errorTextWidget(),
                  SizedBox(height:20),
                  resendButtonWidget()
                ],
              ),
            ),
            ButtonWidget( onPressed: () {
              if(smsOTP!=null && smsOTP.length>0)
              {
                Navigator.of(context).pushNamed('/profilescreen');
              }
              else{
                Toast.show("Please Enter Otp ", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
              }
            },text: 'Next',)
          ],
        ));
  }

  Widget otpTextInputWidget() {
    return
      OTPTextField(
        length: 6,
        width: MediaQuery.of(context).size.width,
        textFieldAlignment: MainAxisAlignment.spaceBetween,
        fieldWidth: 45,
        fieldStyle: FieldStyle.underline,
        style: TextStyle(
            fontSize: 18
        ),
        onCompleted: (pin) {
          smsOTP=pin;
          print("Completed: " + pin);
        },
      );
    //   TextField(
    //   controller: otpController,
    //   keyboardType: TextInputType.number,
    //   maxLength: 6,
    //   onChanged: (value) {
    //     this.smsOTP = value;
    //   },
    // );
  }

  Widget errorTextWidget() {
    return (errorMessage != ''
        ? Text(
            errorMessage,
            style: TextStyle(color: Colors.red),
          )
        : Container());
  }

 Widget resendButtonWidget() {
    return TimerButton(
      label: "Resend Otp",
      timeOutInSeconds: 60,
      onPressed: () {
     verifyPhone();
      },
      disabledColor: Colors.red,
      buttonType: ButtonType.RaisedButton,
      color: Colors.blue,
      disabledTextStyle:
      new TextStyle(fontSize: 20.0, color: Colors.white24),
      activeTextStyle:
      new TextStyle(fontSize: 20.0, color: Colors.white),
    );
  }

}


