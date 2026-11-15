# BaBook Front End

Aplikasi mobile baca buku **BaBook**, dibuat dengan Flutter.
Aplikasi ini terhubung ke [BaBook-Backend](https://github.com/TypingTech/BaBook-Backend) (REST API PHP + MySQL) untuk autentikasi.

**Status:** dalam pengembangan.

## Fitur

- Register akun baru
- Login (token disimpan dengan aman di perangkat)
- Lupa password dan reset password dengan kode OTP lewat email
- Validasi input dan pesan error dari server

## Teknologi

| Bagian        | Teknologi                                  |
| ------------- | ------------------------------------------ |
| Framework     | Flutter (Dart)                             |
| HTTP          | paket `http`                               |
| Simpan token  | paket `flutter_secure_storage`             |
| Backend       | PHP 8.3, MySQL 8, Docker (repo terpisah)   |

## Struktur Folder

```
lib/
  main.dart                       titik masuk aplikasi
  features/
    halaman_utama.dart            halaman awal
    halaman_login.dart            login
    halaman_signup.dart           registrasi
    halaman_lupa_password.dart    minta kode OTP
    halaman_reset_password.dart   input kode OTP + password baru
    halaman_home.dart             beranda setelah login
  routes/
    app_routes.dart               daftar rute / navigasi
  services/
    api_service.dart              semua pemanggilan API + penyimpanan token
assets/
  images/logo.png
```

## Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (cek dengan `flutter doctor`)
- VS Code atau Android Studio
- Android Emulator atau HP Android (untuk menjalankan aplikasi)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (untuk menjalankan backend)
- Akses ke repo backend (repo bersifat private, minta akses ke pemiliknya)

## Cara Menjalankan

### 1. Jalankan backend

Clone dan jalankan [BaBook-Backend](https://github.com/TypingTech/BaBook-Backend) sesuai README-nya. Ringkasnya:

```bash
git clone https://github.com/TypingTech/BaBook-Backend.git
cd BaBook-Backend
```

Buat file `.env` (isi mengikuti `.env.example` bila ada), contoh:

```
DB_HOST=db
DB_NAME=babook
DB_USER=app_user
DB_PASS=app_pass
DB_ROOT_PASS=root

MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_FROM=noreply@babook.local
OTP_TTL_MINUTES=10
TOKEN_TTL_DAYS=7
```

Lalu jalankan:

```bash
docker compose up -d --build
docker compose exec web composer install
```

| Layanan                   | Alamat                |
| ------------------------- | --------------------- |
| API                       | http://localhost:8080 |
| phpMyAdmin                | http://localhost:8081 |
| Mailpit (inbox email tes) | http://localhost:8025 |

### 2. Jalankan aplikasi Flutter

```bash
git clone <url-repo-frontend-ini>
cd babook_front_end
flutter pub get
flutter run
```

Pilih perangkat (emulator atau HP) lalu tunggu proses build selesai.

## Pengaturan Alamat Server (Base URL)

Alamat server diatur di `lib/services/api_service.dart`. Secara default dipilih otomatis:

| Tempat aplikasi berjalan              | Base URL                      |
| ------------------------------------- | ----------------------------- |
| Android Emulator                      | `http://10.0.2.2:8080/api`    |
| Windows desktop / iOS Simulator / Web | `http://localhost:8080/api`   |
| HP asli (satu WiFi dengan laptop)     | `http://<IP-laptop>:8080/api` |

Untuk HP asli, isi konstanta `_manualBaseUrl`:

```dart
static const String _manualBaseUrl = 'http://192.168.1.10:8080/api';
```

Cek IP laptop dengan `ipconfig` (Windows), dan pastikan port 8080 diizinkan di Windows Firewall.

Jika port backend diubah di `docker-compose.yml`, ubah juga angkanya di sini lalu jalankan ulang aplikasi (bukan hot reload).

## Izin Android

Backend lokal memakai HTTP biasa, jadi `android/app/src/main/AndroidManifest.xml` harus memuat:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true" ...>
```

`usesCleartextTraffic` hanya untuk development. Hapus saat backend sudah memakai HTTPS.

## Alur Penggunaan

1. **Sign Up**: isi nama, email, password (minimal 8 karakter), lalu diarahkan ke Login.
2. **Login**: token disimpan di perangkat, lalu masuk ke beranda.
3. **Forget password?**: isi email, kode 6 digit dikirim ke email.
4. **Reset Password**: isi kode dan password baru, lalu kembali ke Login.

Selama development, email tidak dikirim ke inbox asli. Kode OTP dilihat di **Mailpit**: http://localhost:8025

Dokumentasi lengkap endpoint ada di `Api.md` pada repo backend.

## Pemecahan Masalah

| Masalah                                  | Penyebab dan solusi                                                                                                   |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| "Tidak bisa terhubung ke server"         | Backend belum jalan, port salah, atau aplikasi dijalankan di Chrome (diblokir CORS). Cek `docker compose ps`.          |
| "Server tidak merespons"                 | Alamat salah untuk perangkatmu. `10.0.2.2` hanya untuk emulator. HP asli pakai IP laptop dan izinkan firewall.         |
| Kode OTP tidak ada di email              | Email dikirim ke Mailpit (`localhost:8025`), bukan Gmail. Pastikan email yang diisi terdaftar.                         |
| Error `package:http` / `flutter_secure_storage` | Jalankan `flutter pub add http flutter_secure_storage` lalu `flutter pub get`.                                  |
| Port 8080 / 8081 sudah dipakai           | Hentikan program yang memakainya, atau ubah port kiri di `docker-compose.yml`.                                         |
| Build Android gagal                      | Jalankan `flutter clean`, `flutter pub get`, lalu jalankan ulang.                                                      |

## Catatan Pengembangan

- Hindari menjalankan di Chrome sampai backend mengaktifkan CORS.
- File `.env` tidak boleh di-commit. Jangan menaruh password asli di repositori.
- Setelah mengubah nilai `const` (misalnya base URL), hentikan dan jalankan ulang aplikasi.

## Tim

Dikembangkan oleh **TypingTech**.
