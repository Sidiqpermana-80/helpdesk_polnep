import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

// ===========================================================
// MODEL
// ===========================================================

class AnnouncementData {
  const AnnouncementData({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
  });

  final int id;
  final String title;
  final String content;
  final DateTime? publishedAt;

  factory AnnouncementData.fromJson(Map<String, dynamic> json) {
    return AnnouncementData(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString().trim() ?? '',
      content: json['content']?.toString().trim() ?? '',
      publishedAt: _parseDate(json['published_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    final String text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text)?.toLocal();
  }

  String get formattedDate {
    if (publishedAt == null) {
      return '-';
    }

    const List<String> months = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final DateTime date = publishedAt!;

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}

// ===========================================================
// LIST ANNOUNCEMENT
// ===========================================================

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  List<AnnouncementData> _announcements = <AnnouncementData>[];

  bool _isLoading = true;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();

    _loadAnnouncements();
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> _loadAnnouncements() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = false;
      });
    }

    try {
      final http.Response response = await http
          .get(
            Uri.parse(ApiConfig.announcements),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));

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

        _isLoading = false;

        _loadError = false;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = true;
      });
    } catch (e) {
      debugPrint('ANNOUNCEMENT ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = true;
      });
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
            ),
          ),

          child: RefreshIndicator(
            onRefresh: _loadAnnouncements,

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),

              padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),

              children: [
                _buildHeader(),

                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.only(left: 31),
                  child: Text(
                    'Informasi terbaru Helpdesk POLNEP',
                    style: TextStyle(color: Color(0xFF777777), fontSize: 10),
                  ),
                ),

                const SizedBox(height: 24),

                if (_isLoading)
                  const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_loadError)
                  _buildError()
                else if (_announcements.isEmpty)
                  _buildEmpty()
                else
                  for (int i = 0; i < _announcements.length; i++) ...[
                    _buildCard(_announcements[i]),
                    if (i != _announcements.length - 1)
                      const SizedBox(height: 10),
                  ],
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
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),

          onPressed: () {
            Navigator.of(context).pop();
          },

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
            color: Color(0xFF111111),
          ),
        ),

        const SizedBox(width: 10),

        const Text(
          'Pengumuman',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CARD
  // =========================================================

  Widget _buildCard(AnnouncementData announcement) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(10),

        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return AnnouncementDetailPage(announcement: announcement);
              },
            ),
          );
        },

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(10),

            border: Border.all(color: const Color(0xFFD6E9F7)),

            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                announcement.title,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Color(0xFF135F91),
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 70,

                child: ClipRect(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),

                    child: _buildHtml(announcement.content, preview: true),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      announcement.formattedDate,

                      style: const TextStyle(
                        color: Color(0xFF168DE2),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Text(
                    'Baca Selengkapnya',
                    style: TextStyle(
                      color: Color(0xFF168DE2),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: Color(0xFF168DE2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HTML RENDERER
  // =========================================================

  Widget _buildHtml(String html, {required bool preview}) {
    return HtmlWidget(
      html,

      renderMode: RenderMode.column,

      textStyle: TextStyle(
        color: const Color(0xFF303030),

        fontSize: preview ? 11 : 14,

        height: preview ? 1.35 : 1.5,
      ),

      // =====================================================
      // PERTAHANKAN ENTER / BARIS KOSONG
      // =====================================================
      customWidgetBuilder: (element) {
        final String tag = element.localName ?? '';

        final bool explicitBlank = element.attributes['data-blank-line'] == '1';

        final bool oldBlank =
            (tag == 'p' || tag == 'div') &&
            element.text.replaceAll('\u00A0', '').trim().isEmpty;

        if (explicitBlank || oldBlank) {
          return SizedBox(height: preview ? 6 : 22);
        }

        return null;
      },

      // =====================================================
      // RAPIKAN PARAGRAF & NUMBERING
      // =====================================================
      customStylesBuilder: (element) {
        final String tag = element.localName ?? '';

        if (tag == 'body') {
          return {'margin': '0', 'padding': '0'};
        }

        if (tag == 'p') {
          return {
            'margin': preview ? '0 0 4px 0' : '0 0 10px 0',
            'padding': '0',
          };
        }

        if (tag == 'div') {
          return {'margin': preview ? '0 0 4px 0' : '0 0 8px 0'};
        }

        // NUMBERING
        if (tag == 'ol') {
          return {
            'margin': preview ? '2px 0 4px 0' : '8px 0 12px 0',

            'padding-left': preview ? '20px' : '26px',
          };
        }

        // BULLET
        if (tag == 'ul') {
          return {
            'margin': preview ? '2px 0 4px 0' : '8px 0 12px 0',

            'padding-left': preview ? '20px' : '26px',
          };
        }

        // ITEM LIST
        if (tag == 'li') {
          return {
            'margin-bottom': preview ? '3px' : '7px',

            'padding-left': '3px',

            /*
             * Numbering dipaksa
             * rata kiri agar angka
             * dan isi tidak renggang
             * akibat justify.
             */
            'text-align': 'left',
          };
        }

        return null;
      },
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: Color(0xFF777777),
          ),

          const SizedBox(height: 10),

          const Text('Pengumuman gagal dimuat.'),

          TextButton.icon(
            onPressed: _loadAnnouncements,

            icon: const Icon(Icons.refresh),

            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(35),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),
      ),

      child: const Column(
        children: [
          Icon(Icons.campaign_outlined, size: 44, color: Color(0xFF168DE2)),

          SizedBox(height: 10),

          Text(
            'Belum Ada Pengumuman',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// DETAIL
// ===========================================================

class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({required this.announcement, super.key});

  final AnnouncementData announcement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
            ),
          ),

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(14, 14, 14, 35),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,

                      constraints: const BoxConstraints(),

                      onPressed: () {
                        Navigator.of(context).pop();
                      },

                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 21,
                        color: Color(0xFF111111),
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'Detail Pengumuman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(16, 17, 16, 22),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(10),

                    border: Border.all(color: const Color(0xFFD6E9F7)),

                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        announcement.title,

                        style: const TextStyle(
                          color: Color(0xFF135F91),
                          fontSize: 18,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 15,
                            color: Color(0xFF168DE2),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            announcement.formattedDate,
                            style: const TextStyle(
                              color: Color(0xFF168DE2),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Divider(),

                      const SizedBox(height: 15),

                      _buildDetailHtml(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // DETAIL HTML
  // =========================================================

  Widget _buildDetailHtml() {
    return HtmlWidget(
      announcement.content,

      renderMode: RenderMode.column,

      textStyle: const TextStyle(
        color: Color(0xFF303030),

        // FONT DEFAULT
        fontSize: 12.5,

        height: 1.5,
      ),

      // ENTER KOSONG
      customWidgetBuilder: (element) {
        final String tag = element.localName ?? '';

        final bool explicitBlank = element.attributes['data-blank-line'] == '1';

        final bool emptyBlock =
            (tag == 'p' || tag == 'div') &&
            element.text.replaceAll('\u00A0', '').trim().isEmpty;

        if (explicitBlank || emptyBlock) {
          return const SizedBox(height: 22);
        }

        return null;
      },

      customStylesBuilder: (element) {
        final String tag = element.localName ?? '';

        if (tag == 'body') {
          return {'margin': '0', 'padding': '0'};
        }

        if (tag == 'p') {
          return {'margin': '0 0 11px 0', 'padding': '0'};
        }

        if (tag == 'div') {
          return {'margin': '0 0 8px 0'};
        }

        // ==========================================
        // NUMBERING
        // ==========================================

        if (tag == 'ol') {
          return {'padding-left': '27px', 'margin': '8px 0 13px 0'};
        }

        // ==========================================
        // BULLET
        // ==========================================

        if (tag == 'ul') {
          return {'padding-left': '27px', 'margin': '8px 0 13px 0'};
        }

        // ==========================================
        // LIST ITEM
        // ==========================================

        if (tag == 'li') {
          return {
            'padding-left': '3px',

            'margin-bottom': '7px',

            // supaya nomor rapi
            'text-align': 'left',
          };
        }

        return null;
      },
    );
  }
}
