import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'aplikasi_success_page.dart';

class AplikasiFormPage extends StatefulWidget {
  const AplikasiFormPage({
    required this.issueType,
    required this.applicationName,
    super.key,
  });

  final String issueType;
  final String applicationName;

  @override
  State<AplikasiFormPage> createState() => _AplikasiFormPageState();
}

class _AplikasiFormPageState extends State<AplikasiFormPage> {
  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _identifierController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  // =========================================================
  // FILE
  // =========================================================

  XFile? _supportFile;

  // =========================================================
  // LOADING
  // =========================================================

  bool _isSubmitting = false;

  Future<void> _refreshPage() async {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // =========================================================
  // UBAH JENIS KENDALA MENJADI FORMAT API
  // =========================================================

  String _getApiIssueType() {
    switch (widget.issueType) {
      case 'Tidak Bisa Login':
        return 'tidak_bisa_login';

      case 'Data Tidak Sesuai':
        return 'data_tidak_sesuai';

      case 'Error Sistem':
        return 'error_sistem';

      case 'Permintaan Akses':
        return 'permintaan_akses';

      case 'tidak_bisa_login':
      case 'data_tidak_sesuai':
      case 'error_sistem':
      case 'permintaan_akses':
        return widget.issueType;

      default:
        return '';
    }
  }

  // =========================================================
  // PILIH FILE
  // =========================================================

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
      debugPrint('FILE APLIKASI ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Gagal memilih file.');
    }
  }

  // =========================================================
  // DESIGN FIELD
  // =========================================================

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),
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

  // =========================================================
  // BUILD
  // =========================================================

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
                  // =================================================
                  // HEADER
                  // =================================================
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
                        'Layanan Aplikasi',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  // =================================================
                  // FORM
                  // =================================================
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
                            'FORM PERTANYAAN',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          const Text(
                            'Lengkapi data berikut sesuai dengan pilihan anda:',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 9.5,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // =========================================
                          // NAMA
                          // =========================================
                          _fieldTitle('Nama Lengkap'),

                          TextFormField(
                            controller: _nameController,

                            textCapitalization: TextCapitalization.words,

                            textInputAction: TextInputAction.next,

                            decoration: _fieldDecoration(
                              hintText: 'Masukkan nama lengkap',
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

                          // =========================================
                          // NIM / NIP
                          // =========================================
                          _fieldTitle('NIM / NIP'),

                          TextFormField(
                            controller: _identifierController,

                            keyboardType: TextInputType.number,

                            textInputAction: TextInputAction.next,

                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,

                              LengthLimitingTextInputFormatter(30),
                            ],

                            decoration: _fieldDecoration(
                              hintText: 'Masukkan NIM atau NIP',
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
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              hintText: 'Masukkan email aktif',
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

                          // =========================================
                          // APLIKASI
                          // TIDAK BISA DIEDIT
                          // =========================================
                          _fieldTitle('Pilihan Aplikasi'),

                          _buildLockedField(value: widget.applicationName),

                          const SizedBox(height: 13),

                          // =========================================
                          // JENIS KENDALA
                          // TIDAK BISA DIEDIT
                          // =========================================
                          _fieldTitle('Jenis Kendala'),

                          _buildLockedField(value: widget.issueType),

                          const SizedBox(height: 13),

                          // =========================================
                          // DESKRIPSI
                          // =========================================
                          _fieldTitle('Deskripsikan Permasalahan Anda'),

                          SizedBox(
                            height: 115,

                            child: TextFormField(
                              controller: _descriptionController,

                              expands: true,
                              minLines: null,
                              maxLines: null,

                              keyboardType: TextInputType.multiline,

                              textCapitalization: TextCapitalization.sentences,

                              textAlignVertical: TextAlignVertical.top,

                              decoration: _fieldDecoration(
                                hintText:
                                    'Tuliskan permasalahan yang Anda alami',
                              ),

                              validator: (String? value) {
                                final String description = value?.trim() ?? '';

                                if (description.isEmpty) {
                                  return 'Deskripsi permasalahan wajib diisi';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =========================================
                          // FILE
                          // =========================================
                          _fieldTitle('Upload File Pendukung'),

                          _buildFileInput(),

                          const SizedBox(height: 7),

                          const Center(
                            child: Text(
                              'Upload hanya jika diperlukan file pendukung',
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
                              'Format: JPG, PNG, PDF, DOC, DOCX, XLS atau XLSX. Maksimal 5 MB.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 7.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Divider(color: Color(0xFF555555), thickness: 1),

                          const SizedBox(height: 22),

                          // =========================================
                          // BUTTON
                          // =========================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              // KIRIM DATA
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

                              // RESET
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

  // =========================================================
  // FIELD TITLE
  // =========================================================

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

  // =========================================================
  // LOCKED FIELD
  // =========================================================

  // =========================================================
  // FIELD LOCKED / TIDAK BISA DIEDIT
  // =========================================================

  Widget _buildLockedField({required String value}) {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(minHeight: 42),

      alignment: Alignment.centerLeft,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

      decoration: BoxDecoration(
        // Background biru muda
        color: const Color(0xFFE7F3FF),

        borderRadius: BorderRadius.circular(5),

        // Border biru
        border: Border.all(color: const Color(0xFF3AA7F5), width: 1.1),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1769AA),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Penanda field terkunci
          const Icon(
            Icons.lock_outline_rounded,
            size: 15,
            color: Color(0xFF168DE2),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILE INPUT
  // =========================================================

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

                        fontSize: 9,
                      ),
                    ),
                  ),

                  if (hasFile)
                    InkWell(
                      onTap: () {
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

  // =========================================================
  // KIRIM KE LARAVEL
  // =========================================================

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

    final String issueType = _getApiIssueType();

    if (issueType.isEmpty) {
      _showMessage('Jenis kendala tidak valid.');

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // =======================================================
    // SIMPAN DATA SEBELUM FORM DIBERSIHKAN
    // =======================================================

    final String fullName = _nameController.text.trim();

    final String identifierValue = _identifierController.text.trim();

    final String applicationName = widget.applicationName;

    final String description = _descriptionController.text.trim();

    try {
      // =====================================================
      // ENDPOINT LARAVEL
      // =====================================================

      final Uri url = Uri.parse(ApiConfig.createAplikasi);

      // =====================================================
      // MULTIPART REQUEST
      // =====================================================

      final http.MultipartRequest request = http.MultipartRequest('POST', url);

      // =====================================================
      // FIELD
      // =====================================================

      request.fields.addAll({
        'full_name': fullName,

        'identifier_value': identifierValue,

        'email': _emailController.text.trim(),

        'application_name': applicationName,

        'issue_type': issueType,

        'description': description,
      });

      // =====================================================
      // FILE PENDUKUNG
      // =====================================================

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

      // =====================================================
      // KIRIM
      // =====================================================

      final http.StreamedResponse streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 30));

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        'APLIKASI STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'APLIKASI RESPONSE: '
        '${response.body}',
      );

      // =====================================================
      // PARSE JSON
      // =====================================================

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response API tidak valid.');
      }

      final Map<String, dynamic> responseData = decoded;

      // =====================================================
      // BERHASIL
      // =====================================================

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

        if (!mounted) {
          return;
        }

        // ===================================================
        // WAKTU PENGAJUAN
        //
        // Untuk sekarang memakai waktu perangkat.
        // ===================================================

        final DateTime submittedAt = DateTime.now();

        // ===================================================
        // BERSIHKAN FORM SETELAH API BERHASIL
        // ===================================================

        _clearForm();

        // ===================================================
        // SUCCESS PAGE
        // ===================================================

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return AplikasiSuccessPage(
                requestNumber: requestNumber,

                fullName: fullName,

                identifierValue: identifierValue,

                applicationName: applicationName,

                issueType: issueType,

                submittedAt: submittedAt,
              );
            },
          ),
        );

        return;
      }

      // =====================================================
      // API MENOLAK
      // =====================================================

      final String message =
          responseData['message']?.toString() ??
          'Permintaan layanan aplikasi gagal dikirim.';

      if (!mounted) {
        return;
      }

      _showMessage(message);
    }
    // =======================================================
    // TIMEOUT
    // =======================================================
    on TimeoutException {
      if (!mounted) {
        return;
      }

      _showMessage('Server tidak merespon. Periksa koneksi jaringan.');
    }
    // =======================================================
    // JSON ERROR
    // =======================================================
    on FormatException catch (e) {
      debugPrint('FORMAT APLIKASI ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Response dari server tidak valid.');
    }
    // =======================================================
    // ERROR LAIN
    // =======================================================
    catch (e) {
      debugPrint('APLIKASI ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Tidak dapat terhubung ke server.');
    }
    // =======================================================
    // SELESAI
    // =======================================================
    finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // =========================================================
  // CLEAR
  // =========================================================

  void _clearForm() {
    _nameController.clear();
    _identifierController.clear();
    _descriptionController.clear();
    _emailController.clear();

    setState(() {
      _supportFile = null;
    });

    _formKey.currentState?.reset();
  }

  // =========================================================
  // RESET
  // =========================================================

  void _resetForm() {
    FocusScope.of(context).unfocus();

    _clearForm();

    _showMessage('Form berhasil dikosongkan.');
  }

  // =========================================================
  // MESSAGE
  // =========================================================

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
