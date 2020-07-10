#import "FirebaseRemoteModelPlugin.h"
#import "Firebase/Firebase.h"

@implementation FirebaseRemoteModelPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/firebase_remote_model"
            binaryMessenger:[registrar messenger]];
  FirebaseRemoteModelPlugin* instance = [[FirebaseRemoteModelPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method hasPrefix:@"registerRemoteModelSource"]) {
        if(call.arguments[@"source"] != [NSNull null] ){
            NSString *modeName = call.arguments[@"source"][@"modelName"];
            FIRModelDownloadConditions *initialDownloadConditions = [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES allowsBackgroundDownloading:YES];
            FIRModelDownloadConditions *updatesDownloadConditions = [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES allowsBackgroundDownloading:YES];
            if(call.arguments[@"source"][@"initialDownloadConditions"] != [NSNull null] ){
                BOOL requireWifi = call.arguments[@"source"][@"initialDownloadConditions"][@"requireWifi"];
                BOOL requireDeviceIdle = call.arguments[@"source"][@"initialDownloadConditions"][@"requireDeviceIdle"];
                initialDownloadConditions =
                [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:requireWifi
                                                     allowsBackgroundDownloading:requireDeviceIdle];
            }
            if(call.arguments[@"source"][@"updatesDownloadConditions"] != [NSNull null] ){
                BOOL requireWifi = call.arguments[@"source"][@"initialDownloadConditions"][@"requireWifi"];
                BOOL requireDeviceIdle = call.arguments[@"source"][@"initialDownloadConditions"][@"requireDeviceIdle"];
                initialDownloadConditions =
                updatesDownloadConditions =
                [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:requireWifi
                                                     allowsBackgroundDownloading:requireDeviceIdle];
            }
            FIRCustomRemoteModel *remoteModelSource =
            [[FIRCustomRemoteModel alloc] initWithName:modeName];
            [[FIRModelManager modelManager] downloadModel:remoteModelSource
                                               conditions:initialDownloadConditions];
        } else {
            result(nil);
        }
    } else if ([call.method hasPrefix:@"getLatestModelFile"]) {
           if(call.arguments[@"source"] != [NSNull null] ){
               NSString *modeName = call.arguments[@"source"][@"modelName"];
               FIRCustomRemoteModel *remoteModel =
               [[FIRCustomRemoteModel alloc] initWithName:modeName];
               [[FIRModelManager modelManager]
                getLatestModelFilePath:remoteModel
                            completion:^(NSString *_Nullable remoteModelPath, NSError *error) {
                 if (remoteModelPath != nil && error == nil) {
                     result(remoteModelPath);
                 } else {
                     result(nil);
                 }
               }];
           } else {
               result(nil);
           }
    }  else if ([call.method hasPrefix:@"isModelDownloaded"]) {
        if(call.arguments[@"source"] != [NSNull null] ){
            NSString *modeName = call.arguments[@"source"][@"modelName"];
            FIRCustomRemoteModel *remoteModelSource =
            [[FIRCustomRemoteModel alloc] initWithName:modeName];
            result([NSNumber numberWithBool:[[FIRModelManager modelManager] isModelDownloaded:remoteModelSource]]);
        } else {
            result(nil);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
