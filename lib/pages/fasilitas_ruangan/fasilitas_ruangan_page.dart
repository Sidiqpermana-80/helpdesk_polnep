import 'dart:async';

import 'dart:convert';

import 'package:file_selector/file_selector.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

import 'fasilitas_ruangan_success_page.dart';

class FasilitasRuanganPage extends StatefulWidget {
  const FasilitasRuanganPage({super.key});

  @override
  State<FasilitasRuanganPage> createState() => _FasilitasRuanganPageState();
}

class _FasilitasRuanganPageState extends State<FasilitasRuanganPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _identifierController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _floorController = TextEditingController();

  final TextEditingController _roomController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedBuilding;

  String? _selectedFacility;

  int _formVersion = 0;

  XFile? _supportFile;

  bool _isSubmitting = false;

  List<String> _buildingOptions = <String>[];
  List<String> _facilityOptions = <String>[];

  bool _isLoadingBuildings = true;
  bool _isLoadingFacilities = true;
  bool _buildingLoadError = false;
  bool _facilityLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadBuildingOptions();
    _loadFacilityOptions();
  }

  Future<void> _refreshPage() async {
    await Future.wait([_loadBuildingOptions(), _loadFacilityOptions()]);
  }

  @override
  void dispose() {
    _nameController.dispose();

    _identifierController.dispose();

    _emailController.dispose();

    _floorController.dispose();

    _roomController.dispose();

    _descriptionController.dispose();

    super.dispose();
  }

  Future<List<String>> _fetchMasterOptions(String url) async {
    final http.Response response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 20));

    debugPrint('MASTER OPTION STATUS: ${response.statusCode}');
    debugPrint('MASTER OPTION RESPONSE: ${response.body}');

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

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> item) =>
              item['option_label']?.toString().trim() ?? '',
        )
        .where((String value) => value.isNotEmpty)
        .toList();
  }

  Future<void> _loadBuildingOptions() async {
    if (mounted) {
      setState(() {
        _isLoadingBuildings = true;
        _buildingLoadError = false;
      });
    }

    try {
      final List<String> buildings = await _fetchMasterOptions(
        ApiConfig.fasilitasBuildingOptions,
      );

      if (!mounted) return;

      setState(() {
        _buildingOptions = buildings;

        if (_selectedBuilding != null &&
            !_buildingOptions.contains(_selectedBuilding)) {
          _selectedBuilding = null;
        }

        _isLoadingBuildings = false;
        _buildingLoadError = false;
      });
    } on TimeoutException {
      debugPrint('LOAD FASILITAS BUILDINGS ERROR: TimeoutException');

      if (!mounted) return;

      setState(() {
        _buildingOptions = <String>[];
        _isLoadingBuildings = false;
        _buildingLoadError = true;
      });
    } catch (e) {
      debugPrint('LOAD FASILITAS BUILDINGS ERROR: $e');

      if (!mounted) return;

      setState(() {
        _buildingOptions = <String>[];
        _isLoadingBuildings = false;
        _buildingLoadError = true;
      });
    }
  }

  Future<void> _loadFacilityOptions() async {
    if (mounted) {
      setState(() {
        _isLoadingFacilities = true;
        _facilityLoadError = false;
      });
    }

    try {
      final List<String> facilities = await _fetchMasterOptions(
        ApiConfig.fasilitasTypeOptions,
      );

      if (!mounted) return;

      setState(() {
        _facilityOptions = facilities;

        if (_selectedFacility != null &&
            !_facilityOptions.contains(_selectedFacility)) {
          _selectedFacility = null;
        }

        _isLoadingFacilities = false;
        _facilityLoadError = false;
      });
    } on TimeoutException {
      debugPrint('LOAD FACILITY TYPES ERROR: TimeoutException');

      if (!mounted) return;

      setState(() {
        _facilityOptions = <String>[];
        _isLoadingFacilities = false;
        _facilityLoadError = true;
      });
    } catch (e) {
      debugPrint('LOAD FACILITY TYPES ERROR: $e');

      if (!mounted) return;

      setState(() {
        _facilityOptions = <String>[];
        _isLoadingFacilities = false;
        _facilityLoadError = true;
      });
    }
  }

  InputDecoration _fieldDecoration({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),

      prefixIcon: prefixIcon,

      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 40),

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
                        'Fasilitas Ruangan',

                        style: TextStyle(
                          color: Color(0xFF111111),

                          fontSize: 16,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // LOGO
                  SizedBox(
                    width: double.infinity,

                    height: 112,

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 7, top: 2),

                            child: Text(
                              'Pilih Fasilitas\n'
                              'Ruangan yang\n'
                              'ingin anda\n'
                              'keluhkan',

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
                          width: 150,

                          height: 105,

                          child: Image.asset(
                            'assets/images/rusak.png',

                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // FORM CARD
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 20),

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
                            'DATA PELAPOR',

                            style: TextStyle(
                              color: Color(0xFF202020),

                              fontSize: 12,

                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          const Text(
                            'Lengkapi data pelapor berikut:',

                            style: TextStyle(
                              color: Color(0xFF202020),

                              fontSize: 10.5,
                            ),
                          ),

                          const SizedBox(height: 25),

                          _fieldTitle('Nama Lengkap'),

                          TextFormField(
                            controller: _nameController,

                            enabled: !_isSubmitting,

                            style: const TextStyle(fontSize: 14),

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
                                return 'Nama lengkap wajib diisi';
                              }

                              if (name.length < 3) {
                                return 'Nama lengkap belum sesuai';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          _fieldTitle('NIM / NIP'),

                          TextFormField(
                            controller: _identifierController,

                            enabled: !_isSubmitting,

                            style: const TextStyle(fontSize: 14),

                            keyboardType: TextInputType.number,

                            textInputAction: TextInputAction.next,

                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,

                              LengthLimitingTextInputFormatter(30),
                            ],

                            decoration: _fieldDecoration(
                              hintText: 'Masukkan NIM atau NIP',

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
                              final String identifier = value?.trim() ?? '';

                              if (identifier.isEmpty) {
                                return 'NIM/NIP wajib diisi';
                              }

                              if (identifier.length < 5) {
                                return 'NIM/NIP belum sesuai';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          _fieldTitle('Email'),

                          TextFormField(
                            controller: _emailController,

                            enabled: !_isSubmitting,

                            style: const TextStyle(fontSize: 14),

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

                          const SizedBox(height: 28),

                          const Divider(color: Color(0xFF555555), thickness: 1),

                          const SizedBox(height: 22),

                          const Text(
                            'DETAIL LOKASI',

                            style: TextStyle(
                              color: Color(0xFF202020),

                              fontSize: 12,

                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          const Text(
                            'Lengkapi lokasi dan fasilitas yang mengalami kendala:',

                            style: TextStyle(
                              color: Color(0xFF202020),

                              fontSize: 10.5,
                            ),
                          ),

                          const SizedBox(height: 25),

                          _fieldTitle('Nama Gedung'),

                          DropdownButtonFormField<String>(
                            key: ValueKey('building-$_formVersion'),
                            initialValue: _selectedBuilding,
                            isExpanded: true,
                            menuMaxHeight: 320,
                            dropdownColor: const Color(0xFFF0F7FF),
                            decoration: _fieldDecoration(
                              hintText: _isLoadingBuildings
                                  ? 'Memuat nama gedung...'
                                  : _buildingLoadError
                                  ? 'Gagal memuat nama gedung'
                                  : 'Pilih nama gedung',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/images/gedung.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 19,
                              color: Color(0xFF222222),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10.5,
                            ),
                            items: _buildingOptions.map((String building) {
                              return DropdownMenuItem<String>(
                                value: building,
                                child: Text(
                                  building,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged:
                                _isSubmitting ||
                                    _isLoadingBuildings ||
                                    _buildingLoadError ||
                                    _buildingOptions.isEmpty
                                ? null
                                : (String? value) {
                                    setState(() {
                                      _selectedBuilding = value;
                                    });
                                  },
                            validator: (String? value) {
                              if (_isLoadingBuildings) {
                                return 'Daftar gedung masih dimuat';
                              }

                              if (_buildingLoadError) {
                                return 'Daftar gedung gagal dimuat';
                              }

                              if (_buildingOptions.isEmpty) {
                                return 'Daftar gedung tidak tersedia';
                              }

                              if (value == null || value.isEmpty) {
                                return 'Nama gedung wajib dipilih';
                              }

                              return null;
                            },
                          ),

                          if (_buildingLoadError)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _isSubmitting
                                    ? null
                                    : _loadBuildingOptions,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(fontSize: 9),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF168DE2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 13),

                          _fieldTitle('Lantai'),

                          TextFormField(
                            controller: _floorController,

                            enabled: !_isSubmitting,

                            textInputAction: TextInputAction.next,

                            style: const TextStyle(fontSize: 14),

                            decoration: _fieldDecoration(
                              hintText: 'Contoh: Lantai 3',

                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(7),

                                child: Image.asset(
                                  'assets/images/tangga.png',

                                  width: 21,

                                  height: 21,

                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lantai wajib diisi';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          _fieldTitle('Nama / Nomor Ruangan'),

                          TextFormField(
                            controller: _roomController,

                            enabled: !_isSubmitting,

                            style: const TextStyle(fontSize: 14),

                            textCapitalization: TextCapitalization.words,

                            textInputAction: TextInputAction.next,

                            decoration: _fieldDecoration(
                              hintText: 'Contoh: R. 201',

                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8),

                                child: Image.asset(
                                  'assets/images/door.png',

                                  width: 20,

                                  height: 20,

                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama/nomor ruangan wajib diisi';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          _fieldTitle('Jenis Fasilitas'),

                          DropdownButtonFormField<String>(
                            key: ValueKey('facility-$_formVersion'),
                            initialValue: _selectedFacility,
                            isExpanded: true,
                            menuMaxHeight: 300,
                            dropdownColor: const Color(0xFFF0F7FF),
                            decoration: _fieldDecoration(
                              hintText: _isLoadingFacilities
                                  ? 'Memuat jenis fasilitas...'
                                  : _facilityLoadError
                                  ? 'Gagal memuat jenis fasilitas'
                                  : 'Pilih jenis fasilitas',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(7),
                                child: Image.asset(
                                  'assets/images/rumah.png',
                                  width: 21,
                                  height: 21,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 19,
                              color: Color(0xFF222222),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10.5,
                            ),
                            items: _facilityOptions.map((String facility) {
                              return DropdownMenuItem<String>(
                                value: facility,
                                child: Text(
                                  facility,
                                  style: const TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged:
                                _isSubmitting ||
                                    _isLoadingFacilities ||
                                    _facilityLoadError ||
                                    _facilityOptions.isEmpty
                                ? null
                                : (String? value) {
                                    setState(() {
                                      _selectedFacility = value;
                                    });
                                  },
                            validator: (String? value) {
                              if (_isLoadingFacilities) {
                                return 'Jenis fasilitas masih dimuat';
                              }

                              if (_facilityLoadError) {
                                return 'Jenis fasilitas gagal dimuat';
                              }

                              if (_facilityOptions.isEmpty) {
                                return 'Jenis fasilitas tidak tersedia';
                              }

                              if (value == null || value.isEmpty) {
                                return 'Jenis fasilitas wajib dipilih';
                              }

                              return null;
                            },
                          ),

                          if (_facilityLoadError)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _isSubmitting
                                    ? null
                                    : _loadFacilityOptions,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(fontSize: 9),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF168DE2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 13),

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

                              textCapitalization: TextCapitalization.sentences,

                              textAlignVertical: TextAlignVertical.top,

                              style: const TextStyle(fontSize: 14),

                              decoration: _fieldDecoration(
                                hintText:
                                    'Jelaskan kondisi atau kerusakan fasilitas',
                              ),

                              validator: (String? value) {
                                final String description = value?.trim() ?? '';

                                if (description.isEmpty) {
                                  return 'Keterangan wajib diisi';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          _fieldTitle('Upload File Pendukung'),

                          _buildFileInput(),

                          const SizedBox(height: 7),

                          const Center(
                            child: Text(
                              'Upload hanya jika diperlukan file pendukung',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Color(0xFF555555),

                                fontSize: 9,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Center(
                            child: Text(
                              'Format: JPG, PNG, PDF, DOC, DOCX, XLS atau XLSX. Maksimal 5 MB.',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Color(0xFF777777),

                                fontSize: 8.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Divider(color: Color(0xFF555555), thickness: 1),

                          const SizedBox(height: 22),

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),

                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),

                              borderRadius: BorderRadius.circular(8),

                              border: Border.all(
                                color: const Color(0xFF9D8EE7),

                                width: 0.6,
                              ),
                            ),

                            child: const Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,

                                  backgroundColor: Color(0xFF075DBD),

                                  child: Icon(
                                    Icons.priority_high_rounded,

                                    color: Colors.white,

                                    size: 21,
                                  ),
                                ),

                                SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    'Pastikan Data yang Anda isi sudah benar.\n'
                                    'Tim Helpdesk akan menindaklanjuti laporan Anda.',

                                    style: TextStyle(
                                      color: Color(0xFF222222),

                                      fontSize: 9.5,

                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              SizedBox(
                                width: 100,

                                height: 40,

                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitForm,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8C99F2),

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
                                  onPressed: _isSubmitting ? null : _resetForm,

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

  Widget _buildFileInput() {
    final bool hasFile = _supportFile != null;

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
                      hasFile ? _supportFile!.name : 'Belum ada file',

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: hasFile
                            ? const Color(0xFF202020)
                            : const Color(0xFF777777),

                        fontSize: 10.5,
                      ),
                    ),
                  ),

                  if (hasFile)
                    InkWell(
                      onTap: _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _supportFile = null;
                              });
                            },

                      borderRadius: BorderRadius.circular(20),

                      child: const Padding(
                        padding: EdgeInsets.all(4),

                        child: Icon(
                          Icons.close_rounded,

                          size: 16,

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
              onPressed: _isSubmitting ? null : _pickSupportFile,

              icon: const Icon(
                Icons.folder,

                color: Color(0xFFFFB52D),

                size: 18,
              ),

              label: const Text('Choose File', style: TextStyle(fontSize: 8.5)),

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

  Future<void> _pickSupportFile() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'File Pendukung',

        extensions: <String>[
          'jpg',

          'jpeg',

          'png',

          'pdf',

          'doc',

          'docx',

          'xls',

          'xlsx',
        ],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (file == null) {
        return;
      }

      final int fileSize = await file.length();

      const int maximumSize = 5 * 1024 * 1024;

      if (fileSize > maximumSize) {
        if (!mounted) {
          return;
        }

        _showMessage('Ukuran file maksimal 5 MB.');

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _supportFile = file;
      });

      _showMessage('File pendukung berhasil dipilih.');
    } catch (e) {
      debugPrint('FILE FASILITAS ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Gagal memilih file.');
    }
  }

  // Laravel

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      _showMessage('Silakan lengkapi data yang masih kosong.');

      return;
    }

    if (_isSubmitting) {
      return;
    }

    final String fullName = _nameController.text.trim();

    final String identifierValue = _identifierController.text.trim();

    final String email = _emailController.text.trim();

    final String buildingName = _selectedBuilding!;

    final String floor = _floorController.text.trim();

    final String roomName = _roomController.text.trim();

    final String facilityType = _selectedFacility!;

    final String description = _descriptionController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final Uri url = Uri.parse(ApiConfig.createFasilitasRuangan);

      final http.MultipartRequest request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'full_name': fullName,

        'identifier_value': identifierValue,

        'email': email,

        'building_name': buildingName,

        'floor': floor,

        'room_name': roomName,

        'facility_type': facilityType,

        'description': description,
      });

      if (_supportFile != null) {
        final bytes = await _supportFile!.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'support_file',

            bytes,

            filename: _supportFile!.name,
          ),
        );
      }

      final http.StreamedResponse streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 40));

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        'FASILITAS STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'FASILITAS RESPONSE: '
        '${response.body}',
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response API tidak valid.');
      }

      final Map<String, dynamic> responseData = decoded;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['success'] == true) {
        final dynamic rawData = responseData['data'];

        if (rawData is! Map<String, dynamic>) {
          throw const FormatException('Data API tidak valid.');
        }

        final Map<String, dynamic> data = rawData;

        final String requestNumber = data['request_number']?.toString() ?? '';

        if (requestNumber.isEmpty) {
          throw const FormatException('Nomor tiket tidak ditemukan.');
        }

        DateTime submittedAt = DateTime.now();

        final String? submittedAtRaw = data['submitted_at']?.toString();

        if (submittedAtRaw != null && submittedAtRaw.isNotEmpty) {
          submittedAt = DateTime.tryParse(submittedAtRaw) ?? submittedAt;
        }

        debugPrint(
          'FASILITAS EMAIL SENT: '
          '${data['email_sent']}',
        );

        if (!mounted) {
          return;
        }

        _clearForm();

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return FasilitasRuanganSuccessPage(
                requestNumber: requestNumber,

                fullName: fullName,

                identifierValue: identifierValue,

                buildingName: buildingName,

                floor: floor,

                roomName: roomName,

                facilityType: facilityType,

                submittedAt: submittedAt,
              );
            },
          ),
        );

        return;
      }

      final String message =
          responseData['message']?.toString() ??
          'Laporan fasilitas ruangan gagal dikirim.';

      if (!mounted) {
        return;
      }

      _showMessage(message);
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      _showMessage('Server tidak merespon. Periksa koneksi jaringan.');
    } on FormatException catch (e) {
      debugPrint('FORMAT FASILITAS ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Response dari server tidak valid.');
    } catch (e) {
      debugPrint('FASILITAS ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _nameController.clear();

    _identifierController.clear();

    _emailController.clear();

    _floorController.clear();

    _roomController.clear();

    _descriptionController.clear();

    setState(() {
      _selectedBuilding = null;

      _selectedFacility = null;

      _supportFile = null;

      _formVersion++;
    });

    _formKey.currentState?.reset();
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();

    _clearForm();

    _showMessage('Form berhasil dikosongkan.');
  }

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
