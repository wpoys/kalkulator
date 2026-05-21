import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/history_model.dart';
import '../services/history_sync_service.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<HistoryModel> _sessionHistory = [];
  List<HistoryModel> _persistentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadPersistentHistory();
  }

  Future<void> _loadPersistentHistory() async {
    List<HistoryModel> items = const [];
    try {
      items = await DatabaseHelper.instance.getAllHistory();
    } catch (_) {
      // On platforms without SQLite support (for example web), continue with empty local history.
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (items.isEmpty) {
        return;
      }

      final existingKeys = _persistentHistory
          .map((item) => '${item.expression}|${item.result}|${item.createdAt}')
          .toSet();
      final merged = List<HistoryModel>.from(_persistentHistory);

      for (final item in items) {
        final key = '${item.expression}|${item.result}|${item.createdAt}';
        if (!existingKeys.contains(key)) {
          merged.add(item);
        }
      }

      merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _persistentHistory = merged;
    });
  }

  Future<HistoryModel> _onCalculated(String expression, String result) async {
    final item = HistoryModel(
      expression: expression,
      result: result,
      title: null,
      createdAt: DateTime.now().toIso8601String(),
    );

    HistoryModel inserted = item;
    try {
      final id = await DatabaseHelper.instance.insertHistory(item);
      inserted = item.copyWith(id: id);
    } catch (_) {
      // Keep working without local persistence when SQLite is unavailable.
    }

    try {
      await HistorySyncService.instance.syncInsert(inserted);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _sessionHistory.insert(0, inserted);
        _persistentHistory.insert(0, inserted);
      });
    }

    return inserted;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      CalculatorScreen(
        onCalculated: _onCalculated,
      ),
      HistoryScreen(
        sessionHistory: _sessionHistory,
        persistentHistory: _persistentHistory,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Calculator'
              : _currentIndex == 1
              ? 'History'
              : 'Profile',
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
