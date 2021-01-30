import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ai.dart';
import 'camera.dart';
import 'screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await loadModel();
  await loadCameras();

  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(new App());
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}
