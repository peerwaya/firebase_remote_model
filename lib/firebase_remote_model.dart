// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

class FirebaseRemoteModelSource {
  final String modelName;
  final FirebaseModelDownloadConditions initialDownloadConditions;

  static const _defaultCondition = FirebaseModelDownloadConditions();

  FirebaseRemoteModelSource(
      {@required this.modelName,
        this.initialDownloadConditions: _defaultCondition});

  Map<String, dynamic> asDictionary() {
    return {
      "modelName": modelName,
      "initialDownloadConditions": initialDownloadConditions.asDictionary(),
    };
  }
}

// android
//   https://firebase.google.com/docs/reference/android/com/google/firebase/ml/custom/model/FirebaseModelDownloadConditions
class FirebaseModelDownloadConditions {
  final bool requireWifi;
  final bool requireDeviceIdle;
  final bool requireCharging;

  const FirebaseModelDownloadConditions({this.requireCharging: false,
    this.requireDeviceIdle: false,
    this.requireWifi: false});

  Map<String, dynamic> asDictionary() {
    return {
      "requireWifi": requireWifi,
      "requireDeviceIdle": requireDeviceIdle,
      "requireCharging": requireCharging
    };
  }
}

class FirebaseRemoteModel {
  static const MethodChannel _channel =
  const MethodChannel('plugins.flutter.io/firebase_remote_model');

  static Future<bool> isModelDownloaded(FirebaseRemoteModelSource remoteModelSource) async {
    final bool isDownloaded = await _channel.invokeMethod('isModelDownloaded');
    return isDownloaded;
  }

  static Future<String> registerRemoteModelSource(FirebaseRemoteModelSource remoteModelSource) async {
    try {
      await _channel.invokeMethod("registerRemoteModelSource",
          {'source': remoteModelSource.asDictionary()});
    } catch (e) {
      print(
          "Error on registerRemoteModelSource : ${e.toString()}");
    }
    return null;
  }

  static Future<String> getLatestModelFile(FirebaseRemoteModelSource remoteModelSource) async {
    try {
      await _channel.invokeMethod("getLatestModelFile",
          {'source': remoteModelSource.asDictionary()});
    } catch (e) {
      print(
          "Error on getLatestModelFile : ${e.toString()}");
    }
    return null;
  }
}
