import 'package:flutter/material.dart';

import 'website_form_page.dart';

class WebsitePage extends StatefulWidget {
  const WebsitePage({super.key});

  @override
  State<WebsitePage> createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  // =========================================================
  // WEBSITE YANG TERAKHIR DIPILIH
  // =========================================================

  String? _selectedWebsite;

  // =========================================================
  // DAFTAR WEBSITE
  // =========================================================

  static const List<String> _websites = [
    'Web Jurusan Administrasi Bisnis',
    'Web IBIPAC Administrasi Bisnis',
    'Web Jurusan Teknik Arsitektur',
    'Web Jurusan IKP',
    'Web Jurusan Teknologi Pertanian',
    'Web Jurusan Akuntansi',
    'Web PDD Polnep Kapuas Hulu',
    'Web Jurusan Teknik Elektro',
    'Web Jurusan Teknik Mesin',
    'Web Jurusan Teknik Sipil',
    'Web PSDKU Polnep Sanggau',
    'Web PSDKU Polnep Sukamara',
    'Website UPA TIK',
    'Website Resmi Polnep',
  ];

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
              // =================================================
              // HEADER + HERO
              // =================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 5),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =============================================
                    // HEADER
                    // =============================================
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

                    // =============================================
                    // HERO
                    // =============================================
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

              // =================================================
              // LIST WEBSITE
              // =================================================
              Expanded(
                child: ListView.separated(
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
                        // =======================================
                        // SIMPAN PILIHAN
                        // =======================================

                        setState(() {
                          _selectedWebsite = website;
                        });

                        // =======================================
                        // MASUK KE FORM WEBSITE
                        // =======================================

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
              ),
            ],
          ),
        ),
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
            // ===============================================
            // HIJAU JIKA TERAKHIR DIPILIH
            // ===============================================
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
