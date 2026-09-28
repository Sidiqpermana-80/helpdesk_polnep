import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'website_form_page.dart';

class WebsitePage extends StatefulWidget {
  const WebsitePage({super.key});

  @override
  State<WebsitePage> createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  String? _selectedWebsite;

  List<String> _websites = <String>[];

  bool _isLoadingWebsites = true;

  bool _hasWebsiteLoadError = false;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadWebsites();
  }

  // =========================================================
  // LOAD WEBSITE DARI API
  // =========================================================

  Future<void> _loadWebsites() async {
    if (mounted) {
      setState(() {
        _isLoadingWebsites = true;
        _hasWebsiteLoadError = false;
      });
    }

    try {
      final http.Response response = await http
          .get(Uri.parse(ApiConfig.websiteList))
          .timeout(const Duration(seconds: 20));

      debugPrint('WEBSITE STATUS: ${response.statusCode}');

      debugPrint('WEBSITE RESPONSE: ${response.body}');

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw const FormatException('Data website tidak valid.');
      }

      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        throw const FormatException('Daftar website tidak valid.');
      }

      final List<String> websites = rawData
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> item) =>
                item['option_label']?.toString().trim() ?? '',
          )
          .where((String value) => value.isNotEmpty)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _websites = websites;
        _isLoadingWebsites = false;
        _hasWebsiteLoadError = false;
      });
    } on TimeoutException {
      debugPrint('LOAD WEBSITE ERROR: TimeoutException');

      if (!mounted) {
        return;
      }

      setState(() {
        _websites = <String>[];
        _isLoadingWebsites = false;
        _hasWebsiteLoadError = true;
      });
    } catch (e) {
      debugPrint('LOAD WEBSITE ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _websites = <String>[];
        _isLoadingWebsites = false;
        _hasWebsiteLoadError = true;
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

          child: Column(
            children: [
              // ===============================================
              // HEADER
              // ===============================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 5),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,

                          constraints: const BoxConstraints(),

                          tooltip: 'Kembali',

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
                          'Layanan Website',

                          style: TextStyle(
                            color: Color(0xFF111111),

                            fontSize: 16,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 21),

                    // ===========================================
                    // LOGO / HERO
                    // ===========================================
                    SizedBox(
                      width: double.infinity,

                      height: 112,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),

                              child: Text(
                                'Pilih Website dan\n'
                                'jenis kendala yang\n'
                                'ingin anda\n'
                                'keluhkan',

                                style: TextStyle(
                                  color: Color(0xFF111111),

                                  fontSize: 20,

                                  height: 1.05,

                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 145,

                            height: 105,

                            child: Image.asset(
                              'assets/images/web.png',

                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Padding(
                      padding: EdgeInsets.only(left: 8),

                      child: Text(
                        'Website dan portal resmi di lingkungan '
                        'Politeknik Negeri Pontianak.',

                        style: TextStyle(
                          color: Color(0xFF333333),

                          fontSize: 9.5,

                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // ===============================================
              // DAFTAR WEBSITE
              // ===============================================
              Expanded(child: _buildWebsiteContent()),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // WEBSITE CONTENT
  // =========================================================

  Widget _buildWebsiteContent() {
    // =========================================================
    // LOADING
    // =========================================================

    if (_isLoadingWebsites) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,

          color: Color(0xFF7C8CF5),
        ),
      );
    }

    // =========================================================
    // ERROR
    // =========================================================

    if (_hasWebsiteLoadError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                Icons.cloud_off_rounded,

                size: 42,

                color: Color(0xFF7C8CF5),
              ),

              const SizedBox(height: 10),

              const Text(
                'Daftar website gagal dimuat',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Color(0xFF202020),

                  fontSize: 11,

                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Periksa koneksi ke server, lalu coba kembali.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Color(0xFF666666),

                  fontSize: 9.5,

                  height: 1.3,
                ),
              ),

              const SizedBox(height: 13),

              SizedBox(
                width: 100,
                height: 36,

                child: ElevatedButton(
                  onPressed: _loadWebsites,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C8CF5),

                    foregroundColor: Colors.white,

                    elevation: 0,

                    padding: EdgeInsets.zero,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),

                  child: const Text(
                    'Coba Lagi',

                    style: TextStyle(
                      fontSize: 9.5,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================
    // DATA KOSONG
    // =========================================================

    if (_websites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(Icons.language_rounded, size: 42, color: Color(0xFF8793FF)),

              SizedBox(height: 10),

              Text(
                'Belum ada website yang tersedia.',

                textAlign: TextAlign.center,

                style: TextStyle(color: Color(0xFF555555), fontSize: 10.5),
              ),
            ],
          ),
        ),
      );
    }

    // =========================================================
    // LIST WEBSITE
    // =========================================================

    return RefreshIndicator(
      onRefresh: _loadWebsites,

      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),

        itemCount: _websites.length,

        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 4);
        },

        itemBuilder: (BuildContext context, int index) {
          final String website = _websites[index];

          final bool selected = _selectedWebsite == website;

          return _buildWebsiteItem(
            website: website,

            selected: selected,

            onTap: () {
              setState(() {
                _selectedWebsite = website;
              });

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return WebsiteFormPage(websiteName: website);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =========================================================
  // ITEM WEBSITE
  // =========================================================

  Widget _buildWebsiteItem({
    required String website,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(8),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),

          curve: Curves.easeInOut,

          width: double.infinity,

          constraints: const BoxConstraints(minHeight: 45),

          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

          decoration: BoxDecoration(
            color: selected ? const Color(0xFF8EEB91) : Colors.white,

            borderRadius: BorderRadius.circular(8),

            border: Border.all(
              color: selected
                  ? const Color(0xFF54C85A)
                  : const Color(0xFF909090),

              width: selected ? 1.2 : 0.8,
            ),

            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),

                blurRadius: 2,

                offset: Offset(0, 1),
              ),
            ],
          ),

          child: Row(
            children: [
              Expanded(
                child: Text(
                  website,

                  style: TextStyle(
                    color: const Color(0xFF202020),

                    fontSize: 11,

                    fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.arrow_forward_ios_rounded,

                size: 16,

                color: selected
                    ? const Color(0xFF45B957)
                    : const Color(0xFF8793FF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
