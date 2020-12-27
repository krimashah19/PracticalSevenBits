import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ButtonWidget({this.text, this.onPressed,this.isLoading});


  @override
  Widget build(BuildContext context) {

    return  Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.only(bottom: 30,left: 25,right: 25),
      child: RaisedButton(
        onPressed: onPressed,
        child: Text(text,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        textColor: Colors.white,
        color: Colors.blue,
        elevation: 0,
      ),
    );

  }
}
