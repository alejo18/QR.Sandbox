import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Sandbox',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'QR Sandbox'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final contentController = TextEditingController();

  String _QRcode_Reader = "";

  void _generateQRcode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Generated QR"),
          // https://pub.dartlang.org/packages/qr_flutter
          // https://www.qrcode.com/en/about/version.html
          content: new QrImage(
              data: contentController.text,
              size: 200.0,
              version: 2
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'content';
    final value = prefs.getString(key) ?? 0;
    print('read: $value');
  }

  _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'content';
    final value = {"userName": 'name', "value": '321'};
    prefs.setString(key, jsonEncode(value));
    print('saved $value');
  }

  Future _scanQR() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this._QRcode_Reader = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this._QRcode_Reader = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this._QRcode_Reader = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this._QRcode_Reader = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this._QRcode_Reader = 'Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: <Widget>[
            Text(
                'QR generator',
              style: Theme.of(context).textTheme.headline,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: (
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                        labelText: 'Enter the content for the QR',
                        hintText: 'Please enter something'
                    ),
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: (
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    textColor: Colors.white,
                    onPressed: _generateQRcode,
                    child: const Text('Generate QR'),
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: (
                  Text(
                    '$_QRcode_Reader',
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text('Read Information'),
                onPressed: () {
                  _read();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text('Save Information'),
                onPressed: () {
                  _save();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQR,
        tooltip: 'Scan QR',
        child: Icon(Icons.photo_camera),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
