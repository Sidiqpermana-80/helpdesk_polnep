import 'package:flutter/material.dart';

class FasilitasRuanganSuccessPage extends StatelessWidget {
  const FasilitasRuanganSuccessPage({
    required this.requestNumber,
    required this.fullName,
    required this.identifierValue,
    required this.buildingName,
    required this.floor,
    required this.roomName,
    required this.facilityType,
    required this.submittedAt,
    super.key,
  });

  final String requestNumber;
  final String fullName;
  final String identifierValue;
  final String buildingName;
  final String floor;
  final String roomName;
  final String facilityType;
  final DateTime submittedAt;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FF),

        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        leadingWidth: 45,

        leading: IconButton(
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
              const Padding(
                padding: EdgeInsets.only(left: 2),

                child: Text(
                  'Fasilitas Ruangan',
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
                  'Home / Fasilitas Ruangan',
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

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17),

                      child: Text(
                        'Laporan fasilitas ruangan Anda telah kami terima '
                        'dan akan ditindaklanjuti oleh Tim Helpdesk.',
                        textAlign: TextAlign.center,

                        style: TextStyle(
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

                          _detail(
                            asset: 'assets/images/pp.png',
                            label: 'Nama Pengguna',
                            value: fullName,
                          ),

                          const SizedBox(height: 4),

                          _detail(
                            asset: 'assets/images/book.png',
                            label: 'NIM / NIP',
                            value: identifierValue,
                          ),

                          const SizedBox(height: 4),

                          _detail(
                            asset: 'assets/images/gedung.png',
                            label: 'Nama Gedung',
                            value: buildingName,
                          ),

                          const SizedBox(height: 4),

                          _detail(
                            asset: 'assets/images/tangga.png',
                            label: 'Lantai',
                            value: floor,
                          ),

                          const SizedBox(height: 4),

                          _detail(
                            asset: 'assets/images/door.png',
                            label: 'Nama / Nomor Ruangan',
                            value: roomName,
                          ),

                          const SizedBox(height: 4),

                          _detail(
                            asset: 'assets/images/rumah.png',
                            label: 'Jenis Fasilitas',
                            value: facilityType,
                          ),

                          const SizedBox(height: 4),

                          _detail(
                            asset: 'assets/images/kalender.png',
                            label: 'Tanggal',
                            value: formattedDate,
                            iconBackgroundColor: const Color(0xFF315DB3),
                          ),

                          const SizedBox(height: 4),

                          _detail(
                            asset: 'assets/images/ticket.png',
                            label: 'No. Tiket',
                            value: requestNumber,
                            iconBackgroundColor: const Color(0xFF36A83A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 21),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
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
                        style: TextStyle(fontSize: 8.5),
                      ),
                    ),
                  ),

                  const SizedBox(width: 28),

                  SizedBox(
                    width: 120,
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
                        'Buat Laporan Lagi',
                        style: TextStyle(fontSize: 8.5),
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

  Widget _detail({
    required String asset,
    required String label,
    required String value,
    Color iconBackgroundColor = const Color(0xFFD6EBF8),
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

            padding: const EdgeInsets.all(6),

            decoration: BoxDecoration(
              color: iconBackgroundColor,

              borderRadius: BorderRadius.circular(9),
            ),

            child: Image.asset(asset, fit: BoxFit.contain),
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

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 10.5,
                    height: 1.15,
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
