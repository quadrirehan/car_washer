import 'dart:convert';
import 'dart:ffi';

import 'package:car_washer/OrderDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'Users/LogIn.dart';
import 'Utils/DatabaseHelper.dart';
import 'Utils/UI.dart';

class AllOrders extends StatefulWidget {
  @override
  _AllOrdersState createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  String url;
  Menifo menifo;
  bool x1 = false;
  String washerId;
  String address = "";
  double lat;
  double lon;
  Future<List> futureGetOrders;
  Future<List> futureGetHistory;
  int delaySeconds = 0;

  @override
  void initState() {
    super.initState();
    menifo = Menifo();
    getWasherId();
  }

  Future<void> getWasherId() async {
    DatabaseHelper db = DatabaseHelper.instance;
    List washer = await db.getWasher();
    setState(() {
      washerId = washer[0]['washer_id'].toString();
    });
    if (washerId != null) {
      futureGetOrders = _getOrders();
      futureGetHistory = _getOrderHistory();
    }
  }

  Future<List> _getOrders() async {
    url = menifo.getBaseUrl() + "WasherOrders?washer_id=$washerId";

    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': "Application/json"});

    print("_getOrders: ::: : " + response.body.toString());

    return jsonDecode(response.body);
  }

  Future<List> _getOrderHistory() async {
    url = menifo.getBaseUrl() + "OrderHistory?washer_id=$washerId";
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': "Application/json"});

    print("_getOrderHistory: ::: : " + response.body.toString());

    return jsonDecode(response.body);
  }

  Future<void> _orderCompleted(String _orderId) async {
    url = menifo.getBaseUrl() +
        "OrderComplete?order_id=$_orderId&washer_id=$washerId";
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': "Application/json"});

    if (response.body.toString() == "Task Completed by Washer") {
      print(response.body.toString());
      setState(() {
        futureGetOrders = _getOrders();
        futureGetHistory = _getOrderHistory();
      });

      Fluttertoast.showToast(
        msg: "Order Completed Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Error While Completing Order",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
      );
    }
  }

  Future<void> _orderCancel(String _orderId) async {
    url = menifo.getBaseUrl() +
        "CancelOrder?order_id=$_orderId&washer_id=$washerId";
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': "Application/json"});

    if (response.body.toString() == "Order Canceled") {
      Fluttertoast.showToast(
        msg: "Order Cancelled Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
      );
      print(response.body.toString());
      setState(() {
        futureGetOrders = _getOrders();
        futureGetHistory = _getOrderHistory();
      });
    } else {
      Fluttertoast.showToast(
        msg: "Error While Cancelling Order",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
      );
    }
  }

