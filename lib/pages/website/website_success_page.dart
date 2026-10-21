import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cek_status/cek_status_page.dart';

class WebsiteSuccessPage extends StatelessWidget {
  const WebsiteSuccessPage({
    required this.requestNumber,
    required this.fullName,
    required this.identifierValue,
    required this.websiteName,
    required this.issueType,
    required this.submittedAt,
    this.issueLabel = '',
    this.email = '',
    this.description = '',
    this.supportFileName = '',
    this.status = 'menunggu_verifikasi',
    this.estimatedResponse = '',
    this.emailSent = false,
    super.key,
  });

  final String requestNumber;
  final String fullName;
  final String identifierValue;
  final String websiteName;
  final String issueType;
  final DateTime submittedAt;

  final String issueLabel;
  final String email;
  final String description;
  final String supportFileName;
  final String status;
  final String estimatedResponse;

  final bool emailSent;

  // Mengikuti warna halaman sukses Wi-Fi.
  static const Color _green = Color(0xFF2EAA42);
  static const Color _darkBlue = Color(0xFF075DBD);

  static const Color _infoBackground = Color(0xFFF0F7FF);
  static const Color _infoBorder = Color(0xFF9D8EE7);

  static const Color _summaryBackground = Color(0xFFD8D8D8);
  static const Color _buttonBlue = Color(0xFF5868FF);
  static const Color _buttonGreen = Color(0xFF59C467);

  String get _issueLabel {
    if (issueLabel.trim().isNotEmpty) {
      return issueLabel.trim();
    }

    final value = issueType.trim().replaceAll('_', ' ');

    if (value.isEmpty) {
      return '-';
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  String get _statusLabel {
    const labels = <String, String>{
      'menunggu_verifikasi': 'Menunggu Verifikasi',
      'diproses': 'Diproses',
      'dijawab': 'Dijawab',
      'diterima': 'Diterima',
      'selesai': 'Selesai',
      'ditolak': 'Ditolak',
    };

    return labels[status] ?? status;
  }

  String get _dateLabel {
    const months = [
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

    final date = submittedAt;

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _successSubtitle {
    return 'Laporan kendala website berhasil dikirim.\n'
        'Tim Helpdesk akan menindaklanjuti laporan Anda.\n'
        'Pantau perkembangannya melalui Cek Status.';
  }

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
                  'Website',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Home / Pengaduan / Website',
                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),

                // KARTU UTAMA
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
                      _buildSuccessIcon(),
                      const SizedBox(height: 11),
                      const Text(
                        'Pengajuan Berhasil Dikirim',
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

                      // TANGGAL DAN KODE TIKET
                      Row(
                        children: [
                          Expanded(child: _buildSubmissionDateCard()),
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
  // IKON BERHASIL
  // =========================================================

  Widget _buildSuccessIcon() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _infoBackground,
        shape: BoxShape.circle,
        border: Border.all(color: _green, width: 3),
      ),
      child: const Icon(Icons.check_rounded, color: _green, size: 58),
    );
  }

  // =========================================================
  // TANGGAL PENGAJUAN
  // =========================================================

  Widget _buildSubmissionDateCard() {
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
                  'Tanggal Pengajuan:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF333333), fontSize: 7),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateLabel,
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
                        requestNumber,
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
  // RINGKASAN PENGAJUAN
  // =========================================================

  Widget _buildSummaryCard() {
    final rows = <Widget>[
      _summaryRow(
        icon: Icons.language_rounded,
        label: 'Jenis Layanan',
        value: 'Pengaduan Website',
        iconColor: const Color(0xFF168DE2),
      ),
      _summaryRow(
        icon: Icons.person_rounded,
        label: 'Nama',
        value: fullName,
        iconColor: const Color(0xFF2884F2),
      ),
      _summaryRow(
        icon: Icons.menu_book_outlined,
        label: 'NIM / NIP',
        value: identifierValue,
        iconColor: const Color(0xFF6595D2),
      ),
      _summaryRow(
        icon: Icons.email_outlined,
        label: 'Email',
        value: email,
        iconColor: const Color(0xFF2884F2),
      ),
      _summaryRow(
        icon: Icons.language_rounded,
        label: 'Website',
        value: websiteName,
        iconColor: const Color(0xFF168DE2),
      ),
      _summaryRow(
        icon: Icons.report_problem_outlined,
        label: 'Jenis Kendala',
        value: _issueLabel,
        iconColor: const Color(0xFF2884F2),
      ),
      _summaryRow(
        icon: Icons.description_outlined,
        label: 'Deskripsi Keluhan',
        value: description,
        iconColor: const Color(0xFF6757D9),
        maxLines: null,
      ),
      _summaryRow(
        icon: Icons.attach_file_rounded,
        label: 'File Pendukung',
        value: supportFileName.trim().isEmpty
            ? 'Tidak ada lampiran'
            : supportFileName,
        iconColor: const Color(0xFF2884F2),
      ),
      _summaryRow(
        icon: Icons.fact_check_outlined,
        label: 'Status Pengajuan',
        value: _statusLabel,
        iconColor: const Color(0xFF168DE2),
      ),
      _summaryRow(
        icon: Icons.schedule_rounded,
        label: 'Estimasi Respons',
        value: estimatedResponse,
        iconColor: const Color(0xFF168DE2),
      ),
    ];

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
                  errorBuilder: (_, error, stack) {
                    return const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF315D9D),
                      size: 23,
                    );
                  },
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Ringkasan Pengajuan',
                style: TextStyle(
                  color: Color(0xFF315D9D),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const SizedBox(height: 15),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    int? maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: maxLines == null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
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
            maxLines: maxLines,
            overflow: maxLines == null
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
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
        color: _infoBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _infoBorder, width: 0.7),
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
              'pengajuan di Cek Status.',
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
                            ? 'Informasi tiket pengajuan telah dikirim ke\n'
                            : 'Konfirmasi pengiriman email belum tersedia.\n',
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _button('Cek Status', 125, _buttonBlue, () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CekStatusPage(initialKeyword: requestNumber),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: _button('Kembali ke Beranda', 137, _buttonGreen, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Buat Pengaduan Lagi',
              style: TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(
    String label,
    double width,
    Color color,
    VoidCallback onPressed,
  ) {
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
          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
