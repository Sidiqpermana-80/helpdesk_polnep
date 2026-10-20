import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../services/queue_notification_service.dart';
import 'kampus_aman_success_page.dart';

class KampusAmanPage extends StatefulWidget {
  const KampusAmanPage({super.key});

  @override
  State<KampusAmanPage> createState() => _KampusAmanPageState();
}

class _KampusAmanPageState extends State<KampusAmanPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _identifier = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _location = TextEditingController();
  final _time = TextEditingController();
  final _party = TextEditingController();
  final _description = TextEditingController();

  static const _types = <String, String>{
    'fisik': 'Kekerasan Fisik',
    'psikis': 'Kekerasan Psikis',
    'perundungan': 'Perundungan',
    'seksual': 'Kekerasan / Pelecehan Seksual',
    'diskriminasi_intoleransi': 'Diskriminasi / Intoleransi',
    'lainnya': 'Lainnya',
    'belum_tahu': 'Belum Tahu',
  };

  static const _extensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
  ];

  String? _identity;
  String? _position;
  String? _type;

  String _contact = 'none';

  XFile? _file;

  bool _submitting = false;
  bool _picking = false;

  int _version = 0;

  bool get _busy => _submitting || _picking;

  bool get _identified => _identity == 'identified';

  String get _base {
    return ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
  }

  List<TextEditingController> get _identityControllers => [
    _name,
    _identifier,
    _phone,
    _email,
  ];

  List<TextEditingController> get _controllers => [
    ..._identityControllers,
    _location,
    _time,
    _party,
    _description,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // =========================================================
  // DEKORASI FIELD
  // =========================================================

  InputDecoration _decoration(String hint, {IconData? icon}) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 18, color: const Color(0xFF168DE2)),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 42),
      isDense: false,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      border: border(const Color(0xFF8D8D8D), 0.8),
      enabledBorder: border(const Color(0xFF8D8D8D), 0.8),
      focusedBorder: border(const Color(0xFF3AA7F5), 1.4),
      errorBorder: border(Colors.red, 1),
      focusedErrorBorder: border(Colors.red, 1.3),
      errorStyle: const TextStyle(fontSize: 9),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF202020),
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _text(
    String label,
    TextEditingController controller,
    String hint, {
    required IconData icon,
    bool requiredField = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(label),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 16, color: Color(0xFF202020)),
          keyboardType: keyboard,
          textInputAction: TextInputAction.next,
          textCapitalization: keyboard == TextInputType.text
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          maxLength: 200,
          decoration: _decoration(hint, icon: icon).copyWith(counterText: ''),
          validator:
              validator ??
              (value) {
                if (requiredField && (value?.trim().isEmpty ?? true)) {
                  return '$label wajib diisi';
                }

                return null;
              },
        ),
        const SizedBox(height: 13),
      ],
    );
  }

  // =========================================================
  // PILIHAN BERBENTUK TOMBOL
  // =========================================================

  Widget _choices(
    String label,
    Map<String, String> options,
    String? value,
    ValueChanged<String> onChanged, {
    bool requiredField = false,
    int columns = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(label),
        FormField<String>(
          key: ValueKey('$label-$_version'),
          initialValue: value,
          validator: (_) {
            if (requiredField && value == null) {
              return '$label wajib dipilih';
            }

            return null;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final count = constraints.maxWidth < 260 ? 1 : columns;

                    final width =
                        (constraints.maxWidth - (count - 1) * 8) / count;

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in options.entries)
                          SizedBox(
                            width: width,
                            child: Material(
                              color: value == entry.key
                                  ? const Color(0xFFEAF5FF)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(
                                  color: value == entry.key
                                      ? const Color(0xFF3AA7F5)
                                      : const Color(0xFF8D8D8D),
                                  width: value == entry.key ? 1.3 : 0.8,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _busy
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();

                                        onChanged(entry.key);
                                        field.didChange(entry.key);
                                      },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 55,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    entry.value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: const Color(0xFF202020),
                                      fontWeight: value == entry.key
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 9),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 13),
      ],
    );
  }

  // =========================================================
  // IDENTITAS PELAPOR
  // =========================================================

  Widget _identityFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _choices(
          'Pilihan Identitas',
          const {
            'identified': 'Cantumkan Identitas',
            'anonymous': 'Tanpa Identitas',
          },
          _identity,
          (value) {
            setState(() {
              _identity = value;

              if (!_identified) {
                for (final controller in _identityControllers) {
                  controller.clear();
                }

                _contact = 'none';
              }
            });
          },
          requiredField: true,
        ),

        if (_identified) ...[
          _text(
            'Nama Lengkap',
            _name,
            'Masukkan nama lengkap',
            icon: Icons.person_outline_rounded,
            requiredField: true,
          ),

          _text(
            'NIM / NIP (Opsional)',
            _identifier,
            'Masukkan jika memiliki NIM / NIP',
            icon: Icons.badge_outlined,
          ),

          _text(
            'No. HP (Opsional)',
            _phone,
            'Isi jika aman untuk dicantumkan',
            icon: Icons.phone_android_rounded,
            keyboard: TextInputType.phone,
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.isEmpty) {
                return _contact == 'phone'
                    ? 'Isi nomor HP untuk dihubungi'
                    : null;
              }

              return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(text)
                  ? null
                  : 'Nomor HP harus terdiri dari 10–15 angka';
            },
          ),

          _text(
            'Email (Opsional)',
            _email,
            'Isi jika aman untuk dicantumkan',
            icon: Icons.mail_outline_rounded,
            keyboard: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.isEmpty) {
                return _contact == 'email' ? 'Isi email untuk dihubungi' : null;
              }

              return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)
                  ? null
                  : 'Format email tidak valid';
            },
          ),

          _choices(
            'Boleh Menghubungi Saya Melalui',
            const {
              'none': 'Tidak Dihubungi',
              'phone': 'No. HP',
              'email': 'Email',
            },
            _contact,
            (value) {
              setState(() => _contact = value);
            },
            columns: 3,
          ),
        ],

        if (_identity == 'anonymous')
          const Padding(
            padding: EdgeInsets.only(bottom: 13),
            child: Text(
              'Nama, NIM/NIP, nomor HP, dan email tidak dikirim. '
              'Periksa isi laporan dan lampiran jika tidak ingin '
              'mencantumkan identitas.',
              style: TextStyle(
                fontSize: 9,
                height: 1.4,
                color: Color(0xFF555555),
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================
  // PILIH FILE
  // =========================================================

  Future<void> _pickFile() async {
    if (_busy) {
      return;
    }

    setState(() => _picking = true);

    try {
      const group = XTypeGroup(
        label: 'File Pendukung',
        extensions: _extensions,
      );

      final file = await openFile(acceptedTypeGroups: [group]);

      if (file == null) {
        return;
      }

      final extension = file.name.split('.').last.toLowerCase();

      if (!_extensions.contains(extension)) {
        if (mounted) {
          _message('Format file tidak didukung.');
        }

        return;
      }

      final size = await file.length();

      if (size <= 0 || size > 5 * 1024 * 1024) {
        if (mounted) {
          _message('File tidak boleh kosong dan maksimal 5 MB.');
        }

        return;
      }

      if (mounted) {
        setState(() => _file = file);
      }
    } catch (_) {
      if (mounted) {
        _message('File belum berhasil dipilih.');
      }
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Widget _fileInput() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFD7D7D7),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _file?.name ?? 'Belum ada file',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5),
                    ),
                  ),
                  if (_file != null)
                    IconButton(
                      tooltip: 'Hapus file',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      iconSize: 16,
                      onPressed: _busy
                          ? null
                          : () {
                              setState(() => _file = null);
                            },
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 105,
            height: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _pickFile,
              icon: const Icon(
                Icons.folder,
                size: 18,
                color: Color(0xFFFFB52D),
              ),
              label: Text(
                _picking ? 'Memilih...' : 'Choose File',
                style: const TextStyle(fontSize: 9.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58C761),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TOMBOL
  // =========================================================

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 40,
          child: ElevatedButton(
            onPressed: _busy ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C99F2),
              disabledBackgroundColor: const Color(0xFFADB5F5),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Kirim Data',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 22),

        SizedBox(
          width: 72,
          height: 40,
          child: ElevatedButton(
            onPressed: _busy
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    _clear();
                    _message('Form berhasil dikosongkan.');
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF59C467),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // HALAMAN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9FF),
        body: SafeArea(
          child: Container(
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
                ],
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Kembali',
                        onPressed: _busy
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'Kampus Aman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 112,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 7, top: 2),
                            child: Text(
                              'Laporkan kekerasan,\n'
                              'perundungan, atau\n'
                              'pelecehan di\n'
                              'lingkungan POLNEP.',
                              style: TextStyle(
                                fontSize: 20.5,
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 100,
                          child: Image.asset(
                            'assets/images/mhs.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, error, stack) {
                              return const Icon(
                                Icons.shield_outlined,
                                size: 80,
                                color: Color(0xFF168DE2),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const KampusAmanStatusPage(),
                                ),
                              );
                            },
                      child: const Text(
                        'Cek Status Kampus Aman',
                        style: TextStyle(fontSize: 10.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: const Color(0xFFD6E9F7),
                        width: 0.6,
                      ),
                    ),
                    child: AbsorbPointer(
                      absorbing: _busy,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Laporan',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF24477C),
                              ),
                            ),

                            const SizedBox(height: 13),

                            _identityFields(),

                            _choices(
                              'Posisi Pelapor',
                              const {
                                'experienced': 'Mengalami Sendiri',
                                'witness': 'Menyaksikan',
                                'representative': 'Mewakili Orang Lain',
                              },
                              _position,
                              (value) {
                                setState(() => _position = value);
                              },
                              requiredField: true,
                              columns: 3,
                            ),

                            _title('Jenis Kejadian (Opsional)'),

                            DropdownButtonFormField<String>(
                              key: ValueKey('type-$_version'),
                              initialValue: _type,
                              isExpanded: true,
                              style: const TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 16,
                              ),
                              decoration: _decoration(
                                'Pilih jenis kejadian',
                                icon: Icons.list_alt_rounded,
                              ),
                              items: _types.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(
                                    entry.value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _type = value);
                              },
                            ),

                            const SizedBox(height: 13),

                            _text(
                              'Lokasi Kejadian',
                              _location,
                              'Nama ruangan, area kampus, atau media daring',
                              icon: Icons.location_on_outlined,
                              requiredField: true,
                            ),

                            _text(
                              'Waktu Kejadian (Opsional)',
                              _time,
                              'Tanggal pasti atau perkiraan waktu',
                              icon: Icons.access_time_rounded,
                            ),

                            _text(
                              'Pihak yang Dilaporkan (Opsional)',
                              _party,
                              'Nama atau keterangan pihak terkait, jika diketahui',
                              icon: Icons.person_search_outlined,
                            ),

                            _title('Laporkan Kejadian'),

                            SizedBox(
                              height: 115,
                              child: TextFormField(
                                controller: _description,
                                style: const TextStyle(fontSize: 16),
                                expands: true,
                                minLines: null,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textAlignVertical: TextAlignVertical.top,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(5000),
                                ],
                                decoration: _decoration(
                                  'Ceritakan kejadian sejauh yang Anda nyaman '
                                  'sampaikan. Jelaskan bantuan yang dibutuhkan '
                                  'jika ada.',
                                ),
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Laporan kejadian wajib diisi';
                                  }

                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 13),

                            _title('Upload File Pendukung (Opsional)'),

                            _fileInput(),

                            const SizedBox(height: 7),

                            const Text(
                              'File pendukung tidak wajib. Maksimal 5 MB.\n'
                              'Format: JPG, JPEG, PNG, PDF, DOC, DOCX, XLS, XLSX.',
                              style: TextStyle(
                                fontSize: 9,
                                height: 1.4,
                                color: Color(0xFF666666),
                              ),
                            ),

                            const SizedBox(height: 16),

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
                              child: const Text(
                                'Periksa kembali isi laporan dan lampiran '
                                'sebelum mengirim. Simpan kode tiket dan '
                                'kunci akses setelah pengajuan berhasil.',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  height: 1.4,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            _buttons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // KIRIM LAPORAN
  // =========================================================

  Future<void> _submit() async {
    if (_busy) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _message('Silakan periksa kembali isian form.');
      return;
    }

    final identified = _identified;
    final contact = identified ? _contact : 'none';
    final file = _file;

    final fields = <String, String>{
      'reporter_mode': identified ? 'identified' : 'anonymous',
      'reporter_position': _position!,
      'contact_preference': contact,
      'location': _location.text.trim(),
      'description': _description.text.trim(),

      'incident_type': ?_type,

      if (_time.text.trim().isNotEmpty) 'incident_time_text': _time.text.trim(),

      if (_party.text.trim().isNotEmpty) 'reported_party': _party.text.trim(),

      if (identified) ...{
        'full_name': _name.text.trim(),

        if (_identifier.text.trim().isNotEmpty)
          'identifier_value': _identifier.text.trim(),

        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),

        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      },
    };

    setState(() => _submitting = true);

    final client = http.Client();
    bool sent = false;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_base/pengaduan/kampus-aman'),
      );

      request.headers['Accept'] = 'application/json';
      request.fields.addAll(fields);

      if (file != null) {
        final bytes = await file.readAsBytes();

        if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
          if (mounted) {
            _message('File tidak boleh kosong dan maksimal 5 MB.');
          }

          return;
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'support_file',
            bytes,
            filename: file.name,
          ),
        );
      }

      sent = true;

      final response = await client
          .send(request)
          .then((streamed) => http.Response.fromStream(streamed))
          .timeout(const Duration(seconds: 40));

      if (!mounted) {
        return;
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        _message('Layanan Kampus Aman belum tersedia di server.');
        return;
      }

      if (response.statusCode >= 500) {
        _message(
          'Hasil pengajuan belum dapat dipastikan. '
          'Jangan langsung mengirim ulang.',
        );
        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          decoded['success'] != true) {
        var message =
            decoded['message']?.toString() ?? 'Laporan belum berhasil dikirim.';

        final errors = decoded['errors'];

        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;

          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        }

        _message(message);
        return;
      }

      final data = decoded['data'];

      if (data is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final id = int.tryParse(data['id']?.toString() ?? '') ?? 0;
      final number = data['request_number']?.toString().trim() ?? '';
      final key = data['access_key']?.toString().trim() ?? '';

      if (id <= 0 || number.isEmpty || key.isEmpty) {
        throw const FormatException();
      }

      final submittedAt =
          DateTime.tryParse(
            data['submitted_at']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now();

      final status = data['status']?.toString() ?? 'menunggu_verifikasi';

      final emailSent = contact == 'email' && data['email_sent'] == true;

      try {
        await QueueNotificationService.instance.showKampusAmanCreated(
          ticketId: id,
        );
      } catch (_) {
        // Notifikasi gagal tidak membatalkan laporan yang sudah tersimpan.
      }

      if (!mounted) {
        return;
      }

      _clear();

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => KampusAmanSuccessPage(
            requestNumber: number,
            accessKey: key,
            submittedAt: submittedAt,
            status: status,
            emailSent: emailSent,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        _message(
          sent
              ? 'Hasil pengajuan belum dapat dipastikan. '
                    'Jangan langsung mengirim ulang.'
              : 'File pendukung tidak dapat dibaca. '
                    'Pilih ulang file tersebut.',
        );
      }
    } finally {
      client.close();

      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  // =========================================================
  // RESET DAN PESAN
  // =========================================================

  void _clear() {
    _formKey.currentState?.reset();

    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      _identity = null;
      _position = null;
      _type = null;
      _contact = 'none';
      _file = null;
      _version++;
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
  }
}
