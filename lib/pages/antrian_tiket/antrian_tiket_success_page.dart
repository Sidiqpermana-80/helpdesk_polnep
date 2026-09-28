import 'package:flutter/material.dart';

import '../cek_status/cek_status_page.dart';

class AntrianTiketSuccessPage extends StatelessWidget {
  const AntrianTiketSuccessPage({
    super.key,
    required this.queueNumber,
    required this.requestNumber,
    required this.queueType,
    required this.queueDateLabel,
    required this.fullName,
    required this.phone,
    required this.category,
    required this.service,
    required this.email,
    this.identifierValue,
    this.department,
    this.semester,
    this.origin,
    this.destination,
    this.emailSent = true,
  });

  // =========================================================
  // DATA UTAMA
  // =========================================================

  final String queueNumber;

  final String requestNumber;

  final String queueType;

  final String queueDateLabel;

  final String fullName;

  final String phone;

  final String category;

  final String service;

  final String email;

  // =========================================================
  // MAHASISWA
  // =========================================================

  final String? identifierValue;

  final String? department;

  final String? semester;

  // =========================================================
  // UMUM
  // =========================================================

  final String? origin;

  final String? destination;

  // =========================================================
  // EMAIL
  // =========================================================

  final bool emailSent;

  // =========================================================
  // WARNA
  // =========================================================

  static const Color _green = Color(0xFF2EAA42);

  static const Color _darkBlue = Color(0xFF075DBD);

  static const Color _purpleBackground = Color(0xFFC5BCFF);

  static const Color _purpleBorder = Color(0xFF8C80E5);

  static const Color _summaryBackground = Color(0xFFD8D8D8);

  static const Color _buttonPurple = Color(0xFF7184F4);

  static const Color _buttonGreen = Color(0xFF59C467);

  // =========================================================
  // CEK KATEGORI
  // =========================================================

  bool get _isMahasiswa {
    return category.trim().toLowerCase() == 'mahasiswa';
  }

  bool get _isUmum {
    return category.trim().toLowerCase() == 'umum';
  }

  // =========================================================
  // FORMAT JENIS ANTRIAN
  // =========================================================

  String get _queueTypeDisplay {
    final String value = queueType.trim();

    if (value.isEmpty) {
      return '-';
    }

    switch (value.toLowerCase()) {
      case 'langsung':
        return 'Langsung (Hari Ini)';

      case 'booking':
        return 'Booking';

      default:
        return value;
    }
  }

  // =========================================================
  // SUBTITLE
  // =========================================================

