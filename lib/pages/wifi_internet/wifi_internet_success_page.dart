import 'package:flutter/material.dart';

class WifiInternetSuccessPage extends StatelessWidget {
  const WifiInternetSuccessPage({
    required this.requestNumber,
    required this.fullName,
    required this.identifierValue,
    required this.buildingName,
    required this.roomName,
    required this.status,
    required this.estimatedResponse,
    required this.submittedAt,
    super.key,
  });

  final String requestNumber;
  final String fullName;
  final String identifierValue;
  final String buildingName;
  final String roomName;
  final String status;
  final String estimatedResponse;
  final DateTime submittedAt;

  // =========================================================
  // FORMAT TANGGAL INDONESIA
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
          'Laporan Berhasil',
          style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 15.5,
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

        // BACKGROUND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
            stops: [0.00, 0.48, 1.00],
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(7, 5, 7, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // JUDUL BAGIAN
              // =================================================
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Text(
                  'Keluhan WIFI / Internet',
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
                  'Home / WIFI / Internet',
                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // CARD UTAMA
              // =================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(8, 14, 8, 15),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(10),

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
                    // ICON SUKSES
                    // =============================================
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00D51D),
                      size: 80,
                    ),

                    const SizedBox(height: 5),

                    // =============================================
                    // JUDUL SUKSES
                    // =============================================
                    const Text(
                      'Laporan Berhasil Dikirim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17),
                      child: Text(
                        'Laporan Kendala WIFI / Internet anda telah kami '
                        'terima dan akan ditindaklanjuti oleh tim Helpdesk',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // =============================================
                    // DETAIL LAPORAN
                    // =============================================
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(8, 9, 8, 10),

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
                            'Detail Laporan',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFF707070),
                          ),

                          const SizedBox(height: 9),

                          // =========================================
                          // NAMA PENGGUNA
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/pp.png',
                            label: 'Nama Pengguna',
                            value: fullName,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 4),

                          // =========================================
                          // NIM / NIP
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/book.png',
                            label: 'NIM / NIP',
                            value: identifierValue,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 4),

                          // =========================================
                          // GEDUNG
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/gedung.png',
                            label: 'Nama Gedung',
                            value: buildingName,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 4),

                          // =========================================
                          // RUANGAN
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/door.png',
                            label: 'Ruangan',
                            value: roomName,
                            iconBackground: const Color(0xFFD6EBF8),
                          ),

                          const SizedBox(height: 4),

                          // =========================================
                          // TANGGAL
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/tanggal.png',
                            label: 'Tanggal',
                            value: formattedDate,
                            iconBackground: const Color(0xFF3C69C9),
                            imagePadding: 8,
                          ),

                          const SizedBox(height: 4),

                          // =========================================
                          // NO TIKET
                          // =========================================
                          _buildDetailCard(
                            asset: 'assets/images/ticket.png',
                            label: 'No. Tiket',
                            value: requestNumber,
                            iconBackground: const Color(0xFF39AD4A),
                            imagePadding: 7,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 21),

              // =================================================
              // TOMBOL BAWAH
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // ===============================================
                  // KEMBALI KE BERANDA
                  // ===============================================
                  SizedBox(
                    width: 105,
                    height: 38,

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
                          fontSize: 8.5,
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
                    height: 38,

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
                          fontSize: 8.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
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
    double imagePadding = 5,
  }) {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(minHeight: 54),

      padding: const EdgeInsets.fromLTRB(7, 5, 8, 5),

      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: const Color(0xFF969696), width: 0.7),
      ),

      child: Row(
        children: [
          // ===============================================
          // ICON / LOGO
          // ===============================================
          Container(
            width: 44,
            height: 44,

            alignment: Alignment.center,

            padding: EdgeInsets.all(imagePadding),

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
          // LABEL + VALUE
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
