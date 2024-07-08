import 'dart:convert';

import 'package:aai_liveness_check/src/liveness_check_callback.dart';
import 'package:aai_liveness_check/src/liveness_check_exception.dart';
import 'package:aai_liveness_check/src/liveness_detection_response.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:liveness_plugin/liveness_plugin.dart';

/// The Advance AI Liveness Check SDK wrapper.
///
/// The [accessKey] is used to authenticate with the Advance AI API.
///
/// The [secretKey] is used to authenticate with the Advance AI API.
///
/// The [baseUrl] of the Advance AI API.
///
/// The [market] is used to determine the market specified in your Advance AI account.
class AaiLivenessCheck {
  AaiLivenessCheck({
    required String accessKey,
    required String secretKey,
    required String baseUrl,
    required Market market,
  })  : _accessKey = accessKey,
        _secretKey = secretKey,
        _baseUrl = baseUrl,
        _market = market;

  final String _accessKey;
  final String _secretKey;
  final String _baseUrl;
  final Market _market;

  late LivenessCheckCallback _livenessCheckCallback;
  late String _token;

  Dio get _dio => Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          receiveDataWhenStatusError: true,
          contentType: 'application/json',
        ),
      );

  /// Initialize the Advance AI Liveness SDK.
  ///
  /// This method should be called right before starting the liveness detection
  /// as it will initialize the SDK and get the necessary token and license.
  /// 
  /// The [livenessCheckCallback] is called after the liveness detection is done.
  Future<void> initialize({required Function(bool, Map) livenessCheckCallback}) async {
    LivenessPlugin.initSDKOfLicense(_market);

    _livenessCheckCallback = LivenessCheckCallback(callback: livenessCheckCallback);

    await _setToken();
    await _setLicense();
  }

  Future<void> _setToken() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final encodedString = utf8.encode('$_accessKey$_secretKey$timestamp');
    final hashedSignature = sha256.convert(encodedString).toString();

    final tokenResponse = await _dio.post<Map>(
      'openapi/auth/ticket/v1/generate-token',
      data: {
        'accessKey': _accessKey,
        'timestamp': timestamp,
        'signature': hashedSignature,
        'periodSecond': null,
      },
    );

    final tokenData = tokenResponse.data!;

    if (tokenData['code'] != 'SUCCESS') {
      throw LivenessCheckException('Failed to get token.\n${tokenResponse.data}');
    }

    _token = tokenData['data']['token'] as String;
  }

  Future<void> _setLicense() async {
    final licenseResponse = await _dio.post<Map>(
      'intl/openapi/face-identity/v1/auth-license',
      options: Options(headers: {'X-ACCESS-TOKEN': _token}),
      data: {
        'licenseEffectiveSeconds': null,
        'applicationId': null,
      },
    );

    final licenseData = licenseResponse.data!;

    if (licenseData['code'] != 'SUCCESS') {
      throw LivenessCheckException('Failed to get license.\n${licenseResponse.data}');
    }

    final license = licenseData['data']['license'] as String;
    final result = await LivenessPlugin.setLicenseAndCheck(license);

    if (result != 'SUCCESS') {
      throw LivenessCheckException('Failed to set license');
    }
  }

  /// Start the liveness detection.
  ///
  /// This method should be called after the SDK has been initialized. After
  /// the liveness detection is done, the [callback] that was passed to the
  /// [initialize] method will be called.
  void startLivenessDetection() {
    LivenessPlugin.startLivenessDetection(_livenessCheckCallback);
  }

  /// Get the liveness result.
  Future<LivenessDetectionResponse> getLivenessResult(
    String livenessId, {
    String region = 'PH',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'intl/openapi/face-identity/v1/liveness-detection',
      options: Options(headers: {'X-ACCESS-TOKEN': _token}),
      data: {
        'livenessId': livenessId,
        'region': region,
        'resultType': 'IMAGE_BASE64',
      },
    );

    return LivenessDetectionResponse.fromJson(response.data!);
  }
}
