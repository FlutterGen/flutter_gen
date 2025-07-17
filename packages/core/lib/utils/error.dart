class InvalidSettingsException implements Exception {
  const InvalidSettingsException(this.message);

  final String message;

  @override
  String toString() => 'InvalidSettingsException: $message';
}
