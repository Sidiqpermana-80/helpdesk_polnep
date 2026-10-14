import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'ult_success_page.dart';
import 'ult_queue_time_field.dart';
import '../../services/ult_notification_service.dart';

class UltPage extends StatefulWidget {
  const UltPage({super.key});

  @override
  State<UltPage> createState() => _UltPageState();
}

class _UltPageState extends State<UltPage> {
  // FORM
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // FIELD BERSAMA
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // FIELD MAHASISWA
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  String? _selectedSemester;
  String? _selectedService;

  // FIELD UMUM
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  String? _selectedGeneralService;
  String? _selectedCategory;

  // TANGGAL DAN JAM ANTRIAN
  DateTime _selectedQueueDate = DateUtils.dateOnly(UltQueueSchedule.now());

  int? _selectedQueueMinute;

  bool _isQueueDatePickerOpen = false;

  // MASTER DATA
  List<String> _semesterOptions = <String>[];
  List<String> _studentServices = <String>[];
  List<String> _generalServices = <String>[];

  final Map<String, String> _studentServiceNotifications = <String, String>{};

  // LOADING
  bool _isLoadingSemesters = true;
  bool _isLoadingStudentServices = true;
  bool _isLoadingGeneralServices = true;

  // ERROR MASTER DATA
  bool _semesterLoadError = false;
  bool _studentServiceLoadError = false;
  bool _generalServiceLoadError = false;

  bool _isSubmitting = false;

  int _formVersion = 0;

  @override
  void initState() {
    super.initState();

    _loadSemesterOptions();
    _loadStudentServices();
    _loadGeneralServices();
  }

  Future<void> _refreshPage() async {
    await Future.wait([
      _loadSemesterOptions(),
      _loadStudentServices(),
      _loadGeneralServices(),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();

    _identifierController.dispose();
    _departmentController.dispose();

    _originController.dispose();
    _destinationController.dispose();

    super.dispose();
  }

  // NOTIFIKASI LAYANAN MAHASISWA
  String? get _selectedStudentServiceNotification {
    final String service = _selectedService?.trim() ?? '';

    if (service.isEmpty) {
      return null;
    }

    final String notification =
        _studentServiceNotifications[service]?.trim() ?? '';

    if (notification.isEmpty) {
      return null;
    }

    return notification;
  }

  // Mengikuti aturan layanan sebelumnya:
  // layanan mahasiswa dengan pemberitahuan admin
  // tidak dapat mengambil antrean hari ini.
  bool get _isDirectQueueDisabled {
    return _selectedCategory == 'Mahasiswa' &&
        _selectedStudentServiceNotification != null;
  }

  // FETCH MASTER DATA
  Future<List<Map<String, dynamic>>> _fetchMasterOptionItems(String url) async {
    final http.Response response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 20));

    debugPrint('ANTRIAN MASTER STATUS: ${response.statusCode}');
    debugPrint('ANTRIAN MASTER RESPONSE: ${response.body}');

    final dynamic decoded = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        decoded is! Map<String, dynamic> ||
        decoded['success'] != true) {
      throw const FormatException('Data master tidak valid.');
    }

    final dynamic rawData = decoded['data'];

    if (rawData is! List) {
      throw const FormatException('Daftar master tidak valid.');
    }