  String get _successSubtitle {
    final String value = queueType.trim().toLowerCase();

    if (value == 'booking') {
      return 'Tiket booking berhasil dibuat.\n'
          'Silakan datang sesuai tanggal antrian yang dipilih.';
    }

    return 'Silakan menunggu giliran Anda untuk dipanggil\n'
        'oleh Petugas Loket Antrian.';
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

              stops: [0.00, 0.48, 1.00],
            ),
          ),

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(14, 13, 14, 18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ===============================================
                // HEADER
                // ===============================================
                _buildHeader(context),

                const SizedBox(height: 10),

                // ===============================================
                // JUDUL
                // ===============================================
                const Text(
                  'Antrian Tiket',

                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                // ===============================================
                // BREADCRUMB
                // ===============================================
                const Text(
                  'Home / Antrian Tiket',

                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // ===============================================
                // CARD UTAMA
                // ===============================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(8, 15, 8, 10),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(8),

                    border: Border.all(
                      color: const Color(0xFFDCEAF4),
                      width: 0.6,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      // =========================================
                      // NOMOR ANTRIAN
                      // =========================================
                      _buildQueueNumber(),

                      const SizedBox(height: 11),

                      // =========================================
                      // JUDUL SUKSES
                      // =========================================
                      const Text(
                        'Tiket Berhasil Dibuat',

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // =========================================
                      // SUBTITLE
                      // =========================================
                      Text(
                        _successSubtitle,

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 8.2,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // =========================================
                      // TANGGAL + KODE TIKET
                      // =========================================
                      Row(
                        children: [
                          Expanded(child: _buildQueueDateCard()),

                          const SizedBox(width: 10),

                          Expanded(child: _buildTicketCodeCard()),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // =========================================
                      // RINGKASAN
                      // =========================================
                      _buildSummaryCard(),

                      const SizedBox(height: 8),

                      // =========================================
                      // INFO STATUS
                      // =========================================
                      _buildStatusInformation(),

                      const SizedBox(height: 7),

                      // =========================================
                      // EMAIL
                      // =========================================
                      _buildEmailNotification(),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ===============================================
                // BUTTON
                // ===============================================
                _buildBottomButtons(context),
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

  Widget _buildHeader(BuildContext context) {
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

        const SizedBox(width: 11),

        const Text(
          'Permintaan Berhasil',

          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // NOMOR ANTRIAN
  // =========================================================

  Widget _buildQueueNumber() {
    return Container(
      width: 96,

      height: 96,

      decoration: BoxDecoration(
        color: const Color(0xFFE7E6F0),

        shape: BoxShape.circle,

        border: Border.all(color: _green, width: 3),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          const SizedBox(height: 4),

          Text(
            queueNumber,

            style: const TextStyle(
              color: _green,
              fontSize: 29,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Nomor Antrian Anda',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: Color(0xFF315D9D),
              fontSize: 6.8,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TANGGAL ANTRIAN
  // =========================================================

  Widget _buildQueueDateCard() {
    return Container(
      height: 48,

      padding: const EdgeInsets.symmetric(horizontal: 8),

      decoration: BoxDecoration(
        color: _purpleBackground,

        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _purpleBorder, width: 0.7),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,

            color: Color(0xFF315D9D),

            size: 23,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Tanggal Antrian:',

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(color: Color(0xFF333333), fontSize: 7),
                ),

                const SizedBox(height: 2),

                Text(
                  queueDateLabel,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF315D9D),
                    fontSize: 7.5,
                    height: 1.1,
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
  // KODE TIKET
  // =========================================================

  Widget _buildTicketCodeCard() {
    return Container(
      height: 48,

      padding: const EdgeInsets.symmetric(horizontal: 8),

      decoration: BoxDecoration(
        color: _purpleBackground,

        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _purpleBorder, width: 0.7),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_rounded,

            color: Color(0xFF315D9D),

            size: 23,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Kode Tiket:',

                  style: TextStyle(color: Color(0xFF333333), fontSize: 7),
                ),

                const SizedBox(height: 2),

                Text(
                  requestNumber.toUpperCase(),

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF315D9D),
                    fontSize: 8,
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
  // RINGKASAN
  // =========================================================

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(11, 11, 11, 13),

      decoration: BoxDecoration(
        color: _summaryBackground,

        borderRadius: BorderRadius.circular(5),

        border: Border.all(color: const Color(0xFF9A9A9A), width: 0.7),
      ),

      child: Column(
        children: [
          // ===============================================
          // HEADER
          // ===============================================
          Row(
            children: [
              SizedBox(
                width: 23,

                height: 23,

                child: Image.asset(
                  'assets/images/berkas.png',

                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 7),

              const Text(
                'Ringkasan Tiket',

                style: TextStyle(
                  color: Color(0xFF315D9D),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ===============================================
          // NAMA
          // ===============================================
          _summaryRow(
            icon: Icons.person_rounded,

            label: 'Nama',

            value: fullName,

            iconColor: const Color(0xFF2884F2),
          ),

          const SizedBox(height: 15),

          // ===============================================
          // MAHASISWA -> NIM
          // ===============================================
          if (_isMahasiswa) ...[
            _summaryRow(
              icon: Icons.menu_book_outlined,

              label: 'NIM',

              value: identifierValue?.trim().isNotEmpty == true
                  ? identifierValue!
                  : '-',

              iconColor: const Color(0xFF6595D2),
            ),

            const SizedBox(height: 15),
          ],

          // ===============================================
          // UMUM -> DARI
          // ===============================================
          if (_isUmum) ...[
            _summaryRow(
              icon: Icons.business_rounded,

              label: 'Dari',

              value: origin?.trim().isNotEmpty == true ? origin! : '-',

              iconColor: const Color(0xFF6595D2),
            ),

            const SizedBox(height: 15),
          ],

          // ===============================================
          // NO HP
          // ===============================================
          _summaryRow(
            icon: Icons.phone_android_rounded,

            label: 'No. HP',

            value: phone,

            iconColor: const Color(0xFF2884F2),
          ),

          const SizedBox(height: 15),

          // ===============================================
          // KATEGORI
          // ===============================================
          _summaryRow(
            icon: Icons.account_box_rounded,

            label: 'Kategori',

            value: category,

            iconColor: const Color(0xFF655CE6),
          ),

          const SizedBox(height: 15),

          // ===============================================
          // JENIS ANTRIAN
          // ===============================================
          _summaryRow(
            icon: Icons.event_available_rounded,

            label: 'Jenis Antrian',

            value: _queueTypeDisplay,

            iconColor: const Color(0xFF168DE2),
          ),

          // ===============================================
          // MAHASISWA -> JURUSAN
          // ===============================================
          if (_isMahasiswa) ...[
            const SizedBox(height: 15),

            _summaryRow(
              icon: Icons.account_balance_rounded,

              label: 'Jurusan',

              value: department?.trim().isNotEmpty == true ? department! : '-',

              iconColor: const Color(0xFF6757D9),
            ),

            const SizedBox(height: 15),

            // =============================================
            // SEMESTER
            // =============================================
            _summaryRow(
              icon: Icons.school_rounded,

              label: 'Semester',

              value: semester?.trim().isNotEmpty == true
                  ? 'Semester $semester'
                  : '-',

              iconColor: const Color(0xFF3EA94C),
            ),
          ],

          // ===============================================
          // LAYANAN
          // ===============================================
          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.support_agent_rounded,

            label: _isUmum ? 'Jenis Layanan' : 'Layanan',

            value: service,

            iconColor: const Color(0xFF2216B8),
          ),

          // ===============================================
          // UMUM -> UNTUK
          // ===============================================
          if (_isUmum) ...[
            const SizedBox(height: 15),

            _summaryRow(
              icon: Icons.send_rounded,

              label: 'Untuk',

              value: destination?.trim().isNotEmpty == true
                  ? destination!
                  : '-',

              iconColor: const Color(0xFF3EA94C),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // BARIS RINGKASAN
  // =========================================================

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        SizedBox(width: 22, child: Icon(icon, size: 16, color: iconColor)),

        const SizedBox(width: 7),

        SizedBox(
          width: 76,

          child: Text(
            label,

            style: const TextStyle(
              color: Color(0xFF303030),
              fontSize: 8.3,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(width: 5),

        Expanded(
          child: Text(
            value,

            textAlign: TextAlign.right,

            maxLines: 2,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: Color(0xFF202020),
              fontSize: 8.3,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // INFORMASI CEK STATUS
  // =========================================================

  Widget _buildStatusInformation() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),

      decoration: BoxDecoration(
        color: _purpleBackground,

        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _purpleBorder, width: 0.7),
      ),

      child: const Row(
        children: [
          CircleAvatar(
            radius: 13,

            backgroundColor: _darkBlue,

            child: Icon(
              Icons.priority_high_rounded,

              color: Colors.white,

              size: 20,
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Gunakan kode tiket untuk mengecek status\n'
              'antrian di Cek Status.',

              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 8,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // NOTIFIKASI EMAIL
  // =========================================================

  Widget _buildEmailNotification() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),

      decoration: BoxDecoration(
        color: _purpleBackground,

        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _purpleBorder, width: 0.7),
      ),

      child: Row(
        children: [
          // ===============================================
          // EMAIL ICON
          // ===============================================
          Container(
            width: 28,

            height: 28,

            decoration: const BoxDecoration(
              color: Color(0xFF2389EC),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.email_outlined,

              color: Colors.white,

              size: 18,
            ),
          ),

          const SizedBox(width: 9),

          // ===============================================
          // TEXT
          // ===============================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  emailSent ? 'Notifikasi Terkirim' : 'Notifikasi Email',

                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: emailSent
                            ? 'Detail tiket dan nomor antrian telah dikirim ke\n'
                            : 'Tiket berhasil dibuat, namun email belum berhasil dikirim ke\n',

                        style: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 7.5,
                          height: 1.25,
                        ),
                      ),

                      TextSpan(
                        text: email,

                        style: const TextStyle(
                          color: Color(0xFF2AA545),
                          fontSize: 7.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),

                  maxLines: 3,

                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          // ===============================================
          // STATUS EMAIL
          // ===============================================
          Container(
            width: 20,

            height: 20,

            decoration: BoxDecoration(
              color: emailSent
                  ? const Color(0xFFE9F8EA)
                  : const Color(0xFFFFF4DB),

              shape: BoxShape.circle,

              border: Border.all(
                color: emailSent
                    ? const Color(0xFF39B54A)
                    : const Color(0xFFFFB52D),

                width: 1.3,
              ),
            ),

            child: Icon(
              emailSent ? Icons.check_rounded : Icons.priority_high_rounded,

              size: 14,

              color: emailSent
                  ? const Color(0xFF39B54A)
                  : const Color(0xFFFFA000),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BUTTON BAWAH
  // =========================================================

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        // ===============================================
        // CEK STATUS
        // ===============================================
        SizedBox(
          width: 125,

          height: 38,

          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return const CekStatusPage();
                  },
                ),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonPurple,

              foregroundColor: Colors.white,

              elevation: 0,

              padding: EdgeInsets.zero,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            child: const Text(
              'Cek Status',

              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w400),
            ),
          ),
        ),

        const SizedBox(width: 31),

        // ===============================================
        // BERANDA
        // ===============================================
        SizedBox(
          width: 137,

          height: 38,

          child: ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).popUntil((Route<dynamic> route) => route.isFirst);
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonGreen,

              foregroundColor: Colors.white,

              elevation: 0,

              padding: EdgeInsets.zero,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            child: const Text(
              'Kembali ke Beranda',

              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }
}
