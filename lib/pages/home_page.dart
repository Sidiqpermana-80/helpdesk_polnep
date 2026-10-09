import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../config/api_config.dart';

import 'akademik/akademik_page.dart';
import 'ult/ult_page.dart';
import 'pengaduan/pengaduan_page.dart';
import 'cek_status/cek_status_page.dart';
import 'announcement/announcement_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AnnouncementData> _announcements = <AnnouncementData>[];

  final PageController _announcementPageController = PageController();

  Timer? _announcementTimer;

  int _currentAnnouncementIndex = 0;

  bool _isLoadingAnnouncement = true;
  bool _announcementLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _refreshPage() async {
    await _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    if (mounted) {
      setState(() {
        _isLoadingAnnouncement = true;
        _announcementLoadError = false;
      });
    }

    try {
      final http.Response response = await http
          .get(
            Uri.parse(ApiConfig.announcements),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('HOME ANNOUNCEMENT STATUS: ${response.statusCode}');

      debugPrint('HOME ANNOUNCEMENT RESPONSE: ${response.body}');

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw const FormatException('Response announcement tidak valid.');
      }

      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        throw const FormatException('Daftar announcement tidak valid.');
      }

      final List<AnnouncementData> announcements = <AnnouncementData>[];

      for (final dynamic item in rawData) {
        if (item is Map<String, dynamic>) {
          announcements.add(AnnouncementData.fromJson(item));
        } else if (item is Map) {
          announcements.add(
            AnnouncementData.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }

      announcements.sort((AnnouncementData a, AnnouncementData b) {
        final DateTime? dateA = a.publishedAt;
        final DateTime? dateB = b.publishedAt;

        if (dateA == null && dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _announcements = announcements;
        _isLoadingAnnouncement = false;
        _announcementLoadError = false;
        _currentAnnouncementIndex = 0;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            !_announcementPageController.hasClients ||
            _announcements.isEmpty) {
          return;
        }

        _announcementPageController.jumpToPage(0);
      });

      _startAnnouncementAutoSlide();
    } on TimeoutException {
      debugPrint('HOME ANNOUNCEMENT ERROR: Timeout');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingAnnouncement = false;
        _announcementLoadError = true;
      });
    } catch (e) {
      debugPrint('HOME ANNOUNCEMENT ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingAnnouncement = false;
        _announcementLoadError = true;
      });
    }
  }

  // =========================================================
  // AUTO SLIDE PENGUMUMAN
  // =========================================================

  void _startAnnouncementAutoSlide() {
    _announcementTimer?.cancel();

    if (_announcements.length <= 1) {
      return;
    }

    _announcementTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted ||
          !_announcementPageController.hasClients ||
          _announcements.isEmpty) {
        return;
      }

      int nextIndex = _currentAnnouncementIndex + 1;

      if (nextIndex >= _announcements.length) {
        nextIndex = 0;
      }

      _announcementPageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _announcementTimer?.cancel();
    _announcementPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
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
          child: RefreshIndicator(
            onRefresh: _refreshPage,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildAnnouncement(context),
                  _buildServiceMenu(context),
                  _buildQueueStatus(context),
                  const SizedBox(height: 20),
                ],
              ),
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
          Image.asset(
            'assets/images/hero.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.1),
          ),

          Container(color: const Color(0x993AA7F5)),

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

          // Logo dan deskripsi aplikasi.
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
                    padding: EdgeInsets.only(top: 18),
                    child: Text(
                      'Aplikasi untuk merespons permintaan '
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
  // PENGUMUMAN
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
          // Judul pengumuman dan tombol Lihat Semua.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pengumuman',
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
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AnnouncementPage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'Lihat Semua',
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

          // Saat pengumuman sedang dimuat.
          if (_isLoadingAnnouncement)
            Container(
              width: double.infinity,
              height: 145,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFB9E9FF), Color(0xFFEAF8FF)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF90D1F7), width: 0.8),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          // Saat gagal mengambil pengumuman.
          else if (_announcementLoadError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF90D1F7), width: 0.8),
              ),
              child: const Text(
                'Pengumuman gagal dimuat. '
                'Tarik halaman ke bawah untuk mencoba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            )
          // Saat belum ada pengumuman.
          else if (_announcements.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF90D1F7), width: 0.8),
              ),
              child: const Text(
                'Belum ada pengumuman.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF555555), fontSize: 10.5),
              ),
            )
          // Daftar pengumuman dalam carousel.
          else
            Column(
              children: [
                SizedBox(
                  height: 145,
                  child: PageView.builder(
                    controller: _announcementPageController,
                    itemCount: _announcements.length,

                    onPageChanged: (int index) {
                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        _currentAnnouncementIndex = index;
                      });
                    },

                    itemBuilder: (BuildContext context, int index) {
                      final AnnouncementData announcement =
                          _announcements[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),

                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) {
                                    return AnnouncementDetailPage(
                                      announcement: announcement,
                                    );
                                  },
                                ),
                              );
                            },

                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                11,
                                10,
                                10,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFB9E9FF),
                                    Color(0xFFEAF8FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF90D1F7),
                                  width: 0.8,
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announcement.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      letterSpacing: 0.2,
                                      color: Color(0xFF135F91),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 9),

                                  Expanded(
                                    child: ClipRect(
                                      child: SingleChildScrollView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        child: HtmlWidget(
                                          announcement.content,
                                          renderMode: RenderMode.column,
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            color: Color(0xFF202020),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    announcement.formattedDate,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF168DE2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indikator halaman pengumuman.
                if (_announcements.length > 1) ...[
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_announcements.length, (int index) {
                      final bool isActive = index == _currentAnnouncementIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 15 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF168DE2)
                              : const Color(0xFFB8D7EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // =========================================================
  // MENU UTAMA: AKADEMIK, ULT, PENGADUAN
  // =========================================================

  Widget _buildServiceMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Column(
        children: [
          _HomeServiceTile(
            title: 'Akademik',
            description: 'Layanan akademik untuk mahasiswa.',
            icon: Icons.school_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AkademikPage()),
              );
            },
          ),

          const SizedBox(height: 10),

          _HomeServiceTile(
            title: 'ULT',
            description: 'Unit Layanan Terpadu. Ambil nomor antrean layanan.',
            icon: Icons.confirmation_number_rounded,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const UltPage()));
            },
          ),

          const SizedBox(height: 10),

          _HomeServiceTile(
            title: 'Pengaduan',
            description: 'Laporkan kendala layanan atau fasilitas kampus.',
            icon: Icons.campaign_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PengaduanPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CEK STATUS
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
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CekStatusPage()),
            );
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
                    'Cek Status',
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
}

// =========================================================
// KARTU LAYANAN UTAMA
// =========================================================

class _HomeServiceTile extends StatelessWidget {
  const _HomeServiceTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD6E9F7), width: 0.8),
      ),

      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF168DE2), size: 28),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF3AA7F5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
