class LivenessDetectionResponse {
  LivenessDetectionResponse({
    required this.code,
    required this.transactionId,
    required this.pricingStrategy,
    required this.message,
    this.data,
    this.extra,
  });

  factory LivenessDetectionResponse.fromJson(Map<String, dynamic> json) {
    return LivenessDetectionResponse(
      code: LivenessStatusCode.fromJson(json['code'] as String),
      transactionId: json['transactionId'] as String,
      pricingStrategy: PricingStrategy.fromJson(json['pricingStrategy'] as String),
      message: json['message'] as String,
      data: json['data'] != null ? LivenessData.fromJson(json['data'] as Map<String, dynamic>) : null,
      extra: json['extra'],
    );
  }

  final LivenessStatusCode code;
  final String transactionId;
  final PricingStrategy pricingStrategy;
  final String message;
  final LivenessData? data;
  final dynamic extra;
}

enum LivenessResponseCode {
  livenessIdNotExisted,
  parameterError;

  factory LivenessResponseCode.fromJson(String value) {
    return switch (value) {
      'LIVENESS_ID_NOT_EXISTED' => LivenessResponseCode.livenessIdNotExisted,
      'PARAMETER_ERROR' => LivenessResponseCode.parameterError,
      _ => throw Exception('Unknown value: $value')
    };
  }
}

enum LivenessStatusCode {
  success,
  error,
  emptyParameterError,
  insufficientBalance,
  serviceBusy,
  iAmFailed,
  parameterError,
  overQueryLimit,
  clientError,
  retryLater;

  factory LivenessStatusCode.fromJson(String value) {
    return switch (value) {
      'SUCCESS' => LivenessStatusCode.success,
      'ERROR' => LivenessStatusCode.error,
      'EMPTY_PARAMETER_ERROR' => LivenessStatusCode.emptyParameterError,
      'INSUFFICIENT_BALANCE' => LivenessStatusCode.insufficientBalance,
      'SERVICE_BUSY' => LivenessStatusCode.serviceBusy,
      'IAM_FAILED' => LivenessStatusCode.iAmFailed,
      'PARAMETER_ERROR' => LivenessStatusCode.parameterError,
      'OVER_QUERY_LIMIT' => LivenessStatusCode.overQueryLimit,
      'CLIENT_ERROR' => LivenessStatusCode.clientError,
      'RETRY_LATER' => LivenessStatusCode.retryLater,
      _ => throw Exception('Unknown value: $value')
    };
  }
}

enum PricingStrategy {
  free,
  pay;

  factory PricingStrategy.fromJson(String value) {
    return switch (value) {
      'FREE' => PricingStrategy.free,
      'PAY' => PricingStrategy.pay,
      _ => throw Exception('Unknown value: $value')
    };
  }
}

class LivenessData {
  LivenessData({required this.detectionResult, required this.livenessScore});

  factory LivenessData.fromJson(Map<String, dynamic> json) {
    return LivenessData(
      detectionResult: json['detectionResult'] as String,
      livenessScore: json['livenessScore'] as double,
    );
  }

  final String detectionResult;
  final double livenessScore;
}
