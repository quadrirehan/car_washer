import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'Utils/UI.dart';
import 'package:maps_launcher/maps_launcher.dart';

class OrderDetails extends StatefulWidget {
  String _customerName;
  String _customerMobile;
  String _orderId;

  OrderDetails(this._customerName, this._customerMobile, this._orderId);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String url;
  Menifo menifo;
  String address = "";
  var orderDetails;

  TextStyle _textStyle = TextStyle(fontWeight: FontWeight.bold);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    menifo = Menifo();
    getOrderDetails();
  }

  void getOrderDetails() async {
    url = menifo.getBaseUrl() + "OrdersDetails?order_id=${widget._orderId}";
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': "Application/json"});
    // print(response.body);
    orderDetails = await json.decode(response.body.toString());
    // print("Latitude: " + orderDetails[0]['customer_lat']);
    getAddress(orderDetails[0]['customer_lat'].toString(),
        orderDetails[0]['customer_long'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        centerTitle: true,
      ),
      body: orderDetails != null
          ? Padding(
              padding: const EdgeInsets.only(left: 15, top: 15, right: 8.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: Row(
                          children: [
                            Text(
                              "User Name",
                              style: _textStyle,
                            ),
                            Expanded(
                              child: Text(
                                ":",
                                textAlign: TextAlign.right,
                                style: _textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(widget._customerName))
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: Row(
                          children: [
                            Text(
                              "Mobile No.",
                              style: _textStyle,
                            ),
                            Expanded(
                              child: Text(
                                ":",
                                textAlign: TextAlign.right,
                                style: _textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(widget._customerMobile))
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: Row(
                          children: [
                            Text(
                              "Package",
                              style: _textStyle,
                            ),
                            Expanded(
                              child: Text(
                                ":",
                                textAlign: TextAlign.right, style: _textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child:  Text(
                        orderDetails[0]['package_id'].toString() == "1"
                            ? "Premium Wash"
                            : orderDetails[0]['package_id'].toString() == "2"
                            ? "Standard Wash"
                            : "Regular Wash",
                      ))
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: Row(
                          children: [
                            Text(
                              "Car Details",
                              style: _textStyle,
                            ),
                            Expanded(
                              child: Text(
                                ":",
                                textAlign: TextAlign.right,style: _textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(orderDetails[0]['customer_car'].toString()))
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: Row(
                          children: [
                            Text(
                              "Payment Mode",
                              style: _textStyle,
                            ),
                            Expanded(
                              child: Text(
                                ":",
                                textAlign: TextAlign.right, style: _textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(
                        orderDetails[0]['payment_type'].toString() == "1"
                            ? "Prepaid"
                            : "COD",
                      ),)
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: Row(
                          children: [
                            Text(
                              "Date & Time",
                              style: _textStyle,
                            ),
                            Expanded(
                              child: Text(
                                ":",
                                textAlign: TextAlign.right, style: _textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(orderDetails[0]['appointment_date'].toString() +
                          " " +
                          orderDetails[0]['appointment_time'].toString()))
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 110,
                        child: Row(
                          children: [
                            Text(
                              "Address",
                              style: _textStyle,
                            ),
                            Expanded(
                              child: Text(
                                ":",
                                textAlign: TextAlign.right, style: _textStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address,),
                          InkWell(
                              onTap: () {
                                MapsLauncher.launchCoordinates(
                                    double.parse(orderDetails[0]['customer_lat']),
                                    double.parse(orderDetails[0]['customer_long']));
                              },
                              child: Text(
                                "View On Map",
                                style: TextStyle(color: Colors.blue),
                              ))
                        ],
                      ))
                    ],
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  void getAddress(String lat, String lon) async {
    var addresses;
    var first;
    final coordinates = new Coordinates(double.parse(lat), double.parse(lon));
    addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    first = addresses.first;

    setState(() {
      address = first.addressLine.toString().replaceAll("'", "");
    });
    print("address: " + address);
    // return Text(address);
  }
}
