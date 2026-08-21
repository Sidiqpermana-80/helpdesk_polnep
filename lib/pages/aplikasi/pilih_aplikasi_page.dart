import 'package:flutter/material.dart';
import 'aplikasi_form_page.dart';

class PilihAplikasiPage extends StatefulWidget {
  const PilihAplikasiPage({this.selectedIssue, super.key});

  final String? selectedIssue;

  @override
  State<PilihAplikasiPage> createState() => _PilihAplikasiPageState();
}

class _PilihAplikasiPageState extends State<PilihAplikasiPage> {
  String? _selectedApplication;

  // =========================================================
  // DAFTAR APLIKASI
  // =========================================================

  static const List<Map<String, String>> _applications = [
    {'title': 'SIAKAD Polnep', 'asset': 'assets/images/toga.png'},
    {'title': 'SIHADIR', 'asset': 'assets/images/sihadir.png'},
    {'title': 'SIHADIR Web', 'asset': 'assets/images/logopolnep-BESAR.png'},
    {'title': 'SIAKAD SEMIVA Polnep', 'asset': 'assets/images/semiva.png'},
    {'title': 'Sistem Admin Jurusan Polnep', 'asset': 'assets/images/bank.png'},
    {'title': 'Sistem Reservasi Polnep', 'asset': 'assets/images/date.png'},
    {'title': 'HELPDESK Polnep', 'asset': 'assets/images/helpdesk.png'},
    {'title': 'Polnep Link', 'asset': 'assets/images/weblink.png'},
    {'title': 'SPMB Polnep', 'asset': 'assets/images/spmb.png'},
    {'title': 'Sihadir Kepegawaian', 'asset': 'assets/images/sihadirmap.png'},
    {'title': 'SIHADIR Android', 'asset': 'assets/images/logopolnep-BESAR.png'},
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
          // BACKGROUND SAMA DENGAN HALAMAN LAIN
          // ===================================================
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
              // HEADER
              // =================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Row(
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
                      'Pilih Aplikasi',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // =================================================
              // DAFTAR APLIKASI
              // =================================================
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                  itemCount: _applications.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 5);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, String> application =
                        _applications[index];

                    final String title = application['title']!;

                    final String asset = application['asset']!;

                    final bool selected = _selectedApplication == title;

                    return _buildApplicationItem(
                      title: title,
                      asset: asset,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _selectedApplication = title;
                        });
                      },
                    );
                  },
                ),
              ),

              // =================================================
              // BUTTON AJUKAN
              // =================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: SizedBox(
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
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(width: 10),

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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CARD APLIKASI
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

          padding: const EdgeInsets.fromLTRB(7, 5, 9, 5),

          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0F4FF) : Colors.white,

            borderRadius: BorderRadius.circular(9),

            border: Border.all(
              color: selected
                  ? const Color(0xFF5368FF)
                  : const Color(0xFF929292),

              width: selected ? 1.5 : 0.8,
            ),
          ),

          child: Row(
            children: [
              // ===============================================
              // LOGO
              // ===============================================
              Container(
                width: 44,
                height: 44,

                alignment: Alignment.center,

                padding: const EdgeInsets.all(3),

                decoration: BoxDecoration(
                  color: const Color(0xFFDDF1FF),

                  borderRadius: BorderRadius.circular(9),
                ),

                child: Image.asset(asset, fit: BoxFit.contain),
              ),

              const SizedBox(width: 11),

              // ===============================================
              // NAMA
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
                    ? const Color(0xFF4B48FF)
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

    if (widget.selectedIssue == null) {
      _showMessage(
        'Jenis kendala belum dipilih. '
        'Silakan kembali dan pilih jenis kendala.',
      );

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
    // MASUK FORM
    // =========================================================

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return AplikasiFormPage(
            issueType: widget.selectedIssue!,

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
