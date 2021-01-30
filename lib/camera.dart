import 'dart:async';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'ai.dart';

List<CameraDescription> cameras;
CameraController controller;
bool processando = false;
double scorePerson = 0.5;
double scoreKeypoint = 0.7;

Future loadCameras() async {
  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
}

Future initCamera() async {
  controller = CameraController(cameras[0], ResolutionPreset.high);
  await controller.initialize();
}

Future<bool> takePictureAndProcess() async {
  bool newPicture = false;

  if (processando) return newPicture;
  processando = true;

  String filePath = await takePicture();

  if (filePath != null) {
    double score = await processFile(filePath, scorePerson, scoreKeypoint);

    if (score > 0) {
      GallerySaver.saveImage(filePath).then((bool success) {});
      newPicture = true;
    }
  }

  processando = false;
  return newPicture;
}

Future<String> takePicture() async {
  if (!controller.value.isInitialized) {
    return null;
  }

  try {
    print('Taking a picture');
    XFile file = await controller.takePicture();
    return file.path;
  } on CameraException catch (e) {
    print(e);
    return null;
  }
}

void disposeCamera() {
  controller?.dispose();
}
