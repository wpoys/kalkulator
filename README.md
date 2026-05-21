# calculator

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## History Sync to MySQL

Riwayat perhitungan tetap disimpan ke SQLite lokal, lalu bisa disinkronkan ke MySQL/phpMyAdmin lewat backend PHP.

1. Import `backend/schema.sql` ke database MySQL Anda.
2. Edit kredensial di `backend/history_api.php`.
3. Jalankan aplikasi dengan `--dart-define=HISTORY_API_URL=https://domain-anda.com/history_api.php`.
