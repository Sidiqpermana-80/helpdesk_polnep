import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cek_status/cek_status_page.dart';

class PungliSuccessPage extends StatelessWidget {
  const PungliSuccessPage({
    required this.requestNumber,
    required this.identified,
    required this.locationName,
    required this.submittedAt,
    this.email = '',
    this.status = 'menunggu_verifikasi',
    this.emailSent = false,
    super.key,
  });

  final String requestNumber;
  final String locationName;
  final String email;
  final String status;

  final bool identified;
  final bool emailSent;

  final DateTime submittedAt;

  String get _date {
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

    return '${submittedAt.day} '
        '${months[submittedAt.month - 1]} '
        '${submittedAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final accepted = status == 'diterima';

    final statusLabel = accepted ? 'Laporan Diterima' : 'Menunggu Verifikasi';

    final details = <Widget>[
      _detail(
        'Pilihan Identitas',
        identified ? 'Cantumkan Identitas' : 'Tanpa Identitas',

        icon: identified
            ? Icons.person_outline_rounded
            : Icons.visibility_off_outlined,
      ),

      _detail(
        'Unit / Lokasi Kejadian',
        locationName,
        icon: Icons.location_on_outlined,
      ),

      _detail(
        'Status',
        statusLabel,

        icon: accepted
            ? Icons.check_circle_outline_rounded
            : Icons.hourglass_empty_rounded,
      ),

      _detail(
        'Tanggal Pengajuan',
        _date,
        asset: 'assets/images/kalender.png',
        background: const Color(0xFF3E64C7),
      ),

      _detail(
        'No. Tiket',
        requestNumber,
        asset: 'assets/images/ticket.png',
        background: const Color(0xFF41B64E),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FF),

        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        leadingWidth: 45,
        titleSpacing: 0,

        leading: IconButton(
          tooltip: 'Kembali',

          onPressed: () => Navigator.of(context).pop(),

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF202020),
            size: 20,
          ),
        ),

        title: const Text(
          'Pengaduan Berhasil',
          style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Container(
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
          padding: const EdgeInsets.fromLTRB(7, 5, 7, 28),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Padding(
                padding: EdgeInsets.only(left: 2),

                child: Text(
                  'Pungli',
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
                  'Home / Pengaduan / Pungli',
                  style: TextStyle(
                    color: Color(0xFF168DE2),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 10),

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
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00D51D),
                      size: 82,
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Pengaduan Berhasil Dikirim',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      accepted
                          ? 'Laporan Anda telah diverifikasi '
                                'dan diterima oleh admin.'
                          : 'Laporan Pungli Anda berhasil dikirim\n'
                                'dan menunggu verifikasi admin.',

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 9.5,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 14),

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

                          for (int i = 0; i < details.length; i++) ...[
                            details[i],

                            if (i < details.length - 1)
                              const SizedBox(height: 5),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      !identified
                          ? 'Simpan atau salin kode tiket untuk '
                                'Cek Status. Pilihan Tanpa Identitas '
                                'tidak menerima email konfirmasi.'
                          : (emailSent
                                ? 'Informasi tiket telah dikirim '
                                      'ke $email. Periksa juga '
                                      'folder Spam.'
                                : 'Simpan kode tiket Anda. '
                                      'Konfirmasi pengiriman email '
                                      'belum tersedia.'),

                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 9,
                        height: 1.35,
                        color: Color(0xFF555555),
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Laporan Diterima berarti laporan telah '
                      'diverifikasi dan diterima oleh admin.',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 9,
                        height: 1.35,
                        color: Color(0xFF555555),
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () => _copyTicket(context),

                      icon: const Icon(Icons.copy_rounded, size: 16),

                      label: const Text(
                        'Salin Kode Tiket',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                CekStatusPage(initialKeyword: requestNumber),
                          ),
                        );
                      },

                      child: const Text(
                        'Cek Status',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  _button(
                    'Kembali Ke Beranda',
                    115,
                    const Color(0xFF7C8CF5),

                    () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),

                  const SizedBox(width: 28),

                  _button(
                    'Buat Pengaduan Lagi',
                    125,
                    const Color(0xFF58C761),

                    () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          const SnackBar(content: Text('Kode tiket berhasil disalin.')),
        );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Kode tiket belum berhasil disalin.')),
        );
    }
  }

  Widget _button(
    String text,
    double width,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: width,
      height: 40,

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
          text,
          textAlign: TextAlign.center,

          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _detail(
    String label,
    String value, {
    String? asset,
    IconData? icon,
    int? maxLines = 2,
    Color background = const Color(0xFFD6EBF8),
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
          Container(
            width: 44,
            height: 44,

            alignment: Alignment.center,

            padding: const EdgeInsets.all(5),

            decoration: BoxDecoration(
              color: background,

              borderRadius: BorderRadius.circular(9),
            ),

            child: asset == null
                ? Icon(
                    icon ?? Icons.description_outlined,
                    color: const Color(0xFF1762B0),
                  )
                : Image.asset(
                    asset,
                    fit: BoxFit.contain,

                    errorBuilder: (_, error, stack) {
                      return const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF1762B0),
                      );
                    },
                  ),
          ),

          const SizedBox(width: 11),

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

                  maxLines: maxLines,
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
