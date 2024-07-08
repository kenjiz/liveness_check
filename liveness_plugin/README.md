# Liveness Detection flutter SDK

A liveness detection Flutter plugin for iOS and Android.
(Android latest, iOS V3.1.2)

### <font color='#0FA80B'>Demo</font>

#### Android
Install [CV-Demo.apk](https://prod-guardian-cv.oss-ap-southeast-5.aliyuncs.com/app/Guardian.apk) on your phone and log in with the test account.

### <font color='#0FA80B'>Integrate the SDK into your project</font>

**Click to [download](https://prod-guardian-cv.oss-ap-southeast-5.aliyuncs.com/sdk/Liveness-Detection(Flutter).zip) SDK**

#### Android

1. Copy `liveness_plugin` to the root directory of the project or the existing `plugins` folder in the project.

2. Open the `pubspec.yaml` file in the root directory and add a reference to the liveness_plugin plugin under the dependencies node：
    
    ```yaml
    dependencies:
        ...
        liveness_plugin:
            path: plugins/liveness_plugin
    ```

#### iOS
1. Add camera and motion sensor (gyroscope) usage description in `Info.plist` as bellow. Ignore this step if you have added those.

   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Use the camera to detect the face movements</string>
   <key>NSMotionUsageDescription</key>
   <string>Use the motion sensor to get the phone orientation</string>
   ```
2. Open the `pubspec.yaml` file in the root directory and add a reference to the liveness_plugin plugin under the dependencies node:
   
    ```yaml
    dependencies:
        liveness_plugin:
            path: /path/to/liveness_plugin
    ```
3. Open your `Podfile` and specify the SDK name and url:

    ```ruby
    target 'Runner' do
      flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

      # Specify 'AAINetwork' and 'AAILiveness'
      pod 'AAINetwork', :http => 'https://prod-guardian-cv.oss-ap-southeast-5.aliyuncs.com/sdk/iOS-libraries/AAINetwork/AAINetwork-V1.0.2.tar.bz2', type: :tbz
      pod 'AAILiveness', :http => 'https://prod-guardian-cv.oss-ap-southeast-5.aliyuncs.com/sdk/iOS-liveness-detection/3.1.2/iOS-Liveness-SDK-V3.1.2.tar.bz2', type: :tbz

    end
    ```
### <font color='#0FA80B'>Quick Start</font>

1. Declare the plugin.
    ```dart
    import 'package:liveness_plugin/liveness_plugin.dart';
    ```
2. Initialize the SDK.
    ```dart
    LivenessPlugin.initSDKOfLicense(your Market);
    ```
    > The last parameter must match the category of the country to which your account belongs, otherwise you will not be authorized.

3. Set license (call openAPI to obtain license by your server)
    ```dart
    void _checkLicense() async {
        /*
        // Optional
        // Set SDK detection level, default is NORMAL.
        // Available levels are EASY, NORMAL, HARD
        // Note that this method must be call before "setLicenseAndCheck()", otherwise it won't take effact
        LivenessPlugin.setDetectionLevel(DetectionLevel.EASY)
        */

        String license = "";
        String result = await LivenessPlugin.setLicenseAndCheck(license);
        print(result);
        if ("SUCCESS" == result) {// license is valid
            startLivenessDetection();
        } else {
            // license is invalid, expired/format error /appId is invalid
        }
    }
    ```
4. Customize the number and sequence of actions.
    ```dart
    // Example: Perform mouth opening and blinking in random order
    LivenessPlugin.setActionSequence(true, [DetectionType.MOUTH,DetectionType.BLINK])

    // Enable face occlusion detection(only in the preparation phase, not in the action detection phase), this feature is off by default.
    LivenessPlugin.setDetectOcclusion(true);

    /*
    // Set action detection time interval, all actions take effect after setting, unit: Millisecond. Default is 10s.
    LivenessPlugin.setActionTimeoutMills(10000);
    */
    ```
5. Get the SDK version number.
    ```dart
    LivenessPlugin.getSDKVersion.then((sdkVersion) {
        print(sdkVersion);
    });
    ```
6. Start the liveness detection test and obtain the test result.
    > Each time the liveness detection is successful, a unique livenessId and a clear photo of 600*600 pixels for this test will be returned.
    
    * You need to give the livenessId to your server, and the server will call openAPI to get the score of this test.
    * You can get the image directly through the methods provided by the SDK, or you can call the openAPI from the server.
        ```dart
        // Sample code
        class _SomePageState extends State<SomePage> implements LivenessDetectionCallback{

            ...

            void startLivenessDetection() {
                LivenessPlugin.startLivenessDetection(this);
            }

            @override
            void onGetDetectionResult(bool isSuccess, Map resultMap) {
                print(resultMap);
            }   
        }
        ```
7. Read the latest results at anytime after the completion of the Liveness Detection(This feature is only supported on Android).
    > You can get the result in the callback after the Liveness Detection is completed (step 5), or you can get it at any time through the following methods.

    ```dart
    LivenessPlugin.getLatestDetectionResult.then((latestDetectionResult) {
        print(latestDetectionResult);
    });
    ```
8. User binding (strongly recommended).
    > You can use this method to pass your user unique identifier to us, we will establish a mapping relationship based on the identifier。It is helpful for us to check the log when encountering problems.

    ```dart
    LivenessPlugin.bindUser("your user id");
    ```
9. The code of the `liveness` module(for android) and the code of `ios/Classes`(for iOS) can be modified to meet the customization needs.
    > Currently SDK supports six languages/voice: Chinese, English, Indonesian, Vietnamese,Hendi,Thai. Automatically switch according to the current language of the mobile phone, no code setting is required. If you only support one language, you can delete the resource files of other countries, for iOS side, you also need to modify the method `currLanForBundle:` to return a specific language.

---
### <font color='#FF0000'>Android Error Code:</font>

| Code | Explanation | Solution |
| ------ | ------ | ------ |
| FACE\_MISSING | Face loss during detection process | / |
| ACTION\_TIMEOUT | Action timeout | / |
| MULTIPLE\_FACE | Multiple faces detected | / |
| MUCH\_MOTION | Excessive movement range during detection | / |
| AUTH\_BAD\_NETWORK | Authorization failed when requested the network | Try again after using VPN |
| CHECKING\_BAD\_NETWORK | The image uploading network request failed after the motion ended | Try again after using VPN |
| DEVICE\_NOT\_SUPPORT | The device does not support liveness detection | The device has no front camera or is unavailable |
| USER\_GIVE\_UP | The user interrupted the Liveness detection | / |
| UNDEFINED | Other undefined errors | / |
|NO_RESPONSE|Request network failed |Check your network status.|
| AUTH\_PARAMETER\_ERROR | Authorization request parameter error | Please check whether the key passed to the initialization method is SDK’s or not, and make sure that the Market matches. |
| AUTH\_IAM\_FAILED | Package name not registered | Self-configuration on SaaS (Personal Management -> ApplicationId Management) or contact us to add |

---
### <font color='#FF0000'>iOS Error Code:</font>

| Code | Explanation |
| ------ | ------ |
| FAIL\_REASON\_FACEMISS\_BLINK\_MOUTH | Face loss during detection process |
| FAIL\_REASON\_FACEMISS\_POS\_YAW | Face loss during detection process |
| FAIL\_REASON\_MUTI\_FACE | Multiple faces detected |
| FAIL\_REASON\_MUCH\_ACTION | Excessive movement range during detection |
| FAIL\_REASON\_TIMEOUT | Action timeout |
| FAIL\_REASON\_PREPARE\_TIMEOUT | Preparation timeout |
| NETWORK_REQUEST_FAILED | Network request failed |
| DEVICE\_NOT\_SUPPORT | The device has no front camera or is unavailable |

### <font color='#0FA80B'>FAQ</font>

1. **How to make liveness_plugin to support null-safe?**

    First, we need to modify the flutter sdk version of file "liveness_plugin/pubspec.yaml":
    ```
    sdk: ">=2.1.0 <3.0.0"  ==>  sdk: ">=2.12.0 <3.0.0"
    ```
    Then replace the content of file "liveness_plugin/lib/liveness_plugin.dart" with follow content:

    ```dart
    import 'dart:async';
    import 'dart:ffi';

    import 'package:flutter/foundation.dart';
    import 'package:flutter/services.dart';

    //callback interface
    abstract class LivenessDetectionCallback {
      void onGetDetectionResult(bool isSuccess, Map? resultMap);
    }

    // supported market
    enum Market {
      Indonesia,
      India,
      Philippines,
      Vietnam,
      Thailand,
      Malaysia,
      BPS,
      CentralData,
      Mexico,
      Singapore,
      Nigeria,
      Colombia,
      Aksata
    }

    // supported action
    enum DetectionType { MOUTH, BLINK, POS_YAW }
    
    enum DetectionLevel { EASY, NORMAL, HARD }

    // plugin
    class LivenessPlugin {
      static const MethodChannel _channel = const MethodChannel('liveness_plugin');
      static const String platformVersion = "1.0";

      // accessKey&secretKey way to init SDK
      static void initSDK(String accessKey, String secretKey, Market market) {
        String marketStr = market.toString();
        _channel.invokeMethod('initSDK', {
          "accessKey": accessKey,
          "secretKey": secretKey,
          "market":
              marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
          "isGlobalService": false
        });
      }

      static void initSDKForGlobalService(
          String accessKey, String secretKey, Market market) {
        String marketStr = market.toString();
        _channel.invokeMethod('initSDK', {
          "accessKey": accessKey,
          "secretKey": secretKey,
          "market":
              marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
          "isGlobalService": true
        });
      }

      // license way to init SDK
      static void initSDKOfLicense(Market market) {
        String marketStr = market.toString();
        _channel.invokeMethod('initSDKOfLicense', {
          "market":
              marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
          "isGlobalService": false
        });
      }

      static void initSDKOfLicenseForGlobalService(Market market) {
        String marketStr = market.toString();
        _channel.invokeMethod('initSDKOfLicense', {
          "market":
              marketStr.substring(marketStr.indexOf(".") + 1, marketStr.length),
          "isGlobalService": true
        });
      }

      static Future<String?> setLicenseAndCheck(String license) async {
        String? result =
            await _channel.invokeMethod("setLicenseAndCheck", {"license": license});
        return result;
      }

      static void startLivenessDetection(
          LivenessDetectionCallback livenessDetectionCallback) {
        Future<String> livenessCall(MethodCall methodCall) async {
          switch (methodCall.method) {
            case "init":
              break;
            case "onDetectionSuccess":
              print("onDetectionSuccess called:" +
                  livenessDetectionCallback.toString());
              livenessDetectionCallback.onGetDetectionResult(
                  true, (methodCall.arguments as Map?));
              break;
            case "onDetectionFailure":
              livenessDetectionCallback.onGetDetectionResult(
                  false, (methodCall.arguments as Map?));
              break;
          }
          return "";
        }

        _channel.setMethodCallHandler(livenessCall);
        _channel.invokeMethod("startLivenessDetection");
      }

      static void setActionSequence(
          bool shuffle, List<DetectionType> actionSequence) {
        List<String> actionList = [];
        for (var detectionType in actionSequence) {
          var detectionTypeStr = detectionType.toString();
          actionList.add(detectionTypeStr.substring(
              detectionTypeStr.indexOf(".") + 1, detectionTypeStr.length));
        }
        _channel.invokeMethod("setActionSequence",
            {"shuffle": shuffle, "actionSequence": actionList});
      }

      static void setDetectionLevel(DetectionLevel detecionLevel) {
        String detecionLevelStr = detecionLevel.toString();
        _channel.invokeMethod("setDetectionLevel", {"detectionLevel": detecionLevelStr.substring(detecionLevelStr.indexOf(".") + 1)});
      }

      static void setDetectOcclusion(bool detectOcclusion) {
        _channel.invokeMethod("setDetectOcclusion", {"detectOcclusion": detectOcclusion});
      }

      static void set3DLivenessTimeoutMills(int timeoutMills) {
        _channel.invokeMethod(
            "set3DLivenessTimeoutMills", {"timeoutMills": timeoutMills});
      }
      
      static void setActionTimeoutMills(int actionTimeoutMills) {
        _channel.invokeMethod(
            "setActionTimeoutMills", {"actionTimeoutMills": actionTimeoutMills});
      }

      static void setResultPictureSize(int resultPictureSize) {
        _channel.invokeMethod("setResultPictureSize", {"resultPictureSize": resultPictureSize});
      }

      static void bindUser(String userId) {
        _channel.invokeMethod("bindUser", {"userId": userId});
      }

      static get getSDKVersion async {
        return await _channel.invokeMethod("getSDKVersion");
      }

      static get getLatestDetectionResult async {
        return await _channel.invokeMethod("getLatestDetectionResult");
      }
    }
    ```

    Finally add liveness-plugin to your flutter project:
    ```shell
    dart pub add liveness_plugin --path liveness_plugin
    ```