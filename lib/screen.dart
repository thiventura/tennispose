import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'camera.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controllerScorePerson = TextEditingController();
  final controllerScoreKeypoint = TextEditingController();
  Timer _timer;
  bool takingPictures = false;
  int numPictures = 0;

  @override
  void initState() {
    super.initState();

    numPictures = 0;
    controllerScorePerson.text = "0.5";
    controllerScoreKeypoint.text = "0.7";

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);

    initCamera().then((_) {
      setState(() {
        takingPictures = false;
      });
    });
  }

  @override
  Future<void> dispose() async {
    _timer.cancel();
    disposeCamera();
    controllerScorePerson.dispose();
    controllerScoreKeypoint.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tennis pose detection'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: takingPictures
                      ? _cameraPreviewWidget()
                      : const Text(
                          'Set minimum score for person and pose detection'),
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading camera...',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(controller);
    }
  }

  /// Display the control bar with buttons to take pictures.
  Widget _captureControlRowWidget() {
    final size = 100.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: !takingPictures
          ? <Widget>[
              const Text('Minimum person score: '),
              Container(
                width: 100,
                child: TextField(
                  controller: controllerScorePerson,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
              const Text('Minimum pose score: '),
              Container(
                width: 100,
                child: TextField(
                  controller: controllerScoreKeypoint,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                  height: size,
                  width: size,
                  child: new IconButton(
                    padding: new EdgeInsets.all(0.0),
                    color: Colors.red,
                    icon: new Icon(Icons.camera_alt, size: size),
                    onPressed:
                        controller != null && controller.value.isInitialized
                            ? onTakePictureButtonPressed
                            : null,
                  ))
            ]
          : <Widget>[
              Container(
                  width: 100,
                  child: Text("Pictures: " + numPictures.toString())),
              SizedBox(
                  height: size,
                  width: size,
                  child: new IconButton(
                    padding: new EdgeInsets.all(0.0),
                    color: Colors.black,
                    icon: new Icon(Icons.camera_alt, size: size),
                    onPressed: onStopPictureButtonPressed,
                  ))
            ],
    );
  }

  void onTakePictureButtonPressed() {
    scorePerson = double.parse(controllerScorePerson.text);
    scoreKeypoint = double.parse(controllerScoreKeypoint.text);

    setState(() {
      numPictures = 0;
      takingPictures = true;
    });

    // Inicia o timer para tirar fotos e processá-las
    _timer = new Timer.periodic(
      Duration(seconds: 1),
      (Timer times) async {
        if (await takePictureAndProcess()) {
          setState(() {
            numPictures++;
          });
        }
      },
    );
  }

  void onStopPictureButtonPressed() {
    _timer.cancel();
    setState(() {
      takingPictures = false;
    });
  }
}
