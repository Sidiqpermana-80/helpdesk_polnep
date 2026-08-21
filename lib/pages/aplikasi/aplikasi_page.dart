import 'package:flutter/material.dart';

import 'pilih_aplikasi_page.dart';
import 'aplikasi_form_page.dart';

class AplikasiPage extends StatefulWidget {
  const AplikasiPage({super.key});

  @override
  State<AplikasiPage> createState() => _AplikasiPageState();
}

class _AplikasiPageState extends State<AplikasiPage> {
  // =========================================================
  // PILIHAN PENGGUNA
  // =========================================================

  String? _selectedIssue;
  String? _selectedApplication;

  // =========================================================
  // JENIS KENDALA
  // =========================================================

  static const List<Map<String, String>> _issues = [
    {'title': 'Tidak Bisa Login', 'asset': 'assets/images/lock.png'},
    {'title': 'Data Tidak Sesuai', 'asset': 'assets/images/doc.png'},
    {'title': 'Error Sistem', 'asset': 'assets/images/error.png'},
    {'title': 'Permintaan Akses', 'asset': 'assets/images/key.png'},
  ];

  // =========================================================
  // APLIKASI UTAMA
  // =========================================================

  static const List<Map<String, String>> _applications = [
    {'title': 'SIAKAD Polnep', 'asset': 'assets/images/toga.png'},
    {'title': 'SIHADIR', 'asset': 'assets/images/sihadir.png'},
    {'title': 'SIHADIR Web', 'asset': 'assets/images/logopolnep-BESAR.png'},
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

          // ===================================================
          // BACKGROUND
          // ===================================================
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
            ),
          ),

          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =================================================
                // HEADER
                // =================================================
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
                      'Layanan Aplikasi',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =================================================
                // HERO
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 116,

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 6, top: 3),

                          child: Text(
                            'Pilih Aplikasi dan\n'
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
                        width: 135,
                        height: 110,

                        child: Image.asset(
                          'assets/images/settings.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // =================================================
                // JUDUL JENIS KENDALA
                // =================================================
                const Padding(
                  padding: EdgeInsets.only(left: 6),

                  child: Text(
                    'Jenis Kendala',
                    style: TextStyle(
                      color: Color(0xFF202020),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                // =================================================
                // CARD JENIS KENDALA
                // =================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(11, 14, 11, 14),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(11),

                    border: Border.all(color: const Color(0xFFD6E9F7)),
                  ),

                  child: GridView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: _issues.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.65,
                          crossAxisSpacing: 11,
                          mainAxisSpacing: 13,
                        ),

                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, String> issue = _issues[index];

                      final String title = issue['title']!;

                      final String asset = issue['asset']!;

                      final bool selected = _selectedIssue == title;

                      return _buildIssueItem(
                        title: title,
                        asset: asset,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            _selectedIssue = title;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 13),

                // =================================================
                // CARD PILIH APLIKASI
                // =================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(9, 10, 9, 8),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(11),

                    border: Border.all(color: const Color(0xFFD6E9F7)),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Pilih Aplikasi',
                        style: TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ===========================================
                      // 3 APLIKASI UTAMA
                      // ===========================================
                      ..._applications.map((Map<String, String> application) {
                        final String title = application['title']!;

                        final String asset = application['asset']!;

                        final bool selected = _selectedApplication == title;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),

                          child: _buildApplicationItem(
                            title: title,
                            asset: asset,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedApplication = title;
                              });
                            },
                          ),
                        );
                      }),

                      // ===========================================
                      // APLIKASI LAINNYA
                      // ===========================================
                      Align(
                        alignment: Alignment.centerRight,

                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),

                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return PilihAplikasiPage(
                                    selectedIssue: _selectedIssue,
                                  );
                                },
                              ),
                            );
                          },

                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 6,
                            ),

                            child: Text(
                              'Aplikasi Lainnya',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 34),

                // =================================================
                // AJUKAN PERMINTAAN
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 48,

                  child: ElevatedButton(
                    onPressed: _submitSelection,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B48FF),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Image.asset(
                          'assets/images/papperplane.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(width: 5),

                        const Text(
                          'Ajukan Permintaan',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
  // ITEM JENIS KENDALA
  // =========================================================

  Widget _buildIssueItem({
    required String title,
    required String asset,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFFEAF0FF) : Colors.transparent,

      borderRadius: BorderRadius.circular(9),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(9),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),

            border: selected
                ? Border.all(color: const Color(0xFF5368FF), width: 1.2)
                : null,
          ),

          child: Row(
            children: [
              // ===============================================
              // ICON
              // ===============================================
              Container(
                width: 38,
                height: 38,

                padding: const EdgeInsets.all(0.5),

                decoration: BoxDecoration(
                  color: _issueBackground(title),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: Image.asset(asset, fit: BoxFit.contain),
              ),

              const SizedBox(width: 10),

              // ===============================================
              // TEXT
              // ===============================================
              Expanded(
                child: Text(
                  title,

                  style: TextStyle(
                    color: const Color(0xFF202020),

                    fontSize: 9.5,

                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // WARNA BACKGROUND ICON JENIS KENDALA
  // =========================================================

  Color _issueBackground(String title) {
    switch (title) {
      case 'Tidak Bisa Login':
        return const Color(0xFF5A5CEB);

      case 'Data Tidak Sesuai':
        return const Color(0xFFC99700);

      case 'Error Sistem':
        return const Color(0xFFFFC967);

      case 'Permintaan Akses':
        return const Color(0xFF5AC26B);

      default:
        return const Color(0xFFEAEAEA);
    }
  }

  // =========================================================
  // ITEM APLIKASI
  // =========================================================

  Widget _buildApplicationItem({
    required String title,
    required String asset,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(9),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),

          width: double.infinity,

          constraints: const BoxConstraints(minHeight: 56),

          padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),

          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0F4FF) : const Color(0xFFFAFAFA),

            borderRadius: BorderRadius.circular(9),

            border: Border.all(
              color: selected
                  ? const Color(0xFF5368FF)
                  : const Color(0xFFA8A8A8),

              width: selected ? 1.4 : 0.8,
            ),
          ),

          child: Row(
            children: [
              // ===============================================
              // LOGO
              // ===============================================
              Container(
                width: 43,
                height: 43,

                alignment: Alignment.center,

                padding: const EdgeInsets.all(3),

                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3FF),

                  borderRadius: BorderRadius.circular(8),
                ),

                child: Image.asset(asset, fit: BoxFit.contain),
              ),

              const SizedBox(width: 11),

              // ===============================================
              // NAMA APLIKASI
              // ===============================================
              Expanded(
                child: Text(
                  title,

                  style: TextStyle(
                    color: const Color(0xFF202020),

                    fontSize: 11,

                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),

              // ===============================================
              // PANAH
              // ===============================================
              Icon(
                Icons.arrow_forward_ios_rounded,

                size: 16,

                color: selected
                    ? const Color(0xFF5368FF)
                    : const Color(0xFF8793FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // AJUKAN PERMINTAAN
  // =========================================================

  void _submitSelection() {
    // =========================================================
    // JENIS KENDALA
    // =========================================================

    if (_selectedIssue == null) {
      _showMessage('Silakan pilih jenis kendala terlebih dahulu.');

      return;
    }

    // =========================================================
    // APLIKASI
    // =========================================================

    if (_selectedApplication == null) {
      _showMessage('Silakan pilih aplikasi terlebih dahulu.');

      return;
    }

    // =========================================================
    // MASUK KE FORM
    // =========================================================

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AplikasiFormPage(
            issueType: _selectedIssue!,

            applicationName: _selectedApplication!,
          );
        },
      ),
    );
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
