import 'package:flutter/material.dart';
import '../akademik/akademik_page.dart';
import '../ult/ult_page.dart';

class LayananAntrianPage extends StatelessWidget {
  const LayananAntrianPage({super.key});

  static const _blue = Color(0xFF168DE2);
  static const _ink = Color(0xFF202020);

  // Tambahkan layanan baru pada daftar ini ketika sudah tersedia.
  static final List<_LayananAntrian> _layanan = [
    _LayananAntrian(
      title: 'Akademik',
      description: 'Pengajuan administrasi dan kebutuhan akademik mahasiswa.',
      icon: Icons.school_rounded,
      pageBuilder: (_) => const AkademikPage(),
    ),
    _LayananAntrian(
      title: 'ULT',
      description: 'Ambil nomor antrean Unit Layanan Terpadu.',
      icon: Icons.confirmation_number_rounded,
      pageBuilder: (_) => const UltPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      // AppBar mengikuti halaman Pengaduan.
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _ink,
            size: 19,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        titleSpacing: 0,

        title: const Text(
          'Antrian Tiket',
          style: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Gradient sama persis dengan halaman Pengaduan.
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
                  'Pilih layanan',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Pilih layanan Akademik atau ULT sesuai kebutuhan Anda.',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

                // Daftar tetap bisa ditambah melalui _layanan.
                for (int index = 0; index < _layanan.length; index++) ...[
                  if (index > 0) const SizedBox(height: 12),

                  Material(
                    color: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFFD6E9F7),
                        width: 0.8,
                      ),
                    ),

                    clipBehavior: Clip.antiAlias,

                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: _layanan[index].pageBuilder,
                          ),
                        );
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 20,
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7FF),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                _layanan[index].icon,
                                color: _blue,
                                size: 32,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _layanan[index].title,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    _layanan[index].description,
                                    style: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _blue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LayananAntrian {
  const _LayananAntrian({
    required this.title,
    required this.description,
    required this.icon,
    required this.pageBuilder,
  });

  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder pageBuilder;
}
