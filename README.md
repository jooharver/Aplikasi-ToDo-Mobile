# 📔 Agenda Nusantara — Task Management App

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Language-Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)](https://sqlite.org)
[![Style](https://img.shields.io/badge/Design-iOS%20Notes-FFB800)](https://apple.com/ios)

**Agenda Nusantara** adalah aplikasi manajemen tugas berbasis mobile yang dirancang dengan estetika minimalis. Aplikasi ini dibangun sebagai proyek portofolio profesional dan memenuhi kriteria Sertifikasi Kompetensi Mahasiswa Jurusan Teknologi Informasi, Politeknik Negeri Malang.

---

## 🌟 Fitur Utama

Aplikasi ini menggabungkan fungsionalitas manajemen data yang kuat dengan pengalaman pengguna yang mulus:

* **🔐 Secure Local Authentication:** Sistem login terintegrasi dengan database SQLite untuk keamanan data pengguna secara luring.
* **📊 Insightful Dashboard:** Visualisasi data menggunakan grafik batang untuk statistik penyelesaian tugas dalam 7 hari terakhir.
* **📂 Smart Date Grouping:** Tugas dikelompokkan secara otomatis berdasarkan tanggal jatuh tempo untuk memudahkan pemantauan *deadline*.
* **⭐ Priority Marking:** Sistem kategori "Penting" dengan indikator visual bintang merah yang intuitif.
* **👆 Gestural Interaction:** Fitur *Swipe-to-Delete* dengan dialog konfirmasi bergaya `Cupertino` (iOS) untuk mencegah penghapusan data yang tidak disengaja.
* **🎨 Premium UI/UX:** Desain *Light Theme* yang bersih, menggunakan palet warna *Notes Yellow* (#FFB800), font Inter, dan transisi animasi halus.

---

## 🛠️ Tech Stack

| Komponen | Teknologi |
| :--- | :--- |
| **Framework** | Flutter SDK (StatefulWidget) |
| **Language** | Dart |
| **Local Database** | `sqflite` (SQLite) |
| **Date Formatting** | `intl` (Internationalization) |
| **Architecture** | Model-View-Helper |

---

## 🚀 Memulai Proyek

Ikuti langkah berikut untuk menjalankan proyek ini di lingkungan pengembangan lokal Anda:

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/jooharver/Aplikasi-ToDo-Mobile.git
    ```
2.  **Masuk ke direktori:**
    ```bash
    cd agenda-nusantara
    ```
3.  **Instal dependensi:**
    ```bash
    flutter pub get
    ```
4.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

## 📁 Struktur Folder

```text
lib/
├── database/     # Logika CRUD & Inisialisasi SQLite (DbHelper)
├── models/       # Definisi model data (Todo, User)
├── screens/      # Halaman antarmuka pengguna (UI Screens)
└── main.dart     # Entry point aplikasi