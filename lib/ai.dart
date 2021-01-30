import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';

Future loadModel() async {
  try {
    String res = await Tflite.loadModel(
      model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
    );
    print(res);
  } on PlatformException {
    print('Failed to load model.');
  }
}

// Run posenet, get the keypoints, check for tennis poses
// Return person score if some movement was detected, or -1 otherwise
Future<double> processFile(String filePath, double scorePerson, double scoreKeypoint) async {
  var recognitions;

  try {
    // Getting keypoints from Posenet
    recognitions = await Tflite.runPoseNetOnImage(
      path: filePath,
      numResults: 1,
    );
  } catch (e) {
    return -1;
  }

  if (recognitions.length == 0) return -1;

  var recognition = recognitions[0];
  if (checkMovement(recognition["score"], recognition["keypoints"], scorePerson,
      scoreKeypoint)) {
    return recognition["score"];
  } else {
    return -1;
  }
}

// A lot of people think AI is just a lot of IFs.
// Please, do not show this code for these people.
bool checkMovement(double score, Map keypoints, double scorePerson, double scoreKeypoint) {
  Map leftShoulder = keypoints[5];
  Map rightShoulder = keypoints[6];
  Map leftElbow = keypoints[7];
  Map rightElbow = keypoints[8];
  Map leftWrist = keypoints[9];
  Map rightWrist = keypoints[10];
  Map leftHip = keypoints[11];
  Map rightHip = keypoints[12];

  print("Score $score");

  if (score < scorePerson) return false;

  if (isForehand(rightWrist, rightHip, rightShoulder, scoreKeypoint))
    return true;

  if (isBackhand(rightWrist, leftWrist, leftHip, leftShoulder, scoreKeypoint))
    return true;

  if (isServe(rightWrist, leftWrist, rightElbow, leftElbow, rightShoulder,
      leftShoulder, scoreKeypoint)) return true;

  return false;
}

bool isForehand(Map rightWrist, Map rightHip, Map rightShoulder, double scoreKeypoint) {
  if (rightWrist['score'] < scoreKeypoint) return false;
  if (rightHip['score'] < scoreKeypoint) return false;
  if (rightShoulder['score'] < scoreKeypoint) return false;

  if (rightWrist['y'] < rightHip['y'] && rightWrist['x'] < rightShoulder['x']) {
    print('forehand');
    return true;
  }
  return false;
}

bool isBackhand(Map rightWrist, Map leftWrist, Map leftHip, Map leftShoulder,
    double scoreKeypoint) {
  if (rightWrist['score'] < scoreKeypoint) return false;
  if (leftWrist['score'] < scoreKeypoint) return false;
  if (leftHip['score'] < scoreKeypoint) return false;
  if (leftShoulder['score'] < scoreKeypoint) return false;

  if (rightWrist['y'] < leftHip['y'] &&
      rightWrist['x'] > leftShoulder['x'] &&
      leftWrist['x'] > leftShoulder['x']) {
    print('backhand');
    return true;
  }
  return false;
}

bool isServe(Map rightWrist, Map leftWrist, Map rightElbow, Map leftElbow,
    Map rightShoulder, Map leftShoulder, double scoreKeypoint) {
  if (rightWrist['score'] < scoreKeypoint) return false;
  if (leftWrist['score'] < scoreKeypoint) return false;
  if (rightElbow['score'] < scoreKeypoint) return false;
  if (leftElbow['score'] < scoreKeypoint) return false;
  if (rightShoulder['score'] < scoreKeypoint) return false;
  if (leftShoulder['score'] < scoreKeypoint) return false;

  if (rightElbow['y'] > rightWrist['y'] &&
      rightElbow['y'] > rightShoulder['y'] &&
      leftElbow['y'] < leftShoulder['y'] &&
      leftWrist['y'] < leftShoulder['y']) {
    print('serve');
    return true;
  }
  return false;
}
