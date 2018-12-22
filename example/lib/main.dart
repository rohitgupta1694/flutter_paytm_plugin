import 'dart:async';
import 'dart:convert' as json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_paytm_plugin/flutter_paytm_plugin.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterPaytmPlugin _flutterPaytmPlugin;
  int state = 0;
  String errorMessage = "", orderId = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _flutterPaytmPlugin = FlutterPaytmPlugin(
      buildVariant: BuildVariant.debug,
    );

    _flutterPaytmPlugin.onTransactionResponseChanged
        .listen((PaytmTransactionResponse paytmTransactionResponse) {
      if (paytmTransactionResponse != null &&
          paytmTransactionResponse.paytmStatus.contains("TXN_SUCCESS")) {
        orderId = paytmTransactionResponse.paytmOrderId;
        setState(() {
          state = 4;
        });
      } else {
        errorMessage = "Paytm response is null";
        setState(() {
          state = 5;
        });
        print(errorMessage);
      }
    });

    _flutterPaytmPlugin.onErrorOccured.listen((dynamic exception) {
      if (exception.runtimeType == PlatformException) {
        errorMessage = exception != null
            ? "Platform Exception with code: ${exception.code} & message: ${exception.message}"
            : "Paytm response is null";
      } else {
        errorMessage = exception.toString();
      }
      setState(() {
        state = 5;
      });
      print(errorMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Paytm Plugin Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 16.0,
              ),
              RaisedButton(
                child: const Text(
                  "Pay with Paytm",
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: _getDummyChecksumHashFromServer,
              ),
              SizedBox(
                height: 16.0,
              ),
              getWidget(state),
            ],
          ),
        ),
      ),
    );
  }

  void _getDummyChecksumHashFromServer() async {
    setState(() {
      state = 1;
    });
    Map<String, String> header = {HttpHeaders.acceptHeader: 'application/json'};
    //TODO: Always change API before git push
    final dummyChecksumHashURL = 'https://12f5cba7.ngrok.io/api/v4/testing/csm';
    try {
      await http.get(dummyChecksumHashURL, headers: header).then((response) {
        if (response.statusCode == HttpStatus.ok) {
          setState(() {
            state = 3;
          });
          final parsedChecksumRequestObject = json.jsonDecode(response.body);
          print("Checksum Hash Object: $parsedChecksumRequestObject");

          Map<String, String> checksumRequestObjectMap = {
            "MID": parsedChecksumRequestObject["MID"],
            "ORDER_ID": parsedChecksumRequestObject["ORDER_ID"],
            "CUST_ID": parsedChecksumRequestObject["CUST_ID"],
            "INDUSTRY_TYPE_ID": parsedChecksumRequestObject["INDUSTRY_TYPE_ID"],
            "CHANNEL_ID": parsedChecksumRequestObject["CHANNEL_ID"],
            "TXN_AMOUNT": parsedChecksumRequestObject["TXN_AMOUNT"],
            "WEBSITE": parsedChecksumRequestObject["WEBSITE"],
            "CALLBACK_URL": parsedChecksumRequestObject["CALLBACK_URL"],
            "CHECKSUMHASH": parsedChecksumRequestObject["CHECKSUMHASH"]
          };

//          if(parsedChecksumRequestObject["EMAIL"] != null || parsedChecksumRequestObject["MOBILE_NO"] != null) {
//            checksumRequestObjectMap.addAll({
//              "EMAIL": parsedChecksumRequestObject["EMAIL"],
//              "MOBILE_NO": parsedChecksumRequestObject["MOBILE_NO"]
//            });
//          }

          _flutterPaytmPlugin.startPaytmTransaction(checksumRequestObjectMap);
        } else {
          errorMessage =
              "API ERROR CODE: ${response.statusCode} with ERROR MESSGAE: ${response.body}";
          setState(() {
            state = 2;
          });
          print(errorMessage);
        }
      }).timeout(Duration(seconds: 30), onTimeout: () {
        errorMessage = "API ERROR: Timeout Error";
        setState(() {
          state = 2;
        });
        print(errorMessage);
      });
    } catch (error) {
      errorMessage = "Unexpected Error: $error";
      setState(() {
        state = 2;
      });
      print(errorMessage);
    }
  }

  getWidget(int state) {
    switch (state) {
      case 0:
        return Container();
      case 1:
        return CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        );
      case 2:
        return Text(
          errorMessage,
          style: TextStyle(
            color: Color(0xff333333),
            fontSize: 16,
          ),
        );
      case 3:
        return Text(
          "Redirecting to Paytm Gateway...",
          style: TextStyle(
              color: Color(0xff333333),
              fontSize: 20,
              fontStyle: FontStyle.italic),
        );
      case 4:
        return FittedBox(
          child: Row(
            children: <Widget>[
              Text(
                "Payment Successful:",
                style: TextStyle(
                    color: Color(0xff333333),
                    fontSize: 18,
                    fontStyle: FontStyle.italic),
              ),
              Text(
                "Order Id: $orderId",
                style: TextStyle(
                  color: Color(0xff333333),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      case 5:
        return Text(
          "Payment Failed: $errorMessage",
          style: TextStyle(
            color: Color(0xff333333),
            fontSize: 16,
          ),
        );
    }
  }
}
