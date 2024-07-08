class LivenessCheckException implements Exception {
  final String message;

  LivenessCheckException(this.message);

  // TODO(sun): Handle status codes
}