  Future<void> refreshAll() async{
    setState(() {
      futureGetOrders = _getOrders();
      futureGetHistory = _getOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          centerTitle: true,
          title: Text("Order List"),
          actions: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  delaySeconds = 1;
                });
                refreshAllOrders();
                setState(() {
                  futureGetOrders = _getOrders();
                  futureGetHistory = _getOrderHistory();
                });
              },
              child: Icon(Icons.refresh, color: Colors.white),
            ),
            PopupMenuButton<String>(
              onSelected: _selected,
              itemBuilder: (BuildContext context) {
                return {'Logout'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          bottom: TabBar(labelPadding: EdgeInsets.all(8.0), tabs: [
            Text("Orders", style: TextStyle(fontSize: 18)),
            Text("History", style: TextStyle(fontSize: 18)),
          ]),
        ),
        body: delaySeconds == 0
            ? RefreshIndicator(
          onRefresh: refreshAll,
              child: TabBarView(
          dragStartBehavior: DragStartBehavior.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: FutureBuilder(
                      future: futureGetOrders,
                      builder: (context, snap) {
                        if (snap.hasData) {
                          if (snap.data.toString() == "[]") {
                            return Center(child: Text("No Data"));
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snap.data.length != 0
                                    ? snap.data.length
                                    : 0,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.only(top: 3),
                                    // height: 80,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderDetails(
                                                        snap.data[index]
                                                                ['user_name']
                                                            .toString(),
                                                        snap.data[index]
                                                                ['user_mobile']
                                                            .toString(),
                                                        snap.data[index]
                                                                ['order_id']
                                                            .toString())));
                                      },
                                      child: ListTile(
                                        isThreeLine: true,
                                        leading: Column(
                                          children: [
                                            SizedBox(height: 6),
                                            Text(
                                              "Time",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Text(snap.data[index]
                                                    ['appointment_time']
                                                .toString()),
                                          ],
                                        ),
                                        title: Text(snap.data[index]
                                                ['user_name']
                                            .toString(),  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                        subtitle: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(snap.data[index]
                                                    ['package_name']
                                                .toString()),
                                            // SizedBox(height: 1),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        _orderCancel(snap
                                                            .data[index]
                                                                ['order_id']
                                                            .toString());
                                                      },
                                                      child: Text("Cancel"),
                                                      color: Color.fromRGBO(191, 34, 34,0.9),
                                                      textColor: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Expanded(
                                                  child: InkWell(
                                                    child: RaisedButton(
                                                      onPressed: () {
                                                        _orderCompleted(snap
                                                            .data[index]['order_id']
                                                            .toString());
                                                      },
                                                      child: Text("Accept"),
                                                      color: Color.fromRGBO(24, 148, 45, 0.5), //Color.fromRGBO(24, 148, 45, 0.5)
                                                      textColor: Colors.white,
                                                      shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              8)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        // trailing: Row(
                                        //   children: [
                                        //     InkWell(
                                        //       child: Icon(Icons.done,
                                        //           color: Colors.green),
                                        //       onTap: () {
                                        //         _orderCompleted(snap.data[index]
                                        //                 ['order_id']
                                        //             .toString());
                                        //       },
                                        //     ),
                                        //     InkWell(
                                        //       child: Icon(Icons.clear,
                                        //           color: Colors.red),
                                        //       onTap: () {
                                        //         _orderCancel(snap.data[index]
                                        //                 ['order_id']
                                        //             .toString());
                                        //       },
                                        //     ),
                                        //   ],
                                        // ),
                                      ),
                                    ),
                                  );
                                });
                          }
                        } else if (snap.hasError) {
                          return Center(
                            child: Text("Try Again"),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: FutureBuilder(
                      future: futureGetHistory,
                      builder: (context, snap) {
                        print("GetOrderHistory Future Builder: ::: : " +
                            snap.data.toString());

                        if (snap.hasData) {
                          if (snap.data.toString() == "[]") {
                            return Center(child: Text("No Orders Completed"));
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snap.data.length != 0
                                    ? snap.data.length
                                    : 0,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderDetails(
                                                        snap.data[index]
                                                                ['user_name']
                                                            .toString(),
                                                        snap.data[index]
                                                                ['user_mobile']
                                                            .toString(),
                                                        snap.data[index]
                                                                ['order_id']
                                                            .toString())));
                                      },
                                      child: ListTile(
                                        leading: Column(
                                          children: [
                                            SizedBox(height: 6),
                                            Text(
                                              "Time",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Text(snap.data[index]
                                                ['appointment_time']),
                                          ],
                                        ),
                                        title: Text(snap.data[index]
                                                ['user_name']
                                            .toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                        subtitle: Text(snap.data[index]
                                                ['package_name']
                                            .toString()),
                                      ),
                                    ),
                                  );
                                });
                          }
                        } else if (snap.hasError) {
                          return Center(
                            child: Text("Try Again"),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ]),
            )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void getAddress(double lat, double lon) async {
    var addresses;
    var first;
    final coordinates = new Coordinates(lat, lon);
    addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    first = addresses.first;

    setState(() {
      address = first.addressLine.toString().replaceAll("'", "");
    });
    print("address" + address);
    // return Text(address);
  }

  void _selected(String value) {
    switch (value) {
      case 'Logout':
        DatabaseHelper db = DatabaseHelper.instance;
        db.deleteWasher().whenComplete(() => {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => LogIn()))
            });
        break;
    }
  }

  void refreshAllOrders() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        delaySeconds = 0;
      });
    });
  }
}
