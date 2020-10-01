import 'package:car_washer/AllOrders.dart';
import 'package:car_washer/Utils/DatabaseHelper.dart';
import 'package:flutter/material.dart';

import 'Users/LogIn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DatabaseHelper db = DatabaseHelper.instance;
  int washerCount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3), () async {
      washerCount = await db.getCount();
      if (washerCount > 0 ){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllOrders()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LogIn()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(
              "CAR WASHER",
              style: TextStyle(
                  fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue),
            )),
    );
  }
}
