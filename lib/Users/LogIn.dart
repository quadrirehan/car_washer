import 'dart:convert';

import 'package:car_washer/AllOrders.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../Utils/DatabaseHelper.dart';
import '../Utils/UI.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  Menifo menifo = Menifo();
  String url;
  final _formKey = GlobalKey<FormState>();
  bool isLogin = false;

  Color colour = Colors.blue;
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();

  Future<void> _loginWasher() async {
    setState(() {
      isLogin = true;
    });
    url = menifo.getBaseUrl() +
        "WasherLogin?washer_email=${_email.text}&washer_password=${_pass.text}";
    print(url);
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': "application/json"});

    if(response.statusCode == 200){
      if (response.body == "x1") {
        setState(() {
          isLogin = false;
        });
        return Fluttertoast.showToast(
            msg: "Invalid Email and Password...",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
      else {
        DatabaseHelper db = DatabaseHelper.instance;
        db
            .insertWasher(
          jsonDecode(response.body)[0]['washer_id'].toString(),
          jsonDecode(response.body)[0]['washer_name'].toString(),
          jsonDecode(response.body)[0]['washer_mobile'].toString(),
          jsonDecode(response.body)[0]['washer_email'].toString(),
          jsonDecode(response.body)[0]['washer_password'].toString(),
          jsonDecode(response.body)[0]['washer_address'].toString(),
        )
            .whenComplete(() => {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AllOrders()))
        });

        return Fluttertoast.showToast(
            msg: "LogIn Successfully...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
//        timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }else{
      setState(() {
        isLogin = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text(
                "Login",
                style: TextStyle(
                    color: colour, fontWeight: FontWeight.bold, fontSize: 25),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              Text("YOUR EMAIL :",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 16)),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Container(
                padding: EdgeInsets.only(top: 4, left: 8),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(40)),
                height: 50,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: "Enter Your Email Here",
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              Text("PASSWORD :",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 16)),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Container(
                height: 50,
                padding: EdgeInsets.only(top: 4, left: 8),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(40)),
                child: TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      hintText: "**********",
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  onPressed: isLogin == false
                      ? () {
                          if (_email.text.isNotEmpty &&
                              _pass.text.isNotEmpty) {
                            _loginWasher();
                          } else {
                            Fluttertoast.showToast(
                              msg: "Enter Email and Password",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_LONG,
                              textColor: Colors.white,
                              backgroundColor: Colors.grey[600],
                              fontSize: 16.0,
                            );
                          }
                        }
                      : null,
                  color: colour,
                  child: isLogin == true
                      ? Center(child: CircularProgressIndicator())
                      : Text("LogIn"),
                  textColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("can't login? "),
                  Text("Forgot password?",
                      textAlign: TextAlign.center,
                      //Text Underline
                      style: TextStyle(
                          color: colour,
                          decoration: TextDecoration.underline)),
                ],
              ),
              // SizedBox(height: 180),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Text("Don't have an account? "),
              //     InkWell(
              //       onTap: navigateToSignUp,
              //       child: Text(
              //         "Sign Up",
              //         style: TextStyle(
              //             color: colour,
              //             decoration: TextDecoration.underline),
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
