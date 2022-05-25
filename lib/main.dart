import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyperkyc_flutter/hyperkyc_config.dart';
import 'package:hyperkyc_flutter/hyperkyc_flutter.dart';
import 'package:hyperkyc_flutter/hyperkyc_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'KYC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String? error;
  String? status;
  String? reason;
  String? imagePath;
  String? action;
  String? country;

  Future<bool> runKyc() async {
    var workFlow = [
      /*{
        'type': 'document'
      },*/
      {
        'type': 'face',
      },
    ];

    var hyperKycConfig = HyperKycConfig.fromAppIdAppKey(
      appId: "a",
      appKey: "b",
      transactionId: "c",
      workFlow: workFlow,
    );
    final prefs = await SharedPreferences.getInstance();
    try {
      HyperKycResult hyperKycResult = await HyperKyc.launch(
          hyperKycConfig: hyperKycConfig);
      final result = hyperKycResult;

      prefs.setString("status", result.status?.name ?? '' );
      prefs.setString("reason", result.reason ?? '' );
      prefs.setString("country", result.hyperKYCData?.selectedCountry ?? '');
      prefs.setString("image_path", result.hyperKYCData?.faceData?.fullFaceImagePath ?? '');
      prefs.setString("action", result.hyperKYCData?.faceData?.action ?? '');
      return true;
    }catch (error){
      this.error = error.toString();
      prefs.setString("error", error.toString());
      return false;
    }
  }

  void buttonTapped(BuildContext context) async {
    bool result = await runKyc();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Scan Success: ${result}"),
    ));
  }

  void initData() async{
    final prefs = await SharedPreferences.getInstance();

    status = prefs.getString("status");
    reason = prefs.getString("reason");
    imagePath = prefs.getString("image_path");
    action = prefs.getString("action");
    error = prefs.getString("error");
    country = prefs.getString("country");
  }

  @override
  Widget build(BuildContext context) {

    initData();
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !(status?.isEmpty ?? true) ? Text(
              'status: ${status ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ) : const SizedBox.shrink(),
            !(reason?.isEmpty ?? true) ? Text(
              'reason: ${reason ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ) : const SizedBox.shrink(),
            !(country?.isEmpty ?? true) ? Text(
              'selected country: ${country}',
              style: Theme.of(context).textTheme.bodySmall,
            ) : const SizedBox.shrink(),
            !(action?.isEmpty ?? true) ? Text(
              'action: ${action}',
              style: Theme.of(context).textTheme.bodySmall,
            ) : const SizedBox.shrink(),
            !(imagePath?.isEmpty ?? true) ? Image.file(File(imagePath!)) : SizedBox.shrink(),
            !(error?.isEmpty ?? true) ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(error ?? '')
              ),
            ) : const SizedBox.shrink(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){buttonTapped(context);},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
