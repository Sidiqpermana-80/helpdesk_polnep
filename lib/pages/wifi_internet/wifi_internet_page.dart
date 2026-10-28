import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../services/queue_notification_service.dart';
import '../../services/wifi_device_sync_service.dart';
import 'wifi_internet_success_page.dart';

class WifiInternetPage extends StatefulWidget {
  const WifiInternetPage({super.key});

  @override
  State<WifiInternetPage> createState() => _WifiInternetPageState();
}

class _WifiInternetPageState extends State<WifiInternetPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _identifier = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _room = TextEditingController();
  final _description = TextEditingController();

  bool _isAccess = false;
  bool _isSubmitting = false;
  bool _loading = true;
  bool _refreshing = false;

  int _formVersion = 0;

  String? _building;
  String? _department;

  List<String> _buildings = [];
  List<Map<String, String>> _departments = [];

  @override
  void initState() {
    super.initState();

    unawaited(_refreshPage());
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _identifier,
      _phone,
      _email,
      _room,
      _description,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  // =========================================================
  // MASTER DATA
  // =========================================================

  Future<List<Map<String, String>>> _options(String field) async {
    try {
      final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

      final response = await http
          .get(
            Uri.parse('$base/master-options/wifi_internet/$field'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));

      final decoded = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          decoded is! Map ||
          decoded['success'] != true ||
          decoded['data'] is! List) {
        return [];
      }

      final result = <String, Map<String, String>>{};

      for (final item in decoded['data'] as List) {
        if (item is! Map) {
          continue;
        }

        final id = item['id']?.toString() ?? '';

        final name = item['option_label']?.toString().trim() ?? '';

        if ((int.tryParse(id) ?? 0) > 0 && name.isNotEmpty) {
          result[id] = {'id': id, 'name': name};
        }
      }

      return result.values.toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _refreshPage() async {
    if (_refreshing || _isSubmitting) {
      return;
    }

    _refreshing = true;

    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final options = await Future.wait([
        _options('building_name'),
        _options('department'),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _buildings = options[0].map((item) => item['name']!).toSet().toList();

        _departments = options[1];

        if (!_buildings.contains(_building)) {
          _building = null;
        }

        if (!_departments.any((item) => item['id'] == _department)) {
          _department = null;
        }

        _loading = false;
        _formVersion++;
      });
    } finally {
      _refreshing = false;
    }
  }

  // =========================================================
  // TAMPILAN FIELD
  // =========================================================

  InputDecoration _decoration(String hint, {Widget? icon}) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),

      prefixIcon: icon,

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

  Widget _icon(IconData icon) {
    return Icon(icon, size: 18, color: const Color(0xFF168DE2));
  }

  Widget _asset(String path) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Image.asset(path, width: 18, height: 18, fit: BoxFit.contain),
    );
  }

  Widget _title(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
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
    Widget? icon,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(label),

        TextFormField(
          controller: controller,

          style: const TextStyle(fontSize: 16),

          keyboardType: keyboard,
          textInputAction: TextInputAction.next,

          textCapitalization: keyboard == TextInputType.text
              ? TextCapitalization.words
              : TextCapitalization.none,

          inputFormatters: formatters,
          maxLength: maxLength,

          decoration: _decoration(hint, icon: icon).copyWith(counterText: ''),

          validator:
              validator ??
              (value) {
                if (value?.trim().isEmpty ?? true) {
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
  // PILIHAN JENIS LAYANAN
  // =========================================================

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Jenis Layanan'),

        Row(
          children: [
            Expanded(
              child: _serviceButton(
                title: 'Gangguan Jaringan',
                isAccess: false,
                icon: Icons.wifi_off_rounded,
                iconColor: const Color(0xFF6757D9),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _serviceButton(
                title: 'Akses Login/Wi-Fi',
                isAccess: true,
                icon: Icons.wifi_lock_rounded,
                iconColor: const Color(0xFFFFB74D),
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),
      ],
    );
  }

  Widget _serviceButton({
    required String title,
    required bool isAccess,
    required IconData icon,
    required Color iconColor,
  }) {
    final selected = _isAccess == isAccess;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(5),

        onTap: _isSubmitting
            ? null
            : () {
                if (_isAccess == isAccess) {
                  return;
                }

                FocusScope.of(context).unfocus();

                setState(() {
                  _isAccess = isAccess;
                });
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
                  title,
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
  // HALAMAN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,

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
              onRefresh: _refreshPage,

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
                    // HEADER
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,

                          constraints: const BoxConstraints(),

                          onPressed: _isSubmitting
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
                          'Wi-Fi / Internet',

                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // PENJELASAN FORM
                    SizedBox(
                      width: double.infinity,
                      height: 108,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 7, top: 3),

                              child: Text(
                                _isAccess
                                    ? 'Ajukan bantuan\n'
                                          'akses login\n'
                                          'Wi-Fi kampus\n'
                                          'POLNEP'
                                    : 'Laporkan kendala\n'
                                          'jaringan pada\n'
                                          'gedung atau\n'
                                          'ruangan di POLNEP',

                                style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 20.5,
                                  height: 1.08,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 135,
                            height: 100,

                            child: Image.asset(
                              'assets/images/pc.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // FORM
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
                        absorbing: _isSubmitting,

                        child: Form(
                          key: _formKey,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              _buildServiceSelection(),

                              const Text(
                                'Data Pelapor',

                                style: TextStyle(
                                  color: Color(0xFF24477C),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // NAMA
                              _text(
                                'Nama',
                                _name,
                                'Masukkan nama lengkap',

                                maxLength: 150,
                                icon: _icon(Icons.person_rounded),

                                validator: (value) {
                                  if ((value?.trim().length ?? 0) < 3) {
                                    return 'Nama minimal 3 karakter';
                                  }

                                  return null;
                                },
                              ),

                              // NIM / NIP
                              _text(
                                _isAccess ? 'NIM' : 'NIM / NIP',
                                _identifier,

                                _isAccess
                                    ? 'Masukkan NIM'
                                    : 'Masukkan NIM atau NIP',

                                keyboard: TextInputType.number,
                                icon: _icon(Icons.menu_book_rounded),

                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(30),
                                ],
                              ),

                              // NO HP KHUSUS AKSES LOGIN
                              if (_isAccess)
                                _text(
                                  'No. HP',
                                  _phone,
                                  'Masukkan nomor HP aktif',

                                  keyboard: TextInputType.phone,

                                  icon: _icon(Icons.phone_android_rounded),

                                  formatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9+]'),
                                    ),

                                    LengthLimitingTextInputFormatter(16),
                                  ],

                                  validator: (value) {
                                    final valid = RegExp(
                                      r'^\+?[0-9]{10,15}$',
                                    ).hasMatch(value?.trim() ?? '');

                                    if (!valid) {
                                      return 'Nomor HP harus terdiri dari '
                                          '10–15 angka';
                                    }

                                    return null;
                                  },
                                ),

                              const SizedBox(height: 5),

                              const Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFF707070),
                              ),

                              const SizedBox(height: 13),

                              // EMAIL
                              _text(
                                'Email',
                                _email,
                                'Masukkan email aktif',

                                maxLength: 150,
                                keyboard: TextInputType.emailAddress,

                                icon: _icon(Icons.email_outlined),

                                validator: (value) {
                                  final valid = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(value?.trim() ?? '');

                                  if (!valid) {
                                    return 'Format email tidak valid';
                                  }

                                  return null;
                                },
                              ),

                              if (_isAccess) ...[
                                // JURUSAN
                                _title('Jurusan'),

                                DropdownButtonFormField<String>(
                                  key: ValueKey('department-$_formVersion'),

                                  initialValue: _department,
                                  isExpanded: true,
                                  isDense: true,
                                  dropdownColor: const Color(0xFFF0F7FF),

                                  decoration: _decoration(
                                    _loading
                                        ? 'Memuat jurusan...'
                                        : 'Pilih jurusan',

                                    icon: _icon(Icons.school_rounded),
                                  ),

                                  style: const TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 16,
                                  ),

                                  items: _departments.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item['id'],

                                      child: Text(
                                        item['name']!,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),

                                  onChanged: _loading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _department = value;
                                          });
                                        },

                                  validator: (value) {
                                    if (_loading) {
                                      return 'Jurusan masih dimuat';
                                    }

                                    if (_departments.isEmpty) {
                                      return 'Jurusan belum tersedia. '
                                          'Tarik halaman untuk memuat ulang.';
                                    }

                                    if (value == null) {
                                      return 'Jurusan wajib dipilih';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 13),
                              ] else ...[
                                // DETAIL LOKASI
                                const Text(
                                  'Detail Lokasi',

                                  style: TextStyle(
                                    color: Color(0xFF24477C),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                _title('Nama Gedung'),

                                DropdownButtonFormField<String>(
                                  key: ValueKey('building-$_formVersion'),

                                  initialValue: _building,
                                  isExpanded: true,
                                  isDense: true,
                                  dropdownColor: const Color(0xFFF0F7FF),

                                  decoration: _decoration(
                                    _loading
                                        ? 'Memuat nama gedung...'
                                        : 'Pilih nama gedung',

                                    icon: _asset('assets/images/gedung.png'),
                                  ),

                                  style: const TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 16,
                                  ),

                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 17,
                                  ),

                                  items: _buildings.map((name) {
                                    return DropdownMenuItem<String>(
                                      value: name,

                                      child: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),

                                  onChanged: _loading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _building = value;
                                          });
                                        },

                                  validator: (value) {
                                    if (_loading) {
                                      return 'Daftar gedung masih dimuat';
                                    }

                                    if (_buildings.isEmpty) {
                                      return 'Daftar gedung tidak tersedia';
                                    }

                                    if (value == null) {
                                      return 'Nama gedung wajib dipilih';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 13),

                                _text(
                                  'Ruangan',
                                  _room,
                                  'Contoh: Lab Komputer / Ruang 203',

                                  maxLength: 150,

                                  icon: _asset('assets/images/door.png'),
                                ),
                              ],

                              // KETERANGAN / DESKRIPSI
                              _title(
                                _isAccess ? 'Keterangan' : 'Deskripsi Keluhan',
                              ),

                              SizedBox(
                                height: 115,

                                child: TextFormField(
                                  controller: _description,

                                  style: const TextStyle(fontSize: 16),

                                  expands: true,
                                  minLines: null,
                                  maxLines: null,

                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(5000),
                                  ],

                                  keyboardType: TextInputType.multiline,

                                  textCapitalization:
                                      TextCapitalization.sentences,

                                  textAlignVertical: TextAlignVertical.top,

                                  decoration: _decoration(
                                    _isAccess
                                        ? 'Jelaskan kebutuhan akses login/Wi-Fi'
                                        : 'Jelaskan kendala Wifi / Internet '
                                              'yang dialami',
                                  ),

                                  validator: (value) {
                                    if (value?.trim().isEmpty ?? true) {
                                      return _isAccess
                                          ? 'Keterangan wajib diisi'
                                          : 'Deskripsi keluhan wajib diisi';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 11),

                    // INFORMASI
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),

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
                              'Pastikan data yang Anda isi sudah benar.\n'
                              'Jelaskan kendala secara rinci agar petugas dapat '
                              'menindaklanjuti laporan Anda.',

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

                    // TOMBOL KIRIM DAN RESET
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        SizedBox(
                          width: 100,
                          height: 40,

                          child: ElevatedButton(
                            onPressed: _isSubmitting || _loading
                                ? null
                                : _submitForm,

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

                            child: _isSubmitting
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
                            onPressed: _isSubmitting
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

                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
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
  // KIRIM FORM
  // =========================================================

  Future<void> _submitForm() async {
    if (_isSubmitting || _loading) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _message('Silakan lengkapi data yang masih kosong.');

      return;
    }

    // Simpan nilai form sebelum proses asynchronous.
    final access = _isAccess;

    final name = _name.text.trim();
    final identifier = _identifier.text.trim();
    final email = _email.text.trim().toLowerCase();

    final phone = access ? _phone.text.trim() : '';

    final departmentId = _department;

    final department = access
        ? _departments.firstWhere((item) => item['id'] == departmentId)['name']!
        : '';

    final building = access ? '' : _building!;
    final room = access ? '' : _room.text.trim();

    final description = _description.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Token boleh null. Pengajuan tetap dapat dilanjutkan.
      final fcmToken = await QueueNotificationService.instance
          .tokenForSubmission();

      final response = await http
          .post(
            Uri.parse(ApiConfig.createWifiInternet),

            headers: {'Accept': 'application/json'},

            body: {
              'request_kind': access ? 'access' : 'network',

              'full_name': name,
              'identifier_value': identifier,
              'email': email,
              'description': description,

              if (fcmToken != null && fcmToken.isNotEmpty) ...{
                'fcm_token': fcmToken,
                'device_platform': 'android',
              },

              if (access) ...{
                'phone': phone,
                'department_id': departmentId!,
              } else ...{
                'building_name': building,
                'room_name': room,
              },
            },
          )
          .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final successfulStatus =
          response.statusCode == 200 || response.statusCode == 201;

      if (!successfulStatus || decoded['success'] != true) {
        if (!mounted) {
          return;
        }

        if (response.statusCode >= 500) {
          _message(
            'Hasil pengajuan belum dapat dipastikan. '
            'Cek Status dengan email $email sebelum mengirim ulang.',
          );
        } else {
          final errors = decoded['errors'];

          String message =
              decoded['message']?.toString() ?? 'Pengajuan gagal dikirim.';

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

      if (id <= 0 || number.isEmpty) {
        throw const FormatException();
      }

      final submittedAt =
          DateTime.tryParse(
            data['submitted_at']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now();

      // Simpan kunci untuk pembaruan token perangkat berikutnya.
      final syncKey = data['device_sync_key']?.toString() ?? '';

      try {
        await WifiDeviceSyncService.instance.rememberTicket(
          id: id,
          key: syncKey,
        );
      } catch (_) {
        debugPrint('WIFI: kunci sinkronisasi belum berhasil disimpan.');
      }

      // Konfirmasi lokal setelah laporan berhasil dibuat.
      unawaited(
        QueueNotificationService.instance.showWifiTicketCreated(
          ticketId: id,
          requestNumber: number,
          isAccess: access,
        ),
      );

      if (!mounted) {
        return;
      }

      _clearForm();

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WifiInternetSuccessPage(
            requestNumber: number,

            fullName: name,
            identifierValue: identifier,

            buildingName: building,
            roomName: room,

            status: data['status']?.toString() ?? 'menunggu_verifikasi',

            estimatedResponse:
                data['estimated_response']?.toString() ?? '1-2 Hari Kerja',

            submittedAt: submittedAt,

            isAccess: access,
            phone: phone,
            email: email,
            department: department,
            description: description,

            emailSent: data['email_sent'] == true,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        _message(
          'Hasil pengajuan belum dapat dipastikan. '
          'Cek Status dengan email $email sebelum mengirim ulang.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // =========================================================
  // RESET DAN PESAN
  // =========================================================

  void _clearForm() {
    _formKey.currentState?.reset();

    for (final controller in [
      _name,
      _identifier,
      _phone,
      _email,
      _room,
      _description,
    ]) {
      controller.clear();
    }

    setState(() {
      _building = null;
      _department = null;

      _formVersion++;
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),

          behavior: SnackBarBehavior.floating,

          duration: const Duration(seconds: 5),
        ),
      );
  }
}
