import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

const _statusLabels = <String, String>{
  'menunggu_verifikasi': 'Menunggu Verifikasi',
  'diterima': 'Laporan Diterima',
  'dalam_penanganan': 'Dalam Penanganan',
  'selesai': 'Penanganan Selesai',
};

const _background = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
  ),
);

class KampusAmanSuccessPage extends StatefulWidget {
  const KampusAmanSuccessPage({
    required this.requestNumber,
    required this.accessKey,
    required this.submittedAt,
    this.status = 'menunggu_verifikasi',
    this.emailSent = false,
    super.key,
  });

  final String requestNumber;
  final String accessKey;
  final String status;
  final DateTime submittedAt;
  final bool emailSent;

  @override
  State<KampusAmanSuccessPage> createState() => _KampusAmanSuccessPageState();
}

class _KampusAmanSuccessPageState extends State<KampusAmanSuccessPage> {
  bool _showKey = false;

  Future<void> _copy() async {
    try {
      await Clipboard.setData(
        ClipboardData(
          text:
              'Kode tiket: ${widget.requestNumber}\n'
              'Kunci akses: ${widget.accessKey}',
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kode tiket dan kunci akses disalin. '
              'Simpan di tempat pribadi.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum berhasil menyalin data akses.')),
        );
      }
    }
  }

  Widget _detail(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 60),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF969696), width: 0.7),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFD6EBF8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1762B0)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF1762B0),
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF202020),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.submittedAt;

    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Kampus Aman', style: TextStyle(fontSize: 16)),
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00D51D),
                      size: 82,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Laporan Berhasil Dikirim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Simpan kode tiket dan kunci akses '
                      'untuk memeriksa status laporan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, height: 1.4),
                    ),

                    const SizedBox(height: 16),

                    _detail(
                      'Kode Tiket',
                      widget.requestNumber,
                      Icons.confirmation_number_outlined,
                    ),

                    _detail(
                      'Status',
                      _statusLabels[widget.status] ?? 'Status Belum Tersedia',
                      Icons.hourglass_empty_rounded,
                    ),

                    _detail(
                      'Tanggal Pengajuan',
                      dateLabel,
                      Icons.calendar_month_outlined,
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF9D8EE7),
                          width: 0.6,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Kunci Akses Pribadi',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: _showKey
                                    ? 'Sembunyikan kunci'
                                    : 'Tampilkan kunci',
                                onPressed: () {
                                  setState(() {
                                    _showKey = !_showKey;
                                  });
                                },
                                icon: Icon(
                                  _showKey
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                          SelectableText(
                            _showKey ? widget.accessKey : '••••••••••••••••',
                            style: const TextStyle(fontSize: 14),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Jangan bagikan kunci ini. Siapa pun yang '
                            'memilikinya bersama kode tiket dapat '
                            'memeriksa status laporan.',
                            style: TextStyle(fontSize: 9.5, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextButton.icon(
                      onPressed: _copy,
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: const Text(
                        'Salin Kode Tiket dan Kunci Akses',
                        style: TextStyle(fontSize: 10.5),
                      ),
                    ),

                    if (widget.emailSent)
                      const Text(
                        'Server mengonfirmasi pengiriman email '
                        'ke alamat yang Anda izinkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9.5, height: 1.4),
                      ),

                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => KampusAmanStatusPage(
                              requestNumber: widget.requestNumber,
                              accessKey: widget.accessKey,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Cek Status Kampus Aman',
                        style: TextStyle(fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _button('Kembali ke Beranda', const Color(0xFF8C99F2), () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }),
                  _button('Buat Laporan Lagi', const Color(0xFF59C467), () {
                    Navigator.of(context).pop();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 125,
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
        child: Text(text, style: const TextStyle(fontSize: 9.5)),
      ),
    );
  }
}

// =========================================================
// CEK STATUS PRIBADI KAMPUS AMAN
// =========================================================

class KampusAmanStatusPage extends StatefulWidget {
  const KampusAmanStatusPage({
    this.requestNumber = '',
    this.accessKey = '',
    super.key,
  });

  final String requestNumber;
  final String accessKey;

  @override
  State<KampusAmanStatusPage> createState() => _KampusAmanStatusPageState();
}

class _KampusAmanStatusPageState extends State<KampusAmanStatusPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _number;
  late final TextEditingController _key;

  bool _loading = false;

  String? _status;
  String? _message;

  @override
  void initState() {
    super.initState();

    _number = TextEditingController(text: widget.requestNumber);

    _key = TextEditingController(text: widget.accessKey);
  }

  @override
  void dispose() {
    _number.dispose();
    _key.dispose();

    super.dispose();
  }

  Future<void> _check() async {
    if (_loading || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _status = null;
      _message = null;
    });

    try {
      final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

      final response = await http
          .post(
            Uri.parse('$base/pengaduan/kampus-aman/status'),
            headers: {'Accept': 'application/json'},
            body: {
              'request_number': _number.text.trim(),
              'access_key': _key.text.trim(),
            },
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) {
        return;
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        setState(() {
          _message = 'Layanan belum tersedia atau data akses tidak cocok.';
        });

        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          data is! Map ||
          data['success'] != true) {
        setState(() {
          _message =
              'Status belum dapat ditampilkan. '
              'Periksa kode tiket dan kunci akses.';
        });

        return;
      }

      final detail = data['data'];

      if (detail is! Map || !_statusLabels.containsKey(detail['status'])) {
        throw const FormatException();
      }

      setState(() {
        _status = _statusLabels[detail['status']];
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Status belum dapat dimuat. Coba kembali nanti.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
        title: const Text('Status Kampus Aman', style: TextStyle(fontSize: 16)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan kode tiket dan kunci akses pribadi.',
                  style: TextStyle(fontSize: 10.5, height: 1.4),
                ),

                const SizedBox(height: 16),

                _input('Kode Tiket', _number),

                const SizedBox(height: 13),

                _input('Kunci Akses', _key, secret: true),

                const SizedBox(height: 18),

                Center(
                  child: SizedBox(
                    width: 125,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _check,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C99F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        _loading ? 'Memeriksa...' : 'Cek Status',
                        style: const TextStyle(fontSize: 9.5),
                      ),
                    ),
                  ),
                ),

                if (_status != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      'Status: $_status',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],

                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _message!,
                    style: const TextStyle(fontSize: 11, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    bool secret = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          enabled: !_loading,
          obscureText: secret,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 11,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
          validator: (value) {
            if (value?.trim().isEmpty ?? true) {
              return '$label wajib diisi';
            }

            return null;
          },
        ),
      ],
    );
  }
}
