import 'package:flutter/material.dart';
import 'permintaan_data/permintaan_data_page.dart';
import 'aplikasi/aplikasi_page.dart';
import 'website/website_page.dart';
import 'wifi_internet/wifi_internet_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<ServiceData> services = [
      ServiceData(
        title: 'Permintaan\nData',
        imagePath: 'assets/images/file.jpeg',
      ),
      ServiceData(title: 'Wifi/Internet', imagePath: 'assets/images/wifi.jpeg'),
      ServiceData(title: 'Aplikasi', imagePath: 'assets/images/app.jpeg'),
      ServiceData(title: 'Website', imagePath: 'assets/images/web.jpeg'),
      ServiceData(
        title: 'Fasilitas\nRuangan',
        imagePath: 'assets/images/building.jpeg',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Background sama dengan halaman Permintaan Data.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),

                _buildAnnouncement(context),

                _buildServiceMenu(context: context, services: services),

                _buildQueueStatus(context),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Container(
      height: 165,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Stack(
        fit: StackFit.expand,
        children: [
          // Foto Gedung POLNEP.
          Image.asset(
            'assets/images/hero.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.1),
          ),

          // Lapisan biru agar sesuai dengan warna aplikasi.
          Container(color: const Color(0x993AA7F5)),

          // Gradient bagian bawah header.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x003AA7F5),
                  Color(0x33267EBA),
                  Color(0x881168AA),
                ],
              ),
            ),
          ),

          // Logo dan deskripsi.
          Positioned(
            top: 15,
            left: 14,
            right: 14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 82,
                  height: 82,
                  child: Image.asset(
                    'assets/images/logopolnep-BESAR.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(width: 13),

                const Expanded(
                  child: Padding(
                    // Nilai top bisa diperbesar jika tulisan
                    // ingin diturunkan lagi.
                    padding: EdgeInsets.only(top: 18),
                    child: Text(
                      'Aplikasi untuk merespon permintaan, pertanyaan '
                      'dan keluhan terhadap layanan di Politeknik Negeri '
                      'Pontianak.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(color: Color(0x55000000), blurRadius: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nomor telepon dan email.
          const Positioned(
            left: 15,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '0561 736180',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'kampus@polnep.ac.id',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ANNOUNCEMENT
  // =========================================================

  Widget _buildAnnouncement(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E9F7), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Announcement',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF202020),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    _showMessage(
                      context,
                      'Halaman semua pengumuman belum dibuat.',
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'Read More',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF168DE2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Card isi pengumuman.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 11, 10, 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFB9E9FF), Color(0xFFEAF8FF)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF90D1F7), width: 0.8),
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PEMELIHARAAN SISTEM SIAKAD',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.2,
                    color: Color(0xFF135F91),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 9),

                Text(
                  'Akan dilakukan pemeliharaan sistem pada tanggal 25 '
                  'September 2026 pukul 13.00 - 15.00 WIB.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202020),
                  ),
                ),

                SizedBox(height: 22),

                Text(
                  '21 September 2026',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF168DE2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MENU LAYANAN
  // =========================================================

  Widget _buildServiceMenu({
    required BuildContext context,
    required List<ServiceData> services,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E9F7), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: GridView.builder(
        itemCount: services.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.95,
          crossAxisSpacing: 5,
          mainAxisSpacing: 7,
        ),

        itemBuilder: (BuildContext context, int index) {
          final ServiceData service = services[index];

          return ServiceMenuItem(
            service: service,

            onTap: () {
              // PERMINTAAN DATA
              if (index == 0) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const PermintaanDataPage();
                    },
                  ),
                );
                return;
              }

              // WIFI / INTERNET
              if (index == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const WifiInternetPage();
                    },
                  ),
                );
                return;
              }

              // APLIKASI
              if (index == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const AplikasiPage();
                    },
                  ),
                );
                return;
              }

              // WEBSITE
              if (index == 3) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const WebsitePage();
                    },
                  ),
                );
                return;
              }

              // FASILITAS RUANGAN
              if (index == 4) {
                _showMessage(context, 'Menu Fasilitas Ruangan belum dibuat.');
                return;
              }
            },
          );
        },
      ),
    );
  }

  // =========================================================
  // CEK STATUS ANTRIAN
  // =========================================================

  Widget _buildQueueStatus(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 76,
      margin: const EdgeInsets.fromLTRB(8, 14, 8, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E9F7), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(12),

          onTap: () {
            _showMessage(context, 'Halaman cek status antrian belum dibuat.');
          },

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),

            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 48,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7FF),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Image.asset(
                    'assets/images/card.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 17),

                const Expanded(
                  child: Text(
                    'Cek Status Antrian',
                    style: TextStyle(
                      color: Color(0xFF202020),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF3AA7F5),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// ===========================================================
// ITEM MENU
// ===========================================================

class ServiceMenuItem extends StatelessWidget {
  const ServiceMenuItem({
    required this.service,
    required this.onTap,
    super.key,
  });

  final ServiceData service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),

          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 53,
                height: 53,
                padding: const EdgeInsets.all(2),

                decoration: BoxDecoration(
                  color: const Color(0xFFF5FBFF),
                  borderRadius: BorderRadius.circular(9),
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),

                  child: Image.asset(service.imagePath, fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                service.title,
                textAlign: TextAlign.center,
                maxLines: 2,

                style: const TextStyle(
                  color: Color(0xFF202020),
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// DATA MENU
// ===========================================================

class ServiceData {
  const ServiceData({required this.title, required this.imagePath});

  final String title;
  final String imagePath;
}
