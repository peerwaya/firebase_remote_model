package com.peerwaya.firebase_remote_model;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.custom.FirebaseCustomRemoteModel;

import java.io.File;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebaseRemoteModelPlugin */
public class FirebaseRemoteModelPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/firebase_remote_model");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_remote_model");
    channel.setMethodCallHandler(new FirebaseRemoteModelPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, final @NonNull Result result) {
    if (call.method.equals("registerRemoteModelSource")) {
      FirebaseModelManager manager = FirebaseModelManager.getInstance();

      if (call.argument("source") != null) {
        Map<String, Object> sourceMap = call.argument("source");
        String modelName = (String)sourceMap.get("modelName");
        FirebaseCustomRemoteModel remoteModel =
                new FirebaseCustomRemoteModel.Builder(modelName).build();

        FirebaseModelDownloadConditions.Builder conditionsBuilder = new FirebaseModelDownloadConditions.Builder();
        if (sourceMap.get("initialDownloadConditions") != null) {
          Map<String, Boolean> conditionMap = (Map<String, Boolean>) sourceMap
                  .get("initialDownloadConditions");
          if (conditionMap.get("requireWifi")) {
            conditionsBuilder = conditionsBuilder.requireWifi();
          }
          if (conditionMap.get("requireDeviceIdle")) {
            conditionsBuilder.requireDeviceIdle();
          }
          if (conditionMap.get("requireCharging")) {
            conditionsBuilder.requireCharging();
          }
        }
        manager.download(remoteModel, conditionsBuilder.build());
      }
    } else if (call.method.equals("getLatestModelFile")) {
      FirebaseModelManager manager = FirebaseModelManager.getInstance();

      if (call.argument("source") != null) {
        Map<String, Object> sourceMap = call.argument("source");
        String modelName = (String)sourceMap.get("modelName");
        FirebaseCustomRemoteModel remoteModel = new FirebaseCustomRemoteModel.Builder(modelName).build();
        FirebaseModelManager.getInstance().getLatestModelFile(remoteModel)
                .addOnCompleteListener(new OnCompleteListener<File>() {
                  @Override
                  public void onComplete(@NonNull Task<File> task) {
                    File modelFile = task.getResult();
                    if (modelFile != null) {
                      result.success(modelFile.getAbsolutePath());
                    } else {
                      result.success(null);
                    }
                  }
                });
      }

    } else if (call.method.equals("sModelDownloaded")) {
      FirebaseModelManager manager = FirebaseModelManager.getInstance();

      if (call.argument("source") != null) {
        Map<String, Object> sourceMap = call.argument("source");
        String modelName = (String)sourceMap.get("modelName");
        FirebaseCustomRemoteModel remoteModel = new FirebaseCustomRemoteModel.Builder(modelName).build();
        manager.isModelDownloaded(remoteModel).addOnCompleteListener(new OnCompleteListener<Boolean>() {
          @Override
          public void onComplete(@NonNull Task<Boolean> task) {
            Boolean isCompleted = task.getResult();
            if (isCompleted != null) {
              result.success(isCompleted);
            } else {
              result.success(null);
            }
          }
        });
      }

    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
