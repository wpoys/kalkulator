import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.065).clamp(22.0, 30.0);
    final bodySize = (width * 0.040).clamp(14.0, 18.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 480,
          minWidth: 280,
          maxHeight: double.infinity,
        ),
        child: Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profil Pengguna',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: titleSize,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nama: Pengguna Kalkulator',
                    style: TextStyle(fontSize: bodySize),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aplikasi: Kalkulator Cerdas',
                    style: TextStyle(fontSize: bodySize),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Versi: 1.0.0',
                    style: TextStyle(fontSize: bodySize),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aplikasi ini mendukung perhitungan dasar, riwayat sesi, dan penyimpanan permanen SQLite.',
                    style: TextStyle(
                      fontSize: bodySize,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
