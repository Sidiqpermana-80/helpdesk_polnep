import 'package:flutter/material.dart';

class PermintaanDataSuccessPage extends StatelessWidget {
  const PermintaanDataSuccessPage({
    required this.categoryName,
    required this.identifierLabel,
    required this.identifierValue,
    required this.requestCategory,
    required this.requestNumber,
    required this.status,
    required this.estimatedResponse,
    this.unitKerja,
    super.key,
  });

  final String categoryName;
  final String identifierLabel;
  final String identifierValue;
  final String requestCategory;
  final String requestNumber;
  final String status;
  final String estimatedResponse;
  final String? unitKerja;

  // =========================================================
  // FORMAT STATUS
  // =========================================================

  String get formattedStatus {
    switch (status) {
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';

      case 'terverifikasi':
        return 'Terverifikasi';

      case 'diproses':
        return 'Diproses';

      case 'selesai':
        return 'Selesai';

      case 'ditolak':
        return 'Ditolak';

      default:
        return status;
    }
  }

  // =========================================================
  // WARNA STATUS
  // =========================================================

  Color get statusColor {
    switch (status) {
      case 'terverifikasi':
        return const Color(0xFF58C761);

      case 'diproses':
        return const Color(0xFF3AA7F5);

      case 'selesai':
        return const Color(0xFF43A047);

      case 'ditolak':
        return const Color(0xFFE74C3C);

      case 'menunggu_verifikasi':
      default:
        return const Color(0xFFFFB52D);
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
        leadingWidth: 39,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF202020),
            size: 19,
          ),
        ),
        titleSpacing: 0,
        title: const Text(
          'Permintaan Data',
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
            stops: [0.00, 0.25, 0.55, 1.00],
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
              Text(
                'Permintaan Data $categoryName',
                style: const TextStyle(
                  color: Color(0xFF202020),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Home / Permintaan Data',
                style: TextStyle(
                  color: Color(0xFF168DE2),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // CARD SUCCESS
              // =================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(7, 12, 7, 17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
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
                    // ICON
                    // =============================================
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00D51D),
                      size: 82,
                    ),

                    const SizedBox(height: 5),

                    // =============================================
                    // JUDUL SUCCESS
                    // =============================================
                    const Text(
                      'Permintaan Data Berhasil Dikirim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Permintaan Anda telah berhasil dikirim dan akan segera diproses',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 9.5,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =============================================
                    // DETAIL
                    // =============================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCDCDC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.assignment_outlined,
                            label: 'No Permintaan',
                            value: requestNumber,
                          ),

                          _buildDetailRow(
                            icon: Icons.person_rounded,
                            label: identifierLabel,
                            value: identifierValue,
                          ),

                          if (unitKerja != null)
                            _buildDetailRow(
                              icon: Icons.business_rounded,
                              label: 'Nama Unit Kerja',
                              value: unitKerja!,
                            ),

                          _buildDetailRow(
                            icon: Icons.category_rounded,
                            label: 'Kategori Permintaan',
                            value: requestCategory,
                          ),

                          _buildStatusRow(),

                          _buildDetailRow(
                            icon: Icons.access_time_rounded,
                            label: 'Estimasi Respon',
                            value: estimatedResponse,
                            showBottomSpacing: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // BUTTON
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        'Buat Permintaan Lagi',
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
  // DETAIL ROW
  // =========================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool showBottomSpacing = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpacing ? 17 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            child: Icon(icon, color: const Color(0xFF1678DE), size: 16),
          ),

          const SizedBox(width: 4),

          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF222222), fontSize: 9.5),
            ),
          ),

          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF222222),
                fontSize: 9.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS
  // =========================================================

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 22,
            child: Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF1678DE),
              size: 16,
            ),
          ),

          const SizedBox(width: 4),

          const SizedBox(
            width: 118,
            child: Text(
              'Status',
              style: TextStyle(color: Color(0xFF222222), fontSize: 9.5),
            ),
          ),

          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formattedStatus,
                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
