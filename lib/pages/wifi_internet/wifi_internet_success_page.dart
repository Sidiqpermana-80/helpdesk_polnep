import 'package:flutter/material.dart';

import '../cek_status/cek_status_page.dart';

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
    this.isAccess = false,
    this.phone = '',
    this.email = '',
    this.department = '',
    this.description = '',
    this.emailSent = false,
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

  final bool isAccess;
  final String phone;
  final String email;
  final String department;
  final String description;
  final bool emailSent;

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

  @override
  Widget build(BuildContext context) {
    final String serviceName = isAccess
        ? 'Akses Login/Wi-Fi'
        : 'Gangguan Jaringan';

    final List<Widget> details = [
      _buildDetailCard(
        asset: 'assets/images/pp.png',
        label: 'Nama Pengguna',
        value: fullName,
      ),

      _buildDetailCard(
        asset: 'assets/images/book.png',
        label: isAccess ? 'NIM' : 'NIM / NIP',
        value: identifierValue,
      ),

      if (isAccess) ...[
        _buildDetailCard(
          asset: 'assets/images/pp.png',
          label: 'No. HP',
          value: phone,
          icon: Icons.phone_android_rounded,
        ),

        _buildDetailCard(
          asset: 'assets/images/email.png',
          label: 'Email',
          value: email,
        ),

        _buildDetailCard(
          asset: 'assets/images/mhs.png',
          label: 'Jurusan',
          value: department,
        ),

        _buildDetailCard(
          asset: 'assets/images/berkas.png',
          label: 'Keterangan',
          value: description,
          maxLines: null,
        ),
      ] else ...[
        _buildDetailCard(
          asset: 'assets/images/gedung.png',
          label: 'Nama Gedung',
          value: buildingName,
        ),

        _buildDetailCard(
          asset: 'assets/images/door.png',
          label: 'Ruangan',
          value: roomName,
        ),
      ],

      _buildDetailCard(
        asset: 'assets/images/tanggal.png',
        label: 'Tanggal',
        value: formattedDate,
        iconBackground: const Color(0xFF3C69C9),
        imagePadding: 8,
      ),

      _buildDetailCard(
        asset: 'assets/images/ticket.png',
        label: 'No. Tiket',
        value: requestNumber,
        iconBackground: const Color(0xFF39AD4A),
        imagePadding: 7,
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
          padding: const EdgeInsets.fromLTRB(7, 5, 7, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2),

                child: Text(
                  serviceName,
                  style: const TextStyle(
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
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00D51D),
                      size: 80,
                    ),

                    const SizedBox(height: 5),

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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),

                      child: Text(
                        isAccess
                            ? 'Permohonan akses login/Wi-Fi Anda telah '
                                  'kami terima dan akan ditindaklanjuti '
                                  'oleh tim Helpdesk.'
                            : 'Laporan Kendala WIFI / Internet anda '
                                  'telah kami terima dan akan '
                                  'ditindaklanjuti oleh tim Helpdesk',

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

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

                          for (int i = 0; i < details.length; i++) ...[
                            details[i],

                            if (i < details.length - 1)
                              const SizedBox(height: 4),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      emailSent
                          ? 'Informasi tiket sudah dikirim ke $email. '
                                'Periksa juga folder Spam.'
                          : 'Simpan nomor tiket Anda. '
                                'Konfirmasi pengiriman email '
                                'belum tersedia.',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: emailSent
                            ? const Color(0xFF29823A)
                            : const Color(0xFF666666),
                        fontSize: 9,
                        height: 1.35,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) {
                              return CekStatusPage(
                                initialKeyword: requestNumber,
                              );
                            },
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

              const SizedBox(height: 21),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  _buildButton(
                    label: 'Kembali Ke Beranda',
                    width: 105,
                    color: const Color(0xFF7C8CF5),

                    onPressed: () {
                      Navigator.of(
                        context,
                      ).popUntil((Route<dynamic> route) => route.isFirst);
                    },
                  ),

                  const SizedBox(width: 28),

                  _buildButton(
                    label: 'Buat Pertanyaan Lagi',
                    width: 125,
                    color: const Color(0xFF58C761),

                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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

  Widget _buildButton({
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

  Widget _buildDetailCard({
    required String asset,
    required String label,
    required String value,
    Color iconBackground = const Color(0xFFD6EBF8),
    double imagePadding = 5,
    int? maxLines = 2,
    IconData? icon,
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
          Container(
            width: 44,
            height: 44,

            alignment: Alignment.center,

            padding: EdgeInsets.all(imagePadding),

            decoration: BoxDecoration(
              color: iconBackground,

              borderRadius: BorderRadius.circular(9),
            ),

            child: icon != null
                ? Icon(icon, color: const Color(0xFF1762B0))
                : Image.asset(
                    asset,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,

                    errorBuilder: (context, error, stackTrace) {
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
