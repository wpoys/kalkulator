import 'package:flutter/material.dart';

import '../models/history_model.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryModel> sessionHistory;
  final List<HistoryModel> persistentHistory;

  const HistoryScreen({
    super.key,
    required this.sessionHistory,
    required this.persistentHistory,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.055).clamp(18.0, 24.0);
    final itemSize = (width * 0.038).clamp(13.0, 17.0);
    final displayHistory = persistentHistory.isNotEmpty
        ? persistentHistory
        : sessionHistory;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 480,
          minWidth: 280,
          maxHeight: double.infinity,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Riwayat',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: titleSize,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text('Sesi: ${sessionHistory.length}'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: displayHistory.isEmpty
                  ? const Center(
                      child: Text('Belum ada riwayat perhitungan.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      itemCount: displayHistory.length,
                      itemBuilder: (context, index) {
                        final item = displayHistory[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Icon(
                                Icons.history,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              '${item.expression} = ${item.result}',
                              style: TextStyle(
                                fontSize: itemSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    item.createdAt,
                                    style: TextStyle(
                                      fontSize: itemSize - 1,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
