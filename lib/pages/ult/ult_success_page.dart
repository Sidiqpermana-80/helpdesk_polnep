import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cek_status/cek_status_page.dart';

class UltSuccessPage extends StatelessWidget {
  const UltSuccessPage({
    super.key,
    required this.queueNumber,
    required this.requestNumber,
    required this.queueType,
    required this.queueDateLabel,
    this.queueTimeLabel,
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
    this.emailSent = false,
  });

  // =========================================================
  // DATA UTAMA
  // =========================================================

  final String queueNumber;
  final String requestNumber;
  final String queueType;
  final String queueDateLabel;
  final String? queueTimeLabel;

  final String fullName;
  final String phone;
  final String category;
  final String service;
  final String email;

  // MAHASISWA
  final String? identifierValue;
  final String? department;
  final String? semester;

  // UMUM
  final String? origin;
  final String? destination;

  final bool emailSent;

  // =========================================================
  // WARNA
  // =========================================================

  static const Color _green = Color(0xFF2EAA42);
  static const Color _infoBackground = Color(0xFFF0F7FF);
  static const Color _infoBorder = Color(0xFF9D8EE7);
  static const Color _summaryBackground = Color(0xFFD8D8D8);
  static const Color _buttonBlue = Color(0xFF5868FF);
  static const Color _buttonGreen = Color(0xFF59C467);

  // =========================================================
  // KATEGORI DAN LABEL
  // =========================================================

  bool get _isMahasiswa {
    return category.trim().toLowerCase() == 'mahasiswa';
  }

  bool get _isUmum {
    return category.trim().toLowerCase() == 'umum';
  }

  String get _queueTypeDisplay {
    final value = queueType.trim();

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

  String get _successSubtitle {
    return 'Tiket antrean ULT berhasil dibuat.\n'
        'Silakan datang sesuai tanggal dan jam pilihan,\n'
        'lalu pantau giliran Anda melalui Cek Status.';
  }

  // =========================================================
  // HALAMAN
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
                _buildHeader(context),

                const SizedBox(height: 10),

                const Text(
                  'ULT',

                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Home / Antrian Tiket / ULT',

                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

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
                      // Lingkaran nomor antrean dipertahankan.
                      _buildQueueNumber(),

                      const SizedBox(height: 11),

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

                      Row(
                        children: [
                          Expanded(child: _buildQueueDateCard()),

                          const SizedBox(width: 10),

                          Expanded(child: _buildTicketCodeCard(context)),
                        ],
                      ),

                      const SizedBox(height: 10),

                      _buildSummaryCard(),

                      const SizedBox(height: 8),

                      _buildStatusInformation(),

                      const SizedBox(height: 7),

                      _buildEmailNotification(),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

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

        const SizedBox(width: 11),

        const Text(
          'Pengajuan Berhasil',

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
  // LINGKARAN NOMOR ANTRIAN — TETAP
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
        color: _infoBackground,
        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _infoBorder, width: 0.7),
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
  // KODE TIKET DAN TOMBOL SALIN
  // =========================================================

  Widget _buildTicketCodeCard(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),

      decoration: BoxDecoration(
        color: _infoBackground,
        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _infoBorder, width: 0.7),
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

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        requestNumber.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Color(0xFF315D9D),
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 24,
                      height: 24,

                      child: IconButton(
                        tooltip: 'Salin kode tiket',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),

                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: Color(0xFF315D9D),
                        ),

                        onPressed: () {
                          _copyTicket(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyTicket(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: requestNumber));

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Kode tiket berhasil disalin.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Kode tiket belum berhasil disalin.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // =========================================================
  // RINGKASAN TIKET
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

          if (queueTimeLabel?.trim().isNotEmpty == true) ...[
            _summaryRow(
              icon: Icons.schedule_rounded,
              label: 'Jam Pilihan',
              value: queueTimeLabel!,
              iconColor: const Color(0xFF168DE2),
            ),

            const SizedBox(height: 15),
          ],

          _summaryRow(
            icon: Icons.person_rounded,
            label: 'Nama',
            value: fullName,
            iconColor: const Color(0xFF2884F2),
          ),

          const SizedBox(height: 15),

          if (_isMahasiswa) ...[
            _summaryRow(
              icon: Icons.menu_book_outlined,
              label: 'NIM',
              value: identifierValue ?? '-',
              iconColor: const Color(0xFF6595D2),
            ),

            const SizedBox(height: 15),
          ],

          if (_isUmum) ...[
            _summaryRow(
              icon: Icons.business_rounded,
              label: 'Dari',
              value: origin ?? '-',
              iconColor: const Color(0xFF6595D2),
            ),

            const SizedBox(height: 15),
          ],

          _summaryRow(
            icon: Icons.phone_android_rounded,
            label: 'No. HP',
            value: phone,
            iconColor: const Color(0xFF2884F2),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
            iconColor: const Color(0xFF2884F2),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.account_box_rounded,
            label: 'Kategori',
            value: category,
            iconColor: const Color(0xFF655CE6),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.event_available_rounded,
            label: 'Jenis Antrian',
            value: _queueTypeDisplay,
            iconColor: const Color(0xFF168DE2),
          ),

          if (_isMahasiswa) ...[
            const SizedBox(height: 15),

            _summaryRow(
              icon: Icons.account_balance_rounded,
              label: 'Jurusan',
              value: department ?? '-',
              iconColor: const Color(0xFF6757D9),
            ),

            const SizedBox(height: 15),

            _summaryRow(
              icon: Icons.school_rounded,
              label: 'Semester',
              value: semester?.trim().isNotEmpty == true
                  ? 'Semester $semester'
                  : '-',
              iconColor: const Color(0xFF3EA94C),
            ),
          ],

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.support_agent_rounded,
            label: _isUmum ? 'Jenis Layanan' : 'Layanan',
            value: service,
            iconColor: const Color(0xFF2216B8),
          ),

          if (_isUmum) ...[
            const SizedBox(height: 15),

            _summaryRow(
              icon: Icons.send_rounded,
              label: 'Untuk',
              value: destination ?? '-',
              iconColor: const Color(0xFF3EA94C),
            ),
          ],

          if (queueTimeLabel?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 10),

            const Text(
              'Jam pilihan merupakan perkiraan; '
              'giliran mengikuti pemanggilan petugas.',

              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 8,
                height: 1.35,
              ),
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
            value.trim().isEmpty ? '-' : value,
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
  // INFORMASI CEK STATUS — TANDA SERU PNG
  // =========================================================

  Widget _buildStatusInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),

