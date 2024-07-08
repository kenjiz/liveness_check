import 'package:liveness_plugin/liveness_plugin.dart';

class LivenessCheckCallback implements LivenessDetectionCallback {
  LivenessCheckCallback({required this.callback});

  final Function(bool isSuccess, Map resultMap) callback;

  @override
  void onGetDetectionResult(bool isSuccess, Map resultMap) => callback(isSuccess, resultMap);
}
