import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/history_sync_config.dart';
import '../models/history_model.dart';

class HistorySyncService {
  HistorySyncService._internal();

  static final HistorySyncService instance = HistorySyncService._internal();

  Future<void> syncInsert(HistoryModel item) async {
    if (!HistorySyncConfig.enabled) {
      return;
    }

    await _postJson({
      'action': 'insert',
      'expression': item.expression,
      'result': item.result,
      'title': item.title ?? '',
      'created_at': item.createdAt,
    });
  }

  Future<void> syncUpdateTitle(HistoryModel item, String title) async {
    if (!HistorySyncConfig.enabled) {
      return;
    }

    await _postJson({
      'action': 'update_title',
      'id': (item.id ?? 0).toString(),
      'expression': item.expression,
      'result': item.result,
      'created_at': item.createdAt,
      'title': title,
    });
  }

  Future<void> syncClear() async {
    if (!HistorySyncConfig.enabled) {
      return;
    }

    await _postJson({'action': 'clear'});
  }

  Future<void> _postJson(Map<String, String> body) async {
    final response = await http.post(
      Uri.parse(HistorySyncConfig.apiUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to sync history: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic> && decoded['success'] == true) {
      return;
    }

    throw Exception('History sync rejected by server.');
  }
}
