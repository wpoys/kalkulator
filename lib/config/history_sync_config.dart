class HistorySyncConfig {
  static const String apiUrl = String.fromEnvironment('HISTORY_API_URL');

  static bool get enabled => apiUrl.isNotEmpty;
}
