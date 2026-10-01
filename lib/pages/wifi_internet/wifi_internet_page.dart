import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'wifi_internet_success_page.dart';

class WifiInternetPage extends StatefulWidget {
  const WifiInternetPage({super.key});

  @override
  State<WifiInternetPage> createState() => _WifiInternetPageState();
}

class _WifiInternetPageState extends State<WifiInternetPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _identifierController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _roomController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedBuilding;

  bool _isSubmitting = false;

  int _formVersion = 0;

  List<String> _buildingOptions = <String>[];

  bool _isLoadingBuildings = true;

  @override
  void initState() {
    super.initState();

    _loadBuildingOptions();
  }

  Future<void> _refreshPage() async {
    await _loadBuildingOptions();
  }

  Future<void> _loadBuildingOptions() async {
    if (mounted) {
      setState(() {
        _isLoadingBuildings = true;
      });
    }

    try {
      final http.Response response = await http
          .get(Uri.parse(ApiConfig.wifiBuildingOptions))
          .timeout(const Duration(seconds: 20));

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw const FormatException('Data gedung tidak valid.');
      }

      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        throw const FormatException('Daftar gedung tidak valid.');
      }

      final List<String> buildings = rawData
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> item) =>
                item['option_label']?.toString().trim() ?? '',
          )
          .where((String value) => value.isNotEmpty)
          .toList();

      debugPrint('BUILDING STATUS: ${response.statusCode}');

      debugPrint('BUILDING RESPONSE: ${response.body}');

      if (!mounted) {
        return;
      }

      setState(() {
        _buildingOptions = buildings;

        _isLoadingBuildings = false;
      });
    } catch (e) {
      debugPrint('LOAD WIFI BUILDINGS ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _buildingOptions = <String>[];

        _isLoadingBuildings = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _emailController.dispose();
    _roomController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  InputDecoration _fieldDecoration({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 10),

      prefixIcon: prefixIcon,

      prefixIconConstraints: const BoxConstraints(minWidth: 31, minHeight: 31),

      isDense: true,

      filled: true,

      fillColor: const Color(0xFFF5F6FA),

      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.8),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.8),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF3AA7F5), width: 1.2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.red, width: 0.8),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),

      errorStyle: const TextStyle(fontSize: 8.5),
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

                        onPressed: () {
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
                        'Keluhan Wifi / Internet',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // LOGO
                  SizedBox(
                    width: double.infinity,
                    height: 108,

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 7, top: 3),

                            child: Text(
                              'Laporkan kendala\n'
                              'jaringan pada\n'
                              'gedung atau\n'
                              'ruangan di POLNEP',
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

                    child: Form(
                      key: _formKey,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Data Pelapor',
                            style: TextStyle(
                              color: Color(0xFF24477C),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          _fieldTitle('Nama'),

                          TextFormField(
                            controller: _nameController,

                            style: const TextStyle(fontSize: 10.5),

                            textCapitalization: TextCapitalization.words,

                            textInputAction: TextInputAction.next,

                            decoration: _fieldDecoration(
                              hintText: 'Masukkan nama lengkap',

                              prefixIcon: const Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: Color(0xFF168DE2),
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

                          const SizedBox(height: 8),

                          _fieldTitle('NIM / NIP'),

                          TextFormField(
                            controller: _identifierController,

                            style: const TextStyle(fontSize: 10.5),

                            keyboardType: TextInputType.number,

                            textInputAction: TextInputAction.next,

                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,

                              LengthLimitingTextInputFormatter(30),
                            ],

                            decoration: _fieldDecoration(
                              hintText: 'Masukkan NIM atau NIP',

                              prefixIcon: const Icon(
                                Icons.menu_book_rounded,
                                size: 18,
                                color: Color(0xFF4E73C8),
                              ),
                            ),

                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'NIM/NIP wajib diisi';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFF707070),
                          ),

                          const SizedBox(height: 13),

                          _fieldTitle('Email'),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 10.5),
                            decoration: _fieldDecoration(
                              hintText: 'Masukkan email aktif',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 18,
                                color: Color(0xFF168DE2),
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

                          const Text(
                            'Detail Lokasi',
                            style: TextStyle(
                              color: Color(0xFF24477C),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          _fieldTitle('Nama Gedung'),

                          DropdownButtonFormField<String>(
                            key: ValueKey('building-$_formVersion'),
                            initialValue: _selectedBuilding,
                            isExpanded: true,
                            isDense: true,

                            decoration: _fieldDecoration(
                              hintText: _isLoadingBuildings
                                  ? 'Memuat nama gedung...'
                                  : 'Pilih nama gedung',

                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  'assets/images/gedung.png',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 17,
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
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10.5),
                                ),
                              );
                            }).toList(),

                            onChanged: _isLoadingBuildings
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

                              if (_buildingOptions.isEmpty) {
                                return 'Daftar gedung tidak tersedia';
                              }

                              if (value == null || value.isEmpty) {
                                return 'Nama gedung wajib dipilih';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          _fieldTitle('Ruangan'),

                          TextFormField(
                            controller: _roomController,

                            style: const TextStyle(fontSize: 10.5),

                            textCapitalization: TextCapitalization.words,

                            textInputAction: TextInputAction.next,

                            decoration: _fieldDecoration(
                              hintText: 'Contoh: Lab Komputer / Ruang 203',

                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(6),

                                child: Image.asset(
                                  'assets/images/door.png',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ruangan wajib diisi';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          _fieldTitle('Deskripsi Keluhan'),

                          SizedBox(
                            height: 84,

                            child: TextFormField(
                              controller: _descriptionController,

                              style: const TextStyle(fontSize: 10.5),

                              expands: true,
                              minLines: null,
                              maxLines: null,

                              keyboardType: TextInputType.multiline,

                              textCapitalization: TextCapitalization.sentences,

                              textAlignVertical: TextAlignVertical.top,

                              decoration: _fieldDecoration(
                                hintText:
                                    'Jelaskan kendala Wifi / Internet yang dialami',
                              ),

                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Deskripsi keluhan wajib diisi';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

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
                            'Pastikan Data yang Anda isi sudah benar.\n'
                            'Tim Helpdesk akan menindaklanjuti laporan Anda.',
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      SizedBox(
                        width: 88,
                        height: 34,

                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D4BFF),

                            disabledBackgroundColor: const Color(0xFFAAA9FF),

                            foregroundColor: Colors.white,

                            elevation: 0,

                            padding: EdgeInsets.zero,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Kirim Data',
                                  style: TextStyle(fontSize: 9),
                                ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      SizedBox(
                        width: 64,
                        height: 34,

                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _resetForm,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59C467),

                            foregroundColor: Colors.white,

                            elevation: 0,

                            padding: EdgeInsets.zero,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          child: const Text(
                            'Reset',
                            style: TextStyle(fontSize: 9),
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
    );
  }

  Widget _fieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),

      child: Text(
        title,

        style: const TextStyle(color: Color(0xFF303030), fontSize: 9),
      ),
    );
  }

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

    setState(() {
      _isSubmitting = true;
    });

    final String fullName = _nameController.text.trim();

    final String identifierValue = _identifierController.text.trim();

    final String buildingName = _selectedBuilding!;

    final String roomName = _roomController.text.trim();

    final String description = _descriptionController.text.trim();

    try {
      final http.Response response = await http
          .post(
            Uri.parse(ApiConfig.createWifiInternet),

            body: {
              'full_name': fullName,

              'identifier_value': identifierValue,

              'email': _emailController.text.trim(),

              'building_name': buildingName,

              'room_name': roomName,

              'description': description,
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('WIFI STATUS: ${response.statusCode}');

      debugPrint('WIFI RESPONSE: ${response.body}');

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response API tidak valid.');
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        final dynamic rawData = decoded['data'];

        if (rawData is! Map<String, dynamic>) {
          throw const FormatException('Data API tidak valid.');
        }

        final String requestNumber =
            rawData['request_number']?.toString() ?? '';

        final String status =
            rawData['status']?.toString() ?? 'menunggu_verifikasi';

        final String estimatedResponse =
            rawData['estimated_response']?.toString() ?? '1-2 Hari Kerja';

        if (requestNumber.isEmpty) {
          throw const FormatException('Nomor tiket tidak ditemukan.');
        }

        DateTime submittedAt = DateTime.now();

        final String? serverDate = rawData['submitted_at']?.toString();

        if (serverDate != null && serverDate.isNotEmpty) {
          submittedAt = DateTime.tryParse(serverDate) ?? submittedAt;
        }

        if (!mounted) {
          return;
        }

        _clearForm();

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return WifiInternetSuccessPage(
                requestNumber: requestNumber,

                fullName: fullName,

                identifierValue: identifierValue,

                buildingName: buildingName,

                roomName: roomName,

                status: status,

                estimatedResponse: estimatedResponse,

                submittedAt: submittedAt,
              );
            },
          ),
        );

        return;
      }

      final String message =
          decoded['message']?.toString() ??
          'Keluhan Wifi / Internet gagal dikirim.';

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
      debugPrint('WIFI FORMAT ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Response dari server tidak valid.');
    } catch (e) {
      debugPrint('WIFI ERROR: $e');

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
    _roomController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedBuilding = null;
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
