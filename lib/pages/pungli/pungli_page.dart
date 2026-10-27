import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../services/queue_notification_service.dart';
import '../cek_status/cek_status_page.dart';
import 'pungli_success_page.dart';
import '../../services/pungli_device_sync_service.dart';

class PungliPage extends StatefulWidget {
  const PungliPage({super.key});

  @override
  State<PungliPage> createState() => _PungliPageState();
}

class _PungliPageState extends State<PungliPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  final _otherLocation = TextEditingController();
  final _party = TextEditingController();
  final _incidentTime = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();

  static const List<String> _extensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
  ];

  bool? _identified;

  String? _locationId;

  List<Map<String, String>> _locations = [];

  XFile? _supportFile;

  bool _loading = true;
  bool _refreshing = false;
  bool _submitting = false;
  bool _pickingFile = false;

  int _formVersion = 0;

  bool get _busy => _submitting || _pickingFile;

  String get _base {
    return ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
  }

  List<TextEditingController> get _identityControllers {
    return [_name, _nim, _phone, _email];
  }

  List<TextEditingController> get _controllers {
    return [
      ..._identityControllers,
      _otherLocation,
      _party,
      _incidentTime,
      _amount,
      _description,
    ];
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocations());
  }

  // =========================================================
  // UNIT / LOKASI DARI ADMIN
  // =========================================================

  Future<void> _loadLocations() async {
    if (_refreshing || _busy) {
      return;
    }

    _refreshing = true;

    if (mounted) {
      setState(() => _loading = true);
    }

    List<Map<String, String>> locations = [];

    try {
      final response = await http
          .get(
            Uri.parse('$_base/master-options/pungli/location'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true &&
          decoded['data'] is List) {
        final options = <String, Map<String, String>>{};

        for (final item in decoded['data'] as List) {
          if (item is! Map) {
            continue;
          }

          final id = item['id']?.toString() ?? '';

          final name = item['option_label']?.toString().trim() ?? '';

          if ((int.tryParse(id) ?? 0) > 0 &&
              name.isNotEmpty &&
              name.toLowerCase() != 'lainnya') {
            options[id] = {'id': id, 'name': name};
          }
        }

        locations = options.values.toList();
      }
    } catch (_) {
      locations = [];
    } finally {
      if (mounted) {
        setState(() {
          _locations = locations;

          if (_locationId != 'other' &&
              !_locations.any((item) => item['id'] == _locationId)) {
            _locationId = null;
          }

          _loading = false;
          _formVersion++;
        });
      }

      _refreshing = false;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // =========================================================
  // UKURAN INPUT MENGIKUTI FORM APLIKASI
  // =========================================================

  InputDecoration _decoration(String hint, {Widget? prefixIcon}) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),
      prefixIcon: prefixIcon,
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

  Widget _fieldIcon(String label) {
    IconData icon;

    if (label == 'Nama Lengkap') {
      icon = Icons.person_rounded;
    } else if (label == 'NIM / NIP') {
      icon = Icons.menu_book_rounded;
    } else if (label == 'No. HP') {
      icon = Icons.phone_android_rounded;
    } else if (label == 'Email') {
      icon = Icons.email_outlined;
    } else if (label == 'Lokasi Lainnya') {
      icon = Icons.location_on_outlined;
    } else if (label.startsWith('Pihak')) {
      icon = Icons.person_search_outlined;
    } else if (label.startsWith('Waktu')) {
      icon = Icons.access_time_rounded;
    } else {
      icon = Icons.payments_outlined;
    }

    return Icon(icon, size: 18, color: const Color(0xFF168DE2));
  }

  Widget _text(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
    int maxLength = 150,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(label),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Color(0xFF202020), fontSize: 16),
          keyboardType: keyboard,
          textInputAction: TextInputAction.next,
          textCapitalization: keyboard == TextInputType.text
              ? TextCapitalization.words
              : TextCapitalization.none,
          inputFormatters: formatters,
          maxLength: maxLength,
          decoration: _decoration(
            hint,
            prefixIcon: _fieldIcon(label),
          ).copyWith(counterText: ''),
          validator:
              validator ??
              (value) {
                if (isRequired && (value?.trim().isEmpty ?? true)) {
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
  // PILIHAN IDENTITAS
  // =========================================================

  Widget _buildIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Pilihan Identitas'),

        FormField<bool>(
          key: ValueKey('identity-$_formVersion'),
          initialValue: _identified,
          validator: (_) {
            return _identified == null
                ? 'Pilih cara pelaporan terlebih dahulu'
                : null;
          },
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _identityButton(
                        'Cantumkan Identitas',
                        true,
                        Icons.person_outline_rounded,
                        field,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _identityButton(
                        'Tanpa Identitas',
                        false,
                        Icons.visibility_off_outlined,
                        field,
                      ),
                    ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        fontSize: 8.5,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 13),

        if (_identified == true) ...[
          _text(
            'Nama Lengkap',
            _name,
            'Masukkan nama lengkap',
            validator: (value) {
              return (value?.trim().length ?? 0) < 3
                  ? 'Nama lengkap minimal 3 karakter'
                  : null;
            },
          ),

          _text(
            'NIM / NIP',
            _nim,
            'Masukkan NIM atau NIP',
            keyboard: TextInputType.number,
            maxLength: 30,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              return RegExp(r'^[0-9]{5,30}$').hasMatch(value?.trim() ?? '')
                  ? null
                  : 'NIM harus terdiri dari 5–30 angka';
            },
          ),

          _text(
            'No. HP',
            _phone,
            'Masukkan nomor HP aktif',
            keyboard: TextInputType.phone,
            maxLength: 16,
            formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
            validator: (value) {
              return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Nomor HP harus terdiri dari 10–15 angka';
            },
          ),

          _text(
            'Email',
            _email,
            'Masukkan email aktif',
            keyboard: TextInputType.emailAddress,
            validator: (value) {
              return RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Format email tidak valid';
            },
          ),
        ],

        if (_identified == false)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Nama, NIM, nomor HP, dan email tidak dikirim. '
              'Periksa kembali uraian dan bukti jika tidak ingin '
              'mencantumkan identitas. '
              'Simpan kode tiket untuk Cek Status.',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _identityButton(
    String label,
    bool value,
    IconData icon,
    FormFieldState<bool> field,
  ) {
    final selected = _identified == value;

    final iconColor = value ? const Color(0xFF6757D9) : const Color(0xFFFFB74D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: _busy
            ? null
            : () {
                if (_identified == value) {
                  return;
                }

                FocusScope.of(context).unfocus();

                setState(() {
                  _identified = value;

                  if (!value) {
                    for (final controller in _identityControllers) {
                      controller.clear();
                    }
                  }
                });

                field.didChange(value);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF5FF) : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: selected
                  ? const Color(0xFF3AA7F5)
                  : const Color(0xFF8D8D8D),
              width: selected ? 1.3 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, size: 17, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF202020),
                    fontSize: 10.5,
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // UNIT / LOKASI
  // =========================================================

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Unit / Lokasi Kejadian'),

        DropdownButtonFormField<String>(
          key: ValueKey('location-$_formVersion'),
          initialValue: _locationId,
          isExpanded: true,
          isDense: true,
          dropdownColor: const Color(0xFFF0F7FF),
          style: const TextStyle(color: Color(0xFF202020), fontSize: 16),
          decoration: _decoration(
            _loading ? 'Memuat lokasi...' : 'Pilih unit / lokasi kejadian',
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: Color(0xFF168DE2),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          items: [
            ..._locations.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'],
                child: Text(
                  item['name']!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }),
            const DropdownMenuItem<String>(
              value: 'other',
              child: Text('Lainnya', style: TextStyle(fontSize: 16)),
            ),
          ],
          onChanged: _loading
              ? null
              : (value) {
                  setState(() {
                    _locationId = value;
                  });
                },
          validator: (value) {
            if (_loading) {
              return 'Daftar lokasi masih dimuat';
            }

            return value == null ? 'Unit / lokasi wajib dipilih' : null;
          },
        ),

        if (!_loading && _locations.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Daftar lokasi dari admin belum tersedia. '
              'Gunakan Lainnya untuk menulis lokasi.',
              style: TextStyle(
                fontSize: 8.5,
                height: 1.3,
                color: Color(0xFF777777),
              ),
            ),
          ),

        const SizedBox(height: 13),

        if (_locationId == 'other')
          _text(
            'Lokasi Lainnya',
            _otherLocation,
            'Tuliskan unit atau lokasi kejadian',
            maxLength: 200,
          ),
      ],
    );
  }

  // =========================================================
  // FILE PENDUKUNG
  // =========================================================

  Future<void> _pickFile() async {
    if (_busy) {
      return;
    }

    setState(() => _pickingFile = true);

    try {
      const group = XTypeGroup(
        label: 'Bukti Pendukung',
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
        setState(() => _supportFile = file);
      }
    } catch (_) {
      if (mounted) {
        _message('Gagal memilih file pendukung.');
      }
    } finally {
      if (mounted) {
        setState(() => _pickingFile = false);
      }
    }
  }

  Widget _buildFileInput() {
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
                borderRadius: BorderRadius.horizontal(left: Radius.circular(7)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _supportFile?.name ?? 'Belum ada file',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: _supportFile == null
                            ? const Color(0xFF777777)
                            : const Color(0xFF202020),
                      ),
                    ),
                  ),
                  if (_supportFile != null)
                    InkWell(
                      onTap: _busy
                          ? null
                          : () {
                              setState(() {
                                _supportFile = null;
                              });
                            },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: Color(0xFF666666),
                        ),
                      ),
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
                color: Color(0xFFFFB52D),
                size: 18,
              ),
              label: Text(
                _pickingFile ? 'Memilih...' : 'Choose File',
                style: const TextStyle(fontSize: 8.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58C761),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(7),
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
  // TOMBOL MENGIKUTI FORM APLIKASI
  // =========================================================

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 40,
          child: ElevatedButton(
            onPressed: _busy || _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5868FF),
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
                    _clearForm();
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
            child: RefreshIndicator(
              onRefresh: _loadLocations,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          'Pungli',
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 13),
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
                                  color: Color(0xFF24477C),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Laporkan dugaan pungutan liar yang '
                                'Anda alami, saksikan, atau ketahui.',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 9,
                                  height: 1.35,
                                ),
                              ),

                              const SizedBox(height: 13),

                              _buildIdentity(),

                              const Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFF707070),
                              ),

                              const SizedBox(height: 13),

                              _buildLocation(),

                              _text(
                                'Pihak yang Diduga Terkait (Opsional)',
                                _party,
                                'Nama atau jabatan, jika diketahui',
                                isRequired: false,
                              ),

                              _text(
                                'Waktu Kejadian (Opsional)',
                                _incidentTime,
                                'Contoh: 15 Oktober 2026, pagi hari',
                                isRequired: false,
                              ),

                              _text(
                                'Nominal yang Diminta / Dibayarkan '
                                    '(Opsional)',
                                _amount,
                                'Rupiah, contoh: 50000',
                                keyboard: TextInputType.number,
                                maxLength: 12,
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                isRequired: false,
                              ),

                              _title('Laporkan Kejadian'),

                              SizedBox(
                                height: 115,
                                child: TextFormField(
                                  controller: _description,
                                  style: const TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 16,
                                  ),
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
                                    'Ceritakan kejadian yang Anda alami, '
                                    'saksikan, atau ketahui.',
                                  ),
                                  validator: (value) {
                                    return (value?.trim().isEmpty ?? true)
                                        ? 'Laporan kejadian wajib diisi'
                                        : null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              _title('Upload Bukti Pendukung (Opsional)'),

                              _buildFileInput(),

                              const SizedBox(height: 7),

                              const Center(
                                child: Text(
                                  'Upload hanya jika diperlukan '
                                  'file pendukung',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 8,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Center(
                                child: Text(
                                  'Format: JPG, PNG, PDF, DOC, DOCX, '
                                  'XLS atau XLSX. Maksimal 5 MB.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF777777),
                                    fontSize: 7.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              // INFORMASI
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  10,
                                ),

                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F7FF),
                                  borderRadius: BorderRadius.circular(8),

                                  border: Border.all(
                                    color: const Color(0xFF9D8EE7),
                                    width: 0.6,
                                  ),
                                ),

                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 31,
                                      height: 31,

                                      child: Image.asset(
                                        'assets/images/seru.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    const Expanded(
                                      child: Text(
                                        'Periksa kembali isi laporan dan lampiran sebelum mengirim.\n'
                                        'Jika memilih tanpa identitas, pastikan uraian dan bukti '
                                        'tidak memuat identitas yang ingin Anda rahasiakan. '
                                        'Simpan kode tiket untuk memeriksa status laporan.',

                                        style: TextStyle(
                                          color: Color(0xFF303030),
                                          fontSize: 9,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              _buildButtons(),
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
      ),
    );
  }

  // =========================================================
  // PENGIRIMAN
  // =========================================================

  Future<void> _submit() async {
    if (_busy || _loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _message('Silakan lengkapi data yang masih kosong.');
      return;
    }

    final identified = _identified!;
    final locationId = _locationId!;

    final locationName = locationId == 'other'
        ? _otherLocation.text.trim()
        : _locations.firstWhere((item) => item['id'] == locationId)['name']!;

    final email = identified ? _email.text.trim().toLowerCase() : '';

    final file = _supportFile;

    // Identitas hanya ikut dikirim ketika dipilih.
    final fields = <String, String>{
      'reporter_mode': identified ? 'identified' : 'anonymous',

      'description': _description.text.trim(),

      if (locationId == 'other')
        'location_other': locationName
      else
        'location_id': locationId,

      if (_party.text.trim().isNotEmpty) 'alleged_party': _party.text.trim(),

      if (_incidentTime.text.trim().isNotEmpty)
        'incident_time_text': _incidentTime.text.trim(),

      if (_amount.text.trim().isNotEmpty) 'amount': _amount.text.trim(),

      if (identified) ...{
        'full_name': _name.text.trim(),
        'nim': _nim.text.trim(),
        'phone': _phone.text.trim(),
        'email': email,
      },
    };

    setState(() => _submitting = true);

    final client = http.Client();

    bool requestStarted = false;

    try {
      await QueueNotificationService.instance.enableNotifications();

      final fcmToken = await QueueNotificationService.instance
          .tokenForSubmission();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_base/pengaduan/pungli'),
      );

      request.headers['Accept'] = 'application/json';

      request.fields.addAll(fields);

      if (fcmToken != null && fcmToken.isNotEmpty) {
        request.fields.addAll({
          'fcm_token': fcmToken,
          'device_platform': 'android',
        });
      }

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

      requestStarted = true;

      final response = await client
          .send(request)
          .then((streamed) {
            return http.Response.fromStream(streamed);
          })
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 404 || response.statusCode == 405) {
        if (mounted) {
          _message(
            'Layanan pengaduan Pungli '
            'belum tersedia di server.',
          );
        }

        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }

      if ((response.statusCode != 200 && response.statusCode != 201) ||
          decoded['success'] != true) {
        if (!mounted) {
          return;
        }

        if (response.statusCode >= 500) {
          _unknownResult(identified, email);
        } else {
          String message =
              decoded['message']?.toString() ?? 'Pengaduan gagal dikirim.';

          final errors = decoded['errors'];

          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;

            if (first is List && first.isNotEmpty) {
              message = first.first.toString();
            }
          }

          _message(message);
        }

        return;
      }

      final data = decoded['data'];

      if (data is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final id = int.tryParse(data['id']?.toString() ?? '') ?? 0;

      final number = data['request_number']?.toString().trim() ?? '';

      final status = data['status']?.toString() ?? 'menunggu_verifikasi';

      if (id <= 0 ||
          number.isEmpty ||
          !['menunggu_verifikasi', 'diterima'].contains(status)) {
        throw const FormatException();
      }

      final submittedAt =
          DateTime.tryParse(
            data['submitted_at']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now();

      final syncKey = data['device_sync_key']?.toString() ?? '';

      if (syncKey.isNotEmpty) {
        try {
          await PungliDeviceSyncService.instance.rememberTicket(
            id: id,
            key: syncKey,
          );
        } catch (_) {
          debugPrint('PUNGLI: kunci sinkronisasi belum berhasil disimpan.');
        }
      }

      unawaited(
        QueueNotificationService.instance.showPungliTicketCreated(
          ticketId: id,
          requestNumber: number,
        ),
      );

      if (!mounted) {
        return;
      }

      _clearForm();

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PungliSuccessPage(
            requestNumber: number,
            identified: identified,
            email: email,
            locationName: locationName,
            submittedAt: submittedAt,
            status: status,
            emailSent: identified && data['email_sent'] == true,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      if (requestStarted) {
        _unknownResult(identified, email);
      } else {
        _message(
          'File pendukung tidak dapat dibaca. '
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

  void _clearForm() {
    _formKey.currentState?.reset();

    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      _identified = null;
      _locationId = null;
      _supportFile = null;
      _formVersion++;
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  void _unknownResult(bool identified, String email) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            identified
                ? 'Hasil pengajuan belum dapat dipastikan. '
                      'Cek Status dengan email sebelum mengirim ulang.'
                : 'Hasil pengajuan belum dapat dipastikan. '
                      'Jangan langsung mengirim ulang. '
                      'Jika sudah memiliki kode tiket, '
                      'periksa melalui Cek Status.',
          ),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Cek Status',
            onPressed: () {
              if (!mounted) {
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CekStatusPage(initialKeyword: identified ? email : ''),
                ),
              );
            },
          ),
        ),
      );
  }
}