    return rawData.whereType<Map<String, dynamic>>().toList();
  }

  // LOAD SEMESTER
  Future<void> _loadSemesterOptions() async {
    if (mounted) {
      setState(() {
        _isLoadingSemesters = true;
        _semesterLoadError = false;
      });
    }

    try {
      final List<Map<String, dynamic>> items = await _fetchMasterOptionItems(
        ApiConfig.antrianSemesterOptions,
      );

      final List<String> options = items
          .map(
            (Map<String, dynamic> item) =>
                item['option_label']?.toString().trim() ?? '',
          )
          .where((String value) => value.isNotEmpty)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _semesterOptions = options;

        if (_selectedSemester != null &&
            !_semesterOptions.contains(_selectedSemester)) {
          _selectedSemester = null;
        }

        _isLoadingSemesters = false;
        _semesterLoadError = false;
      });
    } on TimeoutException {
      debugPrint('LOAD ANTRIAN SEMESTER ERROR: TimeoutException');

      if (!mounted) {
        return;
      }

      setState(() {
        _semesterOptions = <String>[];
        _isLoadingSemesters = false;
        _semesterLoadError = true;
      });
    } catch (e) {
      debugPrint('LOAD ANTRIAN SEMESTER ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _semesterOptions = <String>[];
        _isLoadingSemesters = false;
        _semesterLoadError = true;
      });
    }
  }

  // LOAD LAYANAN MAHASISWA
  Future<void> _loadStudentServices() async {
    if (mounted) {
      setState(() {
        _isLoadingStudentServices = true;
        _studentServiceLoadError = false;
      });
    }

    try {
      final List<Map<String, dynamic>> items = await _fetchMasterOptionItems(
        ApiConfig.antrianStudentServiceOptions,
      );

      final List<String> services = <String>[];
      final Map<String, String> notifications = <String, String>{};

      for (final Map<String, dynamic> item in items) {
        final String label = item['option_label']?.toString().trim() ?? '';

        if (label.isEmpty) {
          continue;
        }

        services.add(label);

        final String notification =
            item['notification_text']?.toString().trim() ?? '';

        if (notification.isNotEmpty) {
          notifications[label] = notification;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _studentServices = services;

        _studentServiceNotifications
          ..clear()
          ..addAll(notifications);

        if (_selectedService != null &&
            !_studentServices.contains(_selectedService)) {
          _selectedService = null;
        }

        _adjustQueueDateForService();

        _isLoadingStudentServices = false;
        _studentServiceLoadError = false;
      });
    } on TimeoutException {
      debugPrint('LOAD STUDENT SERVICES ERROR: TimeoutException');

      if (!mounted) {
        return;
      }

      setState(() {
        _studentServices = <String>[];
        _studentServiceNotifications.clear();

        _isLoadingStudentServices = false;
        _studentServiceLoadError = true;
      });
    } catch (e) {
      debugPrint('LOAD STUDENT SERVICES ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _studentServices = <String>[];
        _studentServiceNotifications.clear();

        _isLoadingStudentServices = false;
        _studentServiceLoadError = true;
      });
    }
  }

  // LOAD LAYANAN UMUM
  Future<void> _loadGeneralServices() async {
    if (mounted) {
      setState(() {
        _isLoadingGeneralServices = true;
        _generalServiceLoadError = false;
      });
    }

    try {
      final List<Map<String, dynamic>> items = await _fetchMasterOptionItems(
        ApiConfig.antrianGeneralServiceOptions,
      );

      final List<String> options = items
          .map(
            (Map<String, dynamic> item) =>
                item['option_label']?.toString().trim() ?? '',
          )
          .where((String value) => value.isNotEmpty)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _generalServices = options;

        if (_selectedGeneralService != null &&
            !_generalServices.contains(_selectedGeneralService)) {
          _selectedGeneralService = null;
        }

        _isLoadingGeneralServices = false;
        _generalServiceLoadError = false;
      });
    } on TimeoutException {
      debugPrint('LOAD GENERAL SERVICES ERROR: TimeoutException');

      if (!mounted) {
        return;
      }

      setState(() {
        _generalServices = <String>[];
        _isLoadingGeneralServices = false;
        _generalServiceLoadError = true;
      });
    } catch (e) {
      debugPrint('LOAD GENERAL SERVICES ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _generalServices = <String>[];
        _isLoadingGeneralServices = false;
        _generalServiceLoadError = true;
      });
    }
  }

  // FIELD DECORATION
  InputDecoration _fieldDecoration({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 42),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF3AA7F5), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
      ),
    );
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
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _refreshPage,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
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
                      const SizedBox(width: 10),
                      const Text(
                        'ULT',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // HERO
                  SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 7, top: 2),
                            child: Text(
                              'Isi form dibawah\n'
                              'untuk\n'
                              'mendapatkan\n'
                              'nomor antrian tiket',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 20.5,
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 155,
                          height: 115,
                          child: Image.asset(
                            'assets/images/antrian.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 7),

                  // CARD FORM
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD6E9F7),
                        width: 0.7,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Kategori',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Row(
                            children: [
                              Expanded(
                                child: _categoryButton(
                                  title: 'Mahasiswa',
                                  value: 'Mahasiswa',
                                  asset: 'assets/images/mhs.png',
                                  iconColor: const Color(0xFF6757D9),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _categoryButton(
                                  title: 'Umum',
                                  value: 'Umum',
                                  asset: 'assets/images/tendik.png',
                                  iconColor: const Color(0xFFFFB74D),
                                ),
                              ),
                            ],
                          ),

                          if (_selectedCategory != null) ...[
                            const SizedBox(height: 18),

                            const Divider(
                              color: Color(0xFF555555),
                              thickness: 1,
                            ),

                            const SizedBox(height: 12),

                            // TANGGAL ANTRIAN
                            _fieldTitle('Tanggal Antrian'),
                            _queueDateField(),

                            const SizedBox(height: 13),

                            // JAM ANTRIAN
                            _fieldTitle('Jam Antrian'),
                            UltQueueTimeField(
                              date: _selectedQueueDate,
                              selectedMinute: _selectedQueueMinute,
                              enabled:
                                  !_isSubmitting && !_isQueueDatePickerOpen,
                              onChanged: (int minute) {
                                setState(() {
                                  _selectedQueueMinute = minute;
                                });
                              },
                            ),

                            const SizedBox(height: 8),

                            _queueDateInformation(),

                            const SizedBox(height: 18),

                            const Divider(
                              color: Color(0xFF555555),
                              thickness: 1,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              _selectedCategory == 'Mahasiswa'
                                  ? 'Silakan isi data mahasiswa berikut.'
                                  : 'Silakan isi data pengunjung berikut.',
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 9.5,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // NAMA
                            _fieldTitle('Nama'),
                            TextFormField(
                              controller: _nameController,
                              enabled: !_isSubmitting,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/pp.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              validator: (String? value) {
                                final String name = value?.trim() ?? '';

                                if (name.isEmpty) {
                                  return 'Nama wajib diisi';
                                }

                                if (name.length < 3) {
                                  return 'Nama belum sesuai';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),

                            // NIM MAHASISWA
                            if (_selectedCategory == 'Mahasiswa') ...[
                              _fieldTitle('NIM'),
                              TextFormField(
                                controller: _identifierController,
                                enabled: !_isSubmitting,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                decoration: _fieldDecoration(
                                  hintText: 'Masukkan NIM',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'assets/images/book.png',
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                validator: (String? value) {
                                  final String nim = value?.trim() ?? '';

                                  if (nim.isEmpty) {
                                    return 'NIM wajib diisi';
                                  }

                                  if (nim.length < 5) {
                                    return 'NIM belum sesuai';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 13),
                            ],

                            // ASAL PENGUNJUNG UMUM
                            if (_selectedCategory == 'Umum') ...[
                              _fieldTitle('Dari'),
                              TextFormField(
                                controller: _originController,
                                enabled: !_isSubmitting,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: _fieldDecoration(
                                  hintText: 'Masukkan asal / instansi',
                                  prefixIcon: const Icon(
                                    Icons.business_rounded,
                                    size: 20,
                                    color: Color(0xFF6757D9),
                                  ),
                                ),
                                validator: (String? value) {
                                  final String origin = value?.trim() ?? '';

                                  if (origin.isEmpty) {
                                    return 'Dari wajib diisi';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 13),
                            ],

                            // NO. HP
                            _fieldTitle('No. HP'),
                            TextFormField(
                              controller: _phoneController,
                              enabled: !_isSubmitting,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(13),
                              ],
                              decoration: _fieldDecoration(
                                hintText: 'Masukkan nomor HP aktif',
                                prefixIcon: const Icon(
                                  Icons.phone_android_rounded,
                                  size: 20,
                                  color: Color(0xFF168DE2),
                                ),
                              ),
                              validator: (String? value) {
                                final String phone = value?.trim() ?? '';

                                if (phone.isEmpty) {
                                  return 'Nomor HP wajib diisi';
                                }

                                if (phone.length < 10) {
                                  return 'Nomor HP belum sesuai';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),

                            // EMAIL
                            _fieldTitle('Email'),
                            TextFormField(
                              controller: _emailController,
                              enabled: !_isSubmitting,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              decoration: _fieldDecoration(
                                hintText: 'Masukkan email aktif',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/email.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              validator: (String? value) {
                                final String email = value?.trim() ?? '';

                                if (email.isEmpty) {
                                  return 'Email wajib diisi';
                                }

                                final RegExp emailRegex = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                );

                                if (!emailRegex.hasMatch(email)) {
                                  return 'Format email tidak valid';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),

                            // DATA MAHASISWA
                            if (_selectedCategory == 'Mahasiswa') ...[
                              _fieldTitle('Jurusan'),
                              TextFormField(
                                controller: _departmentController,
                                enabled: !_isSubmitting,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: _fieldDecoration(
                                  hintText: 'Masukkan nama jurusan',
                                  prefixIcon: const Icon(
                                    Icons.account_balance_rounded,
                                    size: 20,
                                    color: Color(0xFF6757D9),
                                  ),
                                ),
                                validator: (String? value) {
                                  final String department = value?.trim() ?? '';

                                  if (department.isEmpty) {
                                    return 'Jurusan wajib diisi';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 13),

                              // SEMESTER
                              _fieldTitle('Semester'),
                              DropdownButtonFormField<String>(
                                key: ValueKey('semester-$_formVersion'),
                                initialValue: _selectedSemester,
                                isExpanded: true,
                                menuMaxHeight: 300,
                                dropdownColor: const Color(0xFFF0F7FF),
                                decoration: _fieldDecoration(
                                  hintText: _isLoadingSemesters
                                      ? 'Memuat semester...'
                                      : _semesterLoadError
                                      ? 'Gagal memuat semester'
                                      : 'Pilih Semester',
                                  prefixIcon: const Icon(
                                    Icons.school_rounded,
                                    size: 20,
                                    color: Color(0xFF3EA94C),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: Color(0xFF222222),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF202020),
                                  fontSize: 14,
                                ),
                                items: _semesterOptions.map((String semester) {
                                  return DropdownMenuItem<String>(
                                    value: semester,
                                    child: Text(
                                      'Semester $semester',
                                      style: const TextStyle(
                                        color: Color(0xFF202020),
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged:
                                    _isSubmitting ||
                                        _isLoadingSemesters ||
                                        _semesterLoadError ||
                                        _semesterOptions.isEmpty
                                    ? null
                                    : (String? value) {
                                        setState(() {
                                          _selectedSemester = value;
                                        });
                                      },
                                validator: (String? value) {
                                  if (_isLoadingSemesters) {
                                    return 'Daftar semester masih dimuat';
                                  }

                                  if (_semesterLoadError) {
                                    return 'Daftar semester gagal dimuat';
                                  }

                                  if (_semesterOptions.isEmpty) {
                                    return 'Daftar semester tidak tersedia';
                                  }

                                  if (value == null || value.isEmpty) {
                                    return 'Semester wajib dipilih';
                                  }

                                  return null;
                                },
                              ),

                              if (_semesterLoadError)
                                _retryButton(onPressed: _loadSemesterOptions),

                              const SizedBox(height: 13),

                              // LAYANAN MAHASISWA
                              _fieldTitle('Layanan'),
                              DropdownButtonFormField<String>(
                                key: ValueKey('service-$_formVersion'),
                                initialValue: _selectedService,
                                isExpanded: true,
                                menuMaxHeight: 300,
                                dropdownColor: const Color(0xFFF0F7FF),
                                decoration: _fieldDecoration(
                                  hintText: _isLoadingStudentServices
                                      ? 'Memuat layanan...'
                                      : _studentServiceLoadError
                                      ? 'Gagal memuat layanan'
                                      : 'Pilih Layanan',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: Image.asset(
                                      'assets/images/layanan.png',
                                      width: 21,
                                      height: 21,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: Color(0xFF222222),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF202020),
                                  fontSize: 14,
                                ),
                                items: _studentServices.map((String service) {
                                  return DropdownMenuItem<String>(
                                    value: service,
                                    child: Text(
                                      service,
                                      style: const TextStyle(
                                        color: Color(0xFF202020),
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged:
                                    _isSubmitting ||
                                        _isLoadingStudentServices ||
                                        _studentServiceLoadError ||
                                        _studentServices.isEmpty
                                    ? null
                                    : (String? value) {
                                        bool dateAdjusted = false;

                                        setState(() {
                                          _selectedService = value;

                                          dateAdjusted =
                                              _adjustQueueDateForService();
                                        });

                                        if (dateAdjusted) {
                                          _showMessage(
                                            'Layanan ini tidak tersedia hari ini. '
                                            'Tanggal antrian disesuaikan ke besok; '
                                            'Anda dapat memilih tanggal lain di kalender.',
                                          );
                                        }
                                      },
                                validator: (String? value) {
                                  if (_isLoadingStudentServices) {
                                    return 'Daftar layanan masih dimuat';
                                  }

                                  if (_studentServiceLoadError) {
                                    return 'Daftar layanan gagal dimuat';
                                  }

                                  if (_studentServices.isEmpty) {
                                    return 'Daftar layanan tidak tersedia';
                                  }

                                  if (value == null || value.isEmpty) {
                                    return 'Layanan wajib dipilih';
                                  }

                                  return null;
                                },
                              ),

                              if (_studentServiceLoadError)
                                _retryButton(onPressed: _loadStudentServices),

                              // PEMBERITAHUAN ADMIN
                              if (_selectedStudentServiceNotification !=
                                  null) ...[
                                const SizedBox(height: 8),
                                _buildServiceNotification(
                                  _selectedStudentServiceNotification!,
                                ),
                              ],

                              const SizedBox(height: 13),
                            ],

                            // DATA PENGUNJUNG UMUM
                            if (_selectedCategory == 'Umum') ...[
                              _fieldTitle('Jenis Layanan'),
                              DropdownButtonFormField<String>(
                                key: ValueKey('general-service-$_formVersion'),
                                initialValue: _selectedGeneralService,
                                isExpanded: true,
                                menuMaxHeight: 300,
                                dropdownColor: const Color(0xFFF0F7FF),
                                decoration: _fieldDecoration(
                                  hintText: _isLoadingGeneralServices
                                      ? 'Memuat jenis layanan...'
                                      : _generalServiceLoadError
                                      ? 'Gagal memuat jenis layanan'
                                      : 'Pilih Jenis Layanan',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: Image.asset(
                                      'assets/images/layanan.png',
                                      width: 21,
                                      height: 21,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: Color(0xFF222222),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF202020),
                                  fontSize: 14,
                                ),
                                items: _generalServices.map((String service) {
                                  return DropdownMenuItem<String>(
                                    value: service,
                                    child: Text(
                                      service,
                                      style: const TextStyle(
                                        color: Color(0xFF202020),
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged:
                                    _isSubmitting ||
                                        _isLoadingGeneralServices ||
                                        _generalServiceLoadError ||
                                        _generalServices.isEmpty
                                    ? null
                                    : (String? value) {
                                        setState(() {
                                          _selectedGeneralService = value;
                                        });
                                      },
                                validator: (String? value) {
                                  if (_isLoadingGeneralServices) {
                                    return 'Daftar layanan masih dimuat';
                                  }

                                  if (_generalServiceLoadError) {
                                    return 'Daftar layanan gagal dimuat';
                                  }

                                  if (_generalServices.isEmpty) {
                                    return 'Daftar layanan tidak tersedia';
                                  }

                                  if (value == null || value.isEmpty) {
                                    return 'Jenis layanan wajib dipilih';
                                  }

                                  return null;
                                },
                              ),

                              if (_generalServiceLoadError)
                                _retryButton(onPressed: _loadGeneralServices),

                              const SizedBox(height: 13),

                              _fieldTitle('Untuk'),
                              TextFormField(
                                controller: _destinationController,
                                enabled: !_isSubmitting,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                decoration: _fieldDecoration(
                                  hintText: 'Masukkan tujuan pengajuan',
                                  prefixIcon: const Icon(
                                    Icons.send_rounded,
                                    size: 20,
                                    color: Color(0xFF3EA94C),
                                  ),
                                ),
                                validator: (String? value) {
                                  final String destination =
                                      value?.trim() ?? '';

                                  if (destination.isEmpty) {
                                    return 'Untuk wajib diisi';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 13),
                            ],

                            // KETERANGAN
                            _fieldTitle('Keterangan'),
                            SizedBox(
                              height: 115,
                              child: TextFormField(
                                controller: _descriptionController,
                                enabled: !_isSubmitting,
                                expands: true,
                                minLines: null,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: _fieldDecoration(
                                  hintText:
                                      'Tuliskan keterangan pengajuan Anda',
                                ),
                                validator: (String? value) {
                                  final String description =
                                      value?.trim() ?? '';

                                  if (description.isEmpty) {
                                    return 'Keterangan wajib diisi';
                                  }

                                  return null;
                                },
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
                                    onPressed: _isSubmitting
                                        ? null
                                        : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5868FF),
                                      disabledBackgroundColor: const Color(
                                        0xFFADB5F5,
                                      ),
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
                                        : _resetForm,
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

                            const SizedBox(height: 5),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TOMBOL KATEGORI
  Widget _categoryButton({
    required String title,
    required String value,
    required String asset,
    required Color iconColor,
  }) {
    final bool selected = _selectedCategory == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: _isSubmitting
            ? null
            : () {
                if (_selectedCategory == value) {
                  return;
                }

                setState(() {
                  _selectedCategory = value;

                  // RESET TANGGAL DAN JAM
                  _selectedQueueDate = _today;
                  _selectedQueueMinute = null;

                  // RESET DATA MAHASISWA
                  _identifierController.clear();
                  _departmentController.clear();
                  _selectedSemester = null;
                  _selectedService = null;

                  // RESET DATA UMUM
                  _originController.clear();
                  _destinationController.clear();
                  _selectedGeneralService = null;

                  _descriptionController.clear();
                  _formVersion++;
                });

                _formKey.currentState?.reset();
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
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF202020),
                    fontSize: 10.5,
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

  // TANGGAL ANTRIAN
  DateTime get _today => DateUtils.dateOnly(UltQueueSchedule.now());

  DateTime get _firstAllowedQueueDate {
    final DateTime today = _today;

    return _isDirectQueueDisabled
        ? DateTime(today.year, today.month, today.day + 1)
        : today;
  }

  bool _adjustQueueDateForService() {
    final DateTime today = _today;

    if (_isDirectQueueDisabled && !_selectedQueueDate.isAfter(today)) {
      _selectedQueueDate = DateTime(today.year, today.month, today.day + 1);

      _selectedQueueMinute = null;

      return true;
    }

    return false;
  }

  Widget _queueDateField() {
    final bool isToday = DateUtils.isSameDay(_selectedQueueDate, _today);

    return InkWell(
      onTap: _isSubmitting || _isQueueDatePickerOpen ? null : _selectQueueDate,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFF8D8D8D), width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: Color(0xFF168DE2),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                '${isToday ? 'Hari ini, ' : ''}'
                '${_formatDisplayDate(_selectedQueueDate)}',
                style: const TextStyle(
                  color: Color(0xFF202020),
                  fontSize: 10.5,
                ),
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF555555),
            ),
          ],
        ),
      ),
    );
  }

  Widget _queueDateInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF9CCDF2), width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Color(0xFF168DE2),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              _isDirectQueueDisabled
                  ? 'Layanan ini tidak tersedia hari ini. '
                        'Pilih tanggal mulai '
                        '${_formatDisplayDate(_firstAllowedQueueDate)}.'
                  : 'Tanggal awal adalah hari ini. Tekan kalender untuk '
                        'memilih tanggal kedatangan lain.',
              style: const TextStyle(
                color: Color(0xFF303030),
                fontSize: 9.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PILIH TANGGAL
  Future<void> _selectQueueDate() async {
    if (_isSubmitting || _isQueueDatePickerOpen) {
      return;
    }

    FocusScope.of(context).unfocus();

    final DateTime today = _today;
    final DateTime firstDate = _firstAllowedQueueDate;

    final DateTime lastDate = DateTime(today.year + 1, 12, 31);

    DateTime initialDate = _selectedQueueDate;

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    setState(() {
      _isQueueDatePickerOpen = true;
    });

    try {
      final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        initialEntryMode: DatePickerEntryMode.calendar,
        helpText: 'Pilih Tanggal Antrian',
        cancelText: 'Batal',
        confirmText: 'Pilih',
      );

      if (!mounted || selected == null) {
        return;
      }

      final DateTime date = DateUtils.dateOnly(selected);

      if (date.isBefore(_firstAllowedQueueDate)) {
        _showMessage(
          'Tanggal tersebut sudah tidak tersedia. '
          'Silakan pilih ulang.',
        );

        return;
      }

      setState(() {
        // Mengganti tanggal mengosongkan pilihan jam.
        if (!DateUtils.isSameDay(_selectedQueueDate, date)) {
          _selectedQueueMinute = null;
        }

        _selectedQueueDate = date;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isQueueDatePickerOpen = false;
        });
      }
    }
  }

  // PEMBERITAHUAN ADMIN
  Widget _buildServiceNotification(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE53935), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD32F2F),
            size: 19,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFC62828),
                fontSize: 9.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _retryButton({required Future<void> Function() onPressed}) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          onPressed();
        },
        icon: const Icon(Icons.refresh_rounded, size: 14),
        label: const Text('Coba Lagi', style: TextStyle(fontSize: 9)),
      ),
    );
  }

  Widget _fieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF202020),
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDisplayDate(DateTime date) {
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

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatApiDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');

    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  // SUBMIT
  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (_selectedCategory == null) {
      _showMessage('Silakan pilih kategori terlebih dahulu.');

      return;
    }

    if (_isSubmitting || _isQueueDatePickerOpen) {
      return;
    }

    final DateTime today = _today;

    final DateTime queueDate = DateUtils.dateOnly(_selectedQueueDate);

    if (queueDate.isBefore(today)) {
      _showMessage(
        'Tanggal antrian sudah lewat. '
        'Silakan pilih ulang di kalender.',
      );

      return;
    }

    if (queueDate.isAfter(DateTime(today.year + 1, 12, 31))) {
      _showMessage(
        'Tanggal antrian melewati batas kalender. '
        'Silakan pilih ulang.',
      );

      return;
    }

    if (_isDirectQueueDisabled && DateUtils.isSameDay(queueDate, today)) {
      _showMessage(
        'Layanan ini tidak tersedia hari ini. '
        'Pilih tanggal setelah hari ini.',
      );

      return;
    }

    final String queueType = DateUtils.isSameDay(queueDate, today)
        ? 'langsung'
        : 'booking';

    final int? queueMinute = _selectedQueueMinute;

    if (queueMinute == null) {
      _showMessage('Silakan pilih jam antrian.');

      return;
    }

    if (!UltQueueSchedule.isSelectable(queueDate, queueMinute)) {
      _showMessage(
        'Jam antrian sudah lewat atau di luar jam layanan. '
        'Silakan pilih ulang tanggal dan jam.',
      );

      return;
    }

    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      _showMessage('Silakan lengkapi data yang masih kosong.');

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Ambil token perangkat jika notifikasi diizinkan.
      final String? fcmToken = await UltNotificationService.instance
          .tokenForSubmission();

      if (!mounted) {
        return;
      }

      // Pengambilan token dapat memerlukan waktu.
      // Periksa kembali agar jam yang lewat tidak terkirim.
      if (!UltQueueSchedule.isSelectable(queueDate, queueMinute)) {
        _showMessage(
          'Jam antrian sudah lewat. '
          'Silakan pilih ulang jam antrian.',
        );

        return;
      }

      final Uri uri = Uri.parse(ApiConfig.createAntrianTiket);

      final http.MultipartRequest request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'category': _selectedCategory!.trim().toLowerCase(),
        'queue_type': queueType,
        'queue_date': _formatApiDate(queueDate),
        'queue_time': UltQueueSchedule.formatMinute(
          queueMinute,
          separator: ':',
        ),
        'description': _descriptionController.text.trim(),
      });

      // Laravel nanti menyimpan token ini bersama tiket.
      if (fcmToken != null && fcmToken.isNotEmpty) {
        request.fields['fcm_token'] = fcmToken;
        request.fields['device_platform'] = 'android';
      }

      if (_selectedCategory == 'Mahasiswa') {
        request.fields.addAll({
          'identifier_value': _identifierController.text.trim(),
          'department': _departmentController.text.trim(),
          'semester': _selectedSemester!,
          'service': _selectedService!,
        });
      }

      if (_selectedCategory == 'Umum') {
        request.fields.addAll({
          'origin': _originController.text.trim(),
          'service': _selectedGeneralService!,
          'destination': _destinationController.text.trim(),
        });
      }

      final http.StreamedResponse streamedResponse = await request.send();

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('ANTRIAN STATUS: ${response.statusCode}');

      debugPrint('ANTRIAN RESPONSE: ${response.body}');

      Map<String, dynamic> jsonResponse;

      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          jsonResponse = decoded;
        } else {
          throw const FormatException('Response bukan object JSON.');
        }
      } catch (e) {
        if (!mounted) {
          return;
        }

        _showMessage('Response server tidak valid.');

        return;
      }

      final bool success = jsonResponse['success'] == true;

      if (response.statusCode == 201 && success) {
        final dynamic rawData = jsonResponse['data'];

        if (rawData is! Map<String, dynamic>) {
          if (!mounted) {
            return;
          }

          _showMessage('Data tiket dari server tidak valid.');

          return;
        }

        final Map<String, dynamic> data = rawData;

        if (!mounted) {
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return UltSuccessPage(
                queueNumber: data['queue_number']?.toString() ?? '-',
                requestNumber: data['request_number']?.toString() ?? '-',
                queueType: data['queue_type']?.toString() ?? queueType,
                queueDateLabel:
                    data['queue_date_label']?.toString() ??
                    _formatDisplayDate(queueDate),
                fullName:
                    data['full_name']?.toString() ??
                    _nameController.text.trim(),
                phone:
                    data['phone']?.toString() ?? _phoneController.text.trim(),
                category:
                    data['category_label']?.toString() ?? _selectedCategory!,
                service:
                    data['service']?.toString() ??
                    (_selectedCategory == 'Mahasiswa'
                        ? (_selectedService ?? '-')
                        : (_selectedGeneralService ?? '-')),
                identifierValue: _selectedCategory == 'Mahasiswa'
                    ? (data['identifier_value']?.toString() ??
                          _identifierController.text.trim())
                    : null,
                department: _selectedCategory == 'Mahasiswa'
                    ? (data['department']?.toString() ??
                          _departmentController.text.trim())
                    : null,
                semester: _selectedCategory == 'Mahasiswa'
                    ? (data['semester']?.toString() ?? _selectedSemester)
                    : null,
                origin: _selectedCategory == 'Umum'
                    ? (data['origin']?.toString() ??
                          _originController.text.trim())
                    : null,
                destination: _selectedCategory == 'Umum'
                    ? (data['destination']?.toString() ??
                          _destinationController.text.trim())
                    : null,
                email:
                    data['email']?.toString() ?? _emailController.text.trim(),
                emailSent: data['email_sent'] == true,
              );
            },
          ),
        );

        return;
      }

      if (!mounted) {
        return;
      }

      final String message =
          jsonResponse['message']?.toString() ?? 'Tiket antrian gagal dibuat.';

      _showMessage(message);
    } catch (e, stackTrace) {
      debugPrint('ANTRIAN TIKET ERROR: $e');

      debugPrint('ANTRIAN STACK TRACE: $stackTrace');

      if (!mounted) {
        return;
      }

      _showMessage(
        'Tidak dapat terhubung ke server. '
        'Pastikan perangkat dan server berada '
        'pada jaringan yang sama.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // CLEAR FORM
  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _descriptionController.clear();

    _identifierController.clear();
    _departmentController.clear();

    _originController.clear();
    _destinationController.clear();

    setState(() {
      _selectedCategory = null;

      // RESET TANGGAL DAN JAM
      _selectedQueueDate = _today;
      _selectedQueueMinute = null;

      _selectedSemester = null;
      _selectedService = null;
      _selectedGeneralService = null;

      _formVersion++;
    });

    _formKey.currentState?.reset();
  }

  // RESET
  void _resetForm() {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) {
      return;
    }

    _clearForm();
    _showMessage('Form berhasil dikosongkan.');
  }

  // MESSAGE
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