      decoration: BoxDecoration(
        color: _infoBackground,
        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _infoBorder, width: 0.7),
      ),

      child: Row(
        children: [
          SizedBox(
            width: 31,
            height: 31,

            child: Image.asset('assets/images/seru.png', fit: BoxFit.contain),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Simpan kode tiket untuk memeriksa status antrean.\n'
              'Pantau Cek Status dan perhatikan pemanggilan petugas ULT.',

              style: TextStyle(
                color: Color(0xFF303030),
                fontSize: 9,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // INFORMASI EMAIL
  // =========================================================

  Widget _buildEmailNotification() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),

      decoration: BoxDecoration(
        color: _infoBackground,
        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: _infoBorder, width: 0.7),
      ),

      child: Row(
        children: [
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

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emailSent ? 'Notifikasi Email Terkirim' : 'Notifikasi Email',

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
                            ? 'Informasi tiket antrean ULT '
                                  'telah dikirim ke\n'
                            : 'Tiket berhasil dibuat. Konfirmasi '
                                  'pengiriman email belum tersedia.\n',

                        style: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 7.5,
                          height: 1.25,
                        ),
                      ),

                      TextSpan(
                        text: email.trim().isEmpty ? '-' : email,

                        style: const TextStyle(
                          color: Color(0xFF2AA545),
                          fontSize: 7.5,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),

                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

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
  // TOMBOL BAWAH
  // =========================================================

  Widget _buildBottomButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: _button(
              label: 'Cek Status',
              width: 125,
              color: _buttonBlue,

              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CekStatusPage(initialKeyword: requestNumber),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 16),

          Flexible(
            child: _button(
              label: 'Kembali ke Beranda',
              width: 137,
              color: _buttonGreen,

              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String label,
    required double width,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: width,
      height: 38,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),

        child: Text(
          label,
          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
