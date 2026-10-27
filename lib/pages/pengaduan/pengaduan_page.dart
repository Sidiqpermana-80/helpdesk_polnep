import 'package:flutter/material.dart';

import '../aplikasi/aplikasi_page.dart';
import '../fasilitas_ruangan/fasilitas_ruangan_page.dart';
import '../website/website_page.dart';
import '../wifi_internet/wifi_internet_page.dart';
import '../pengaduan_akademik/pengaduan_akademik_page.dart';
import '../pungli/pungli_page.dart';
import '../ppkpt/ppkpt_page.dart';

class PengaduanPage extends StatelessWidget {
  const PengaduanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF202020),
            size: 19,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        titleSpacing: 0,

        title: const Text(
          'Pengaduan',
          style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
          ),
        ),

        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih jenis pengaduan',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Laporkan kendala layanan, sistem, jaringan, '
                  'atau fasilitas kampus.',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    // Dua kolom pada layar biasa.
                    // Satu kolom jika area layar sangat sempit.
                    final double width = constraints.maxWidth < 280
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,

                      children: [
                        _ComplaintCard(
                          width: width,
                          title: 'Wi-Fi/Internet',
                          imagePath: 'assets/images/wifi.jpeg',
                          imageScale: 1.0,
                          fallbackIcon: Icons.wifi_rounded,
                          destination: const WifiInternetPage(),
                        ),

                        _ComplaintCard(
                          width: width,
                          title: 'Website',
                          imagePath: 'assets/images/web.jpeg',
                          imageScale: 1.0,
                          fallbackIcon: Icons.language_rounded,
                          destination: const WebsitePage(),
                        ),

                        _ComplaintCard(
                          width: width,
                          title: 'Aplikasi',
                          imagePath: 'assets/images/app.jpeg',
                          imageScale: 1.0,
                          fallbackIcon: Icons.apps_rounded,
                          destination: const AplikasiPage(),
                        ),

                        _ComplaintCard(
                          width: width,
                          title: 'Fasilitas Ruangan',
                          imagePath: 'assets/images/building.jpeg',
                          imageScale: 1.0,
                          fallbackIcon: Icons.meeting_room_rounded,
                          destination: const FasilitasRuanganPage(),
                        ),

                        _ComplaintCard(
                          width: width,
                          title: 'Akademik',
                          imagePath: 'assets/images/mhs.png',
                          imageScale: 1.3,
                          fallbackIcon: Icons.school_rounded,
                          destination: const PengaduanAkademikPage(),
                        ),

                        _ComplaintCard(
                          width: width,
                          title: 'Pungli',
                          imagePath: 'assets/images/pungli.png',
                          imageScale: 1.3,
                          fallbackIcon: Icons.report_outlined,
                          destination: const PungliPage(),
                        ),

                        _ComplaintCard(
                          width: width,
                          title: 'PPKPT',
                          imagePath: 'assets/images/ppkpt.png',
                          imageScale: 1.4,
                          fallbackIcon: Icons.shield_outlined,
                          destination: const PpkptPage(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// KARTU JENIS PENGADUAN
// =========================================================

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({
    required this.width,
    required this.title,
    required this.imagePath,
    required this.fallbackIcon,
    required this.destination,
    this.imageScale = 1.0,
  });

  final double width;
  final String title;
  final String imagePath;
  final IconData fallbackIcon;
  final Widget destination;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,

      child: Material(
        color: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFD6E9F7), width: 0.8),
        ),

        clipBehavior: Clip.antiAlias,

        child: InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => destination));
          },

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),

            child: Column(
              children: [
                // Area tata letak gambar tetap 56 x 56.
                SizedBox(
                  width: 56,
                  height: 56,

                  child: Transform.scale(
                    scale: imageScale,

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),

                      child: Image.asset(
                        imagePath,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,

                        // Ikon cadangan jika gambar gagal dimuat.
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            fallbackIcon,
                            size: 56,
                            color: const Color(0xFF168DE2),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
