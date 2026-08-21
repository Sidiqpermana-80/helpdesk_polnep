import 'package:flutter/material.dart';

class WebsiteSuccessPage extends StatelessWidget {
  const WebsiteSuccessPage({
    required this.requestNumber,
    required this.fullName,
    required this.identifierValue,
    required this.websiteName,
    required this.issueType,
    required this.submittedAt,
    super.key,
  });

  final String requestNumber;
  final String fullName;
  final String identifierValue;
  final String websiteName;
  final String issueType;
  final DateTime submittedAt;

  // =========================================================
  // FORMAT JENIS KENDALA
  // =========================================================

  String get formattedIssueType {
    switch (issueType) {
      case 'lainnya':
      case 'Lainnya':
        return 'Lainnya';

      case 'tidak_bisa_login':
      case 'Tidak Bisa Login':
        return 'Tidak Bisa Login';

      case 'error_sistem':
      case 'Error Sistem':
        return 'Error Sistem';

      case 'data_tidak_sesuai':
      case 'Data Tidak Sesuai':
        return 'Data Tidak Sesuai';

      case 'permintaan_akses':
      case 'Permintaan Akses':
        return 'Permintaan Akses';

      default:
        return issueType;
    }
  }

  // =========================================================
  // FORMAT TANGGAL
  // =========================================================

  String get formattedDate {
    const List<String> months = [
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

    return '${submittedAt.day} '
        '${months[submittedAt.month - 1]} '
        '${submittedAt.year}';
  }

  // =========================================================
  // LOGO JENIS KENDALA
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

      case 'lainnya':
      case 'Lainnya':
      default:
        return 'assets/images/doc.png';
    }
  }

  // =========================================================
  // BACKGROUND ICON JENIS KENDALA
  // =========================================================

  Color get issueBackground {
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
        return const Color(0xFFD6EBF8);
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

        leadingWidth: 44,

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
            colors: [
              Color(0xFFF0F9FF),
              Color(0xFFD7EEFF),
              Color(0xFFB9E1FF),
              Color(0xFF39A8F4),
            ],
            stops: [0.00, 0.22, 0.52, 1.00],
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(7, 7, 7, 34),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // JUDUL BAGIAN
              // =================================================
              const Padding(
                padding: EdgeInsets.only(left: 1),
                child: Text(
                  'Layanan Website',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              const Padding(
                padding: EdgeInsets.only(left: 1),
                child: Text(
                  'Home / Website',
                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =================================================
              // CARD UTAMA
              // =================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(10, 18, 10, 17),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(11),

                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // =============================================
                    // SUCCESS ICON
                    // =============================================
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00D51D),
                      size: 78,
                    ),

                    const SizedBox(height: 8),

                    // =============================================
                    // SUCCESS TITLE
                    // =============================================
                    const Text(
                      'Permintaan Berhasil Dikirim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 9),

                    const Text(
                      'Laporan kendala Website Anda telah kami terima '
                      'dan akan segera diproses oleh Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 9.5,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 17),

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
                          // =========================================
                          // JUDUL DETAIL
                          // =========================================
                          const Text(
                            'Detail Pengajuan',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 9),

                          const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFF707070),
                          ),

                          const SizedBox(height: 11),

                          // =========================================
                          // NAMA
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/pp.png',
                            label: 'Nama Pengguna',
                            value: fullName,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 6),

                          // =========================================
                          // NIM/NIP
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/book.png',
                            label: 'NIM / NIP',
                            value: identifierValue,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 6),

                          // =========================================
                          // WEBSITE
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/weblink.png',
                            label: 'Website',
                            value: websiteName,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 6),

                          // =========================================
                          // JENIS KENDALA
                          // =========================================
                          _buildDetailCard(
                            asset: issueAsset,
                            label: 'Jenis Kendala',
                            value: formattedIssueType,
                            iconBackground: issueBackground,
                            compactIcon: true,
                          ),

                          const SizedBox(height: 6),

                          // =========================================
                          // TANGGAL
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/kalender.png',
                            label: 'Tanggal',
                            value: formattedDate,
                            iconBackground: const Color(0xFF3E64C7),
                          ),

                          const SizedBox(height: 6),

                          // =========================================
                          // TIKET
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

              const SizedBox(height: 27),

              // =================================================
              // BUTTON BAWAH
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // ===============================================
                  // KEMBALI KE BERANDA
                  // ===============================================
                  SizedBox(
                    width: 105,
                    height: 42,

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

                        padding: const EdgeInsets.symmetric(horizontal: 10),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),

                      child: const Text(
                        'Kembali Ke\nBeranda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // ===============================================
                  // BUAT PERTANYAAN LAGI
                  // ===============================================
                  SizedBox(
                    width: 116,
                    height: 42,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58C761),

                        foregroundColor: Colors.white,

                        elevation: 0,

                        padding: const EdgeInsets.symmetric(horizontal: 7),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),

                      child: const Text(
                        'Buat Pertanyaan Lagi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CARD DETAIL
  // =========================================================

  Widget _buildDetailCard({
    required String asset,
    required String label,
    required String value,
    required Color iconBackground,
    bool compactIcon = false,
  }) {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(minHeight: 62),

      padding: const EdgeInsets.fromLTRB(8, 6, 9, 6),

      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),

        borderRadius: BorderRadius.circular(9),

        border: Border.all(color: const Color(0xFF969696), width: 0.7),
      ),

      child: Row(
        children: [
          // ===============================================
          // ICON
          // ===============================================
          Container(
            width: 50,
            height: 50,

            alignment: Alignment.center,

            padding: EdgeInsets.all(compactIcon ? 10 : 6),

            decoration: BoxDecoration(
              color: iconBackground,

              borderRadius: BorderRadius.circular(10),
            ),

            child: Image.asset(
              asset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          // ===============================================
          // TEXT
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
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 11,
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
