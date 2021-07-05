class InvalidSettingsException implements Exception {
  const InvalidSettingsException(this.message);

  final String message;
}
