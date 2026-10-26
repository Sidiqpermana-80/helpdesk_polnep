import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cek_status/cek_status_page.dart';

class PpkptSuccessPage extends StatelessWidget {
  const PpkptSuccessPage({
    required this.requestNumber,
    required this.submittedAt,
    this.status = 'menunggu_verifikasi',
    this.emailSent = false,
    this.contactPreference = 'none',
    this.email = '',
    super.key,
  });

  final String requestNumber;
  final DateTime submittedAt;
  final String status;
  final bool emailSent;
  final String contactPreference;
  final String email;

  static const _green = Color(0xFF2EAA42);
  static const _blue = Color(0xFF315D9D);
  static const _infoBackground = Color(0xFFF0F7FF);
  static const _infoBorder = Color(0xFF9D8EE7);

  BoxDecoration get _infoDecoration => BoxDecoration(
    color: _infoBackground,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: _infoBorder, width: 0.7),
  );

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

    final date = submittedAt.toLocal();

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _timeLabel {
    final date = submittedAt.toLocal();

    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String get _statusLabel {
    const labels = {
      'menunggu_verifikasi': 'Menunggu Verifikasi',
      'diterima': 'Laporan Diterima',
      'dalam_penanganan': 'Dalam Penanganan',
      'selesai': 'Penanganan Selesai',
      'ditolak': 'Ditolak',
    };

    return labels[status] ?? status;
  }

  String get _contactLabel {
    const labels = {
      'none': 'Tidak Dihubungi',
      'phone': 'No. HP',
      'email': 'Email',
    };

    return labels[contactPreference] ?? '-';
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
              stops: [0, 0.48, 1],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                ),
                const SizedBox(height: 10),
                const Text(
                  'PPKPT',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Home / Pengaduan / PPKPT',
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
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: _infoBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: _green, width: 3),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: _green,
                          size: 58,
                        ),
                      ),
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
                      const Text(
                        'Laporan PPKPT Anda berhasil dikirim.\n'
                        'Laporan akan diverifikasi oleh petugas.\n'
                        'Simpan kode tiket untuk memantau statusnya.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 8.2,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _smallCard(
                              icon: Icons.calendar_month_rounded,
                              label: 'Tanggal Pengajuan:',
                              value: Text(
                                _dateLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _blue,
                                  fontSize: 7.5,
                                  height: 1.1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _smallCard(
                              icon: Icons.confirmation_number_rounded,
                              label: 'Kode Tiket:',
                              value: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      requestNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _blue,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Salin kode tiket',
                                      onPressed: () {
                                        _copyTicket(context);
                                      },
                                      icon: const Icon(
                                        Icons.copy_rounded,
                                        size: 14,
                                        color: _blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _summary(),
                      const SizedBox(height: 8),
                      _information(
                        'Simpan kode tiket untuk memantau '
                        'perkembangan laporan melalui Cek Status.',
                      ),
                      if (email.trim().isNotEmpty) ...[
                        const SizedBox(height: 7),
                        _emailCard(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _button(
                        'Cek Status',
                        125,
                        const Color(0xFF5868FF),
                        () {
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
                        'Kembali ke Beranda',
                        137,
                        const Color(0xFF59C467),
                        () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Buat Laporan Lagi',
                      style: TextStyle(fontSize: 9),
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

  Widget _smallCard({
    required IconData icon,
    required String label,
    required Widget value,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _infoDecoration,
      child: Row(
        children: [
          Icon(icon, color: _blue, size: 23),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF333333), fontSize: 7),
                ),
                const SizedBox(height: 2),
                value,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    final rows = <Widget>[
      _summaryRow(Icons.shield_outlined, 'Jenis Layanan', 'PPKPT'),
      _summaryRow(Icons.fact_check_outlined, 'Status Pengajuan', _statusLabel),
      _summaryRow(Icons.contact_mail_outlined, 'Pilihan Kontak', _contactLabel),
      _summaryRow(Icons.schedule_rounded, 'Jam Pengajuan', _timeLabel),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 11, 11, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF9A9A9A), width: 0.7),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, color: _blue, size: 23),
              SizedBox(width: 7),
              Text(
                'Ringkasan Pengajuan',
                style: TextStyle(
                  color: _blue,
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

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Icon(icon, size: 16, color: const Color(0xFF2884F2)),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF303030), fontSize: 8.3),
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

  Widget _information(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: _infoDecoration,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 13,
            backgroundColor: Color(0xFF075DBD),
            child: Icon(
              Icons.priority_high_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
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

  Widget _emailCard() {
    final address = email.trim().isEmpty ? 'alamat email yang Anda isi' : email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: _infoDecoration,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF2389EC),
            child: Icon(Icons.email_outlined, color: Colors.white, size: 18),
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
                Text(
                  emailSent
                      ? 'Informasi pengajuan telah dikirim ke\n'
                            '$address'
                      : 'Konfirmasi pengiriman email '
                            'belum tersedia.\n$address',
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 7.5,
                    height: 1.25,
                  ),
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
