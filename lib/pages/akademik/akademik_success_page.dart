import 'package:flutter/material.dart';

import '../../services/akademik_queue_service.dart';
import '../cek_status/cek_status_page.dart';

class AkademikSuccessPage extends StatelessWidget {
  const AkademikSuccessPage({
    super.key,
    required this.ticket,
    required this.fullName,
    required this.nim,
    required this.phone,
    required this.email,
    required this.studentStatus,
    required this.purpose,
    required this.description,
  });

  final AkademikQueueTicket ticket;

  final String fullName;
  final String nim;
  final String phone;
  final String email;
  final String studentStatus;
  final String purpose;
  final String description;

  // WARNA MENGIKUTI HALAMAN SUKSES ULT
  static const Color _green = Color(0xFF2EAA42);
  static const Color _darkBlue = Color(0xFF075DBD);
  static const Color _purpleBackground = Color(0xFFC5BCFF);
  static const Color _purpleBorder = Color(0xFF8C80E5);
  static const Color _summaryBackground = Color(0xFFD8D8D8);
  static const Color _buttonPurple = Color(0xFF7184F4);
  static const Color _buttonGreen = Color(0xFF59C467);

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

    final date = ticket.queueDate;

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _successSubtitle {
    return 'Tiket antrian Akademik berhasil dibuat.\n'
        'Silakan datang sesuai tanggal dan jam pilihan,\n'
        'lalu pantau giliran Anda melalui Cek Status.';
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
                  'Akademik',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Home / Akademik',
                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // CARD UTAMA
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

                      // TANGGAL DAN KODE TIKET
                      Row(
                        children: [
                          Expanded(child: _buildQueueDateCard()),

                          const SizedBox(width: 10),

                          Expanded(child: _buildTicketCodeCard()),
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
            ticket.numberLabel,
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
                  ticket.requestNumber.toUpperCase(),
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
  // RINGKASAN TIKET AKADEMIK
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

          _summaryRow(
            icon: Icons.schedule_rounded,
            label: 'Jam Pilihan',
            value: ticket.timeLabel,
            iconColor: const Color(0xFF168DE2),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.person_rounded,
            label: 'Nama',
            value: fullName,
            iconColor: const Color(0xFF2884F2),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.menu_book_outlined,
            label: 'NIM',
            value: nim,
            iconColor: const Color(0xFF6595D2),
          ),

          const SizedBox(height: 15),

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
            icon: Icons.school_rounded,
            label: 'Status Mahasiswa',
            value: studentStatus,
            iconColor: const Color(0xFF3EA94C),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.support_agent_rounded,
            label: 'Keperluan',
            value: purpose,
            iconColor: const Color(0xFF2216B8),
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.description_outlined,
            label: 'Keterangan',
            value: description,
            iconColor: const Color(0xFF6757D9),
            maxLines: null,
          ),

          const SizedBox(height: 15),

          _summaryRow(
            icon: Icons.fact_check_outlined,
            label: 'Status Antrian',
            value: ticket.statusLabel,
            iconColor: const Color(0xFF168DE2),
          ),

          const SizedBox(height: 10),

          const Text(
            'Jam pilihan merupakan perkiraan; giliran mengikuti petugas.',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 8,
              height: 1.35,
            ),
          ),
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
  // INFORMASI NOTIFIKASI HP
  // =========================================================

  Widget _buildEmailNotification() {
    final bool emailSent = ticket.emailSent;

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
          // IKON EMAIL
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

          // INFORMASI HASIL PENGIRIMAN
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
                            ? 'Detail tiket dan nomor antrian '
                                  'telah dikirim ke\n'
                            : 'Tiket berhasil dibuat. Email '
                                  'konfirmasi belum terkirim ke\n',

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

                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          // INDIKATOR EMAIL
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 125,
          height: 38,

          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) {
                    return CekStatusPage(initialKeyword: ticket.requestNumber);
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
