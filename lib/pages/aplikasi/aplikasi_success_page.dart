import 'package:flutter/material.dart';

class AplikasiSuccessPage extends StatelessWidget {
  const AplikasiSuccessPage({
    required this.requestNumber,
    required this.fullName,
    required this.identifierValue,
    required this.applicationName,
    required this.issueType,
    required this.submittedAt,
    super.key,
  });

  final String requestNumber;
  final String fullName;
  final String identifierValue;
  final String applicationName;
  final String issueType;
  final DateTime submittedAt;

  // =========================================================
  // FORMAT JENIS KENDALA
  // =========================================================

  String get formattedIssueType {
    switch (issueType) {
      case 'tidak_bisa_login':
      case 'Tidak Bisa Login':
        return 'Tidak Bisa Login';

      case 'data_tidak_sesuai':
      case 'Data Tidak Sesuai':
        return 'Data Tidak Sesuai';

      case 'error_sistem':
      case 'Error Sistem':
        return 'Error Sistem';

      case 'permintaan_akses':
      case 'Permintaan Akses':
        return 'Permintaan Akses';

      default:
        return issueType;
    }
  }

  // =========================================================
  // FORMAT TANGGAL INDONESIA
  // =========================================================

  String get formattedDate {
    const List<String> monthNames = [
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

    final String day = submittedAt.day.toString().padLeft(2, '0');

    final String month = monthNames[submittedAt.month - 1];

    final String year = submittedAt.year.toString();

    return '$day $month $year';
  }

  // =========================================================
  // LOGO APLIKASI
  //
  // Logo otomatis berubah berdasarkan aplikasi yang dipilih.
  // =========================================================

  String get applicationAsset {
    switch (applicationName) {
      case 'SIAKAD Polnep':
        return 'assets/images/toga.png';

      case 'SIHADIR':
        return 'assets/images/sihadir.png';

      case 'SIHADIR Web':
        return 'assets/images/logopolnep-BESAR.png';

      case 'SIAKAD SEMIVA Polnep':
        return 'assets/images/semiva.png';

      case 'Sistem Admin Jurusan Polnep':
        return 'assets/images/bank.png';

      case 'Sistem Reservasi Polnep':
        return 'assets/images/date.png';

      case 'HELPDESK Polnep':
        return 'assets/images/helpdesk.png';

      case 'Polnep Link':
        return 'assets/images/weblink.png';

      case 'SPMB Polnep':
        return 'assets/images/spmb.png';

      case 'Sihadir Kepegawaian':
        return 'assets/images/sihadirmap.png';

      case 'SIHADIR Android':
        return 'assets/images/logopolnep-BESAR.png';

      default:
        return 'assets/images/app.jpeg';
    }
  }

  // =========================================================
  // LOGO JENIS KENDALA
  //
  // Logo otomatis berubah berdasarkan jenis kendala.
  // =========================================================

  String get issueAsset {
    switch (issueType) {
      case 'tidak_bisa_login':
      case 'Tidak Bisa Login':
        return 'assets/images/lock.png';

      case 'data_tidak_sesuai':
      case 'Data Tidak Sesuai':
        return 'assets/images/doc.png';

      case 'error_sistem':
      case 'Error Sistem':
        return 'assets/images/error.png';

      case 'permintaan_akses':
      case 'Permintaan Akses':
        return 'assets/images/key.png';

      default:
        return 'assets/images/error.png';
    }
  }

  // =========================================================
  // WARNA BACKGROUND LOGO JENIS KENDALA
  // =========================================================

  Color get issueBackgroundColor {
    switch (issueType) {
      case 'tidak_bisa_login':
      case 'Tidak Bisa Login':
        return const Color(0xFF5A5CEB);

      case 'data_tidak_sesuai':
      case 'Data Tidak Sesuai':
        return const Color(0xFFC99700);

      case 'error_sistem':
      case 'Error Sistem':
        return const Color(0xFFFFC967);

      case 'permintaan_akses':
      case 'Permintaan Akses':
        return const Color(0xFF58C761);

      default:
        return const Color(0xFFE7F3FF);
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      // =======================================================
      // APP BAR
      // =======================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 45,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF202020),
            size: 20,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Permintaan Berhasil',
          style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // =======================================================
      // BODY
      // =======================================================
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
            stops: [0.00, 0.48, 1.00],
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(7, 5, 7, 28),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // JUDUL HALAMAN
              // =================================================
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Text(
                  'Pilihan Aplikasi',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Text(
                  'Home / Aplikasi',
                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // CARD SUCCESS
              // =================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(8, 15, 8, 17),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(10),

                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // =============================================
                    // ICON SUKSES
                    // =============================================
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00D51D),
                      size: 82,
                    ),

                    const SizedBox(height: 5),

                    // =============================================
                    // JUDUL SUKSES
                    // =============================================
                    const Text(
                      'Permintaan Berhasil Dikirim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Laporan kendala Aplikasi anda telah kami terima\n'
                      'dan akan diproses oleh Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 9.5,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =============================================
                    // DETAIL PENGAJUAN
                    // =============================================
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(8, 11, 8, 12),

                      decoration: BoxDecoration(
                        color: const Color(0xFFDCDCDC),

                        borderRadius: BorderRadius.circular(5),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Detail Pengajuan',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFF707070),
                          ),

                          const SizedBox(height: 10),

                          // =========================================
                          // NAMA PENGGUNA
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/pp.png',
                            label: 'Nama Pengguna',
                            value: fullName,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 5),

                          // =========================================
                          // NIM / NIP
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/book.png',
                            label: 'NIM / NIP',
                            value: identifierValue,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 5),

                          // =========================================
                          // APLIKASI
                          //
                          // LOGO BERUBAH OTOMATIS
                          // =========================================
                          _buildDetailCard(
                            asset: applicationAsset,
                            label: 'Aplikasi',
                            value: applicationName,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 5),

                          // =========================================
                          // JENIS KENDALA
                          //
                          // LOGO BERUBAH OTOMATIS
                          // =========================================
                          _buildDetailCard(
                            asset: issueAsset,
                            label: 'Jenis Kendala',
                            value: formattedIssueType,
                            iconBackground: issueBackgroundColor,
                            issueIcon: true,
                          ),

                          const SizedBox(height: 5),

                          // =========================================
                          // TANGGAL
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/kalender.png',
                            label: 'Tanggal',
                            value: formattedDate,
                            iconBackground: const Color(0xFF3E64C7),
                          ),

                          const SizedBox(height: 5),

                          // =========================================
                          // NO TIKET
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/ticket.png',
                            label: 'No. Tiket',
                            value: requestNumber,
                            iconBackground: const Color(0xFF41B64E),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // BUTTON
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // ===============================================
                  // KEMBALI KE BERANDA
                  // ===============================================
                  SizedBox(
                    width: 115,
                    height: 40,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((Route<dynamic> route) => route.isFirst);
                      },

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
                        'Kembali Ke Beranda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 28),

                  // ===============================================
                  // BUAT PERTANYAAN LAGI
                  // ===============================================
                  SizedBox(
                    width: 125,
                    height: 40,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58C761),

                        foregroundColor: Colors.white,

                        elevation: 0,

                        padding: EdgeInsets.zero,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),

                      child: const Text(
                        'Buat Pertanyaan Lagi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
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
  // DETAIL CARD
  // =========================================================

  Widget _buildDetailCard({
    required String asset,
    required String label,
    required String value,
    required Color iconBackground,
    bool issueIcon = false,
  }) {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(minHeight: 54),

      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),

      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),

        borderRadius: BorderRadius.circular(9),

        border: Border.all(color: const Color(0xFF969696), width: 0.7),
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

            padding: EdgeInsets.all(issueIcon ? 9 : 5),

            decoration: BoxDecoration(
              color: iconBackground,

              borderRadius: BorderRadius.circular(9),
            ),

            child: Image.asset(
              asset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 11),

          // ===============================================
          // LABEL DAN VALUE
          // ===============================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: const TextStyle(
                    color: Color(0xFF1762B0),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
