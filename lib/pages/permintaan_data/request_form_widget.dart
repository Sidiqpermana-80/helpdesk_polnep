import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'permintaan_data_success_page.dart';

class RequestFormWidget extends StatefulWidget {
  const RequestFormWidget({
    required this.categoryName,
    required this.identifierLabel,
    this.showUnitKerjaField = false,
    super.key,
  });

  final String categoryName;
  final String identifierLabel;
  final bool showUnitKerjaField;

  @override
  State<RequestFormWidget> createState() => _RequestFormWidgetState();
}

class _RequestFormWidgetState extends State<RequestFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _identifierController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _informationController = TextEditingController();

  final TextEditingController _reasonController = TextEditingController();

  String _selectedUnitKerja = 'BAK';

  String _selectedRequestCategory = 'SIAKAD';

  String _selectedPriority = 'Tidak Mendesak';

  bool _isSubmitting = false;

  int _formVersion = 0;

  final List<XFile> _supportFiles = <XFile>[];

  static const int _maximumSupportFiles = 5;

  static const int _maximumFileSize = 5 * 1024 * 1024;

  static const List<String> _unitKerjaOptions = [
    'BAK',
    'BAAK',
    'BUK',
    'UPT TIK',
    'Perpustakaan',
    'Jurusan Teknik Sipil',
    'Jurusan Teknik Mesin',
    'Jurusan Teknik Elektro',
    'Jurusan Administrasi Bisnis',
    'Jurusan Akuntansi',
    'Jurusan Teknologi Pertanian',
    'Jurusan Teknik Arsitektur',
    'Unit Lainnya',
  ];

  static const List<String> _requestCategories = [
    'SIAKAD',
    'Aplikasi',
    'Website',
    'Access Point',
    'Fasilitas Ruangan',
    'Lainnya',
  ];

  static const List<String> _priorities = [
    'Tidak Mendesak',
    'Normal',
    'Mendesak',
  ];

  @override
  void dispose() {
    _nameController.dispose();

    _identifierController.dispose();

    _emailController.dispose();

    _phoneController.dispose();

    _informationController.dispose();

    _reasonController.dispose();

    super.dispose();
  }

  String _getRequesterType() {
    switch (widget.categoryName) {
      case 'Unit Kerja':
        return 'unit_kerja';

      case 'Dosen':
        return 'dosen';

      case 'Mahasiswa':
        return 'mahasiswa';

      default:
        return '';
    }
  }

  String _getFormattedPhone() {
    String phone = _phoneController.text.trim();

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    return '+62$phone';
  }

  Future<void> _pickSupportFiles() async {
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

      final List<XFile> files = await openFiles(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (files.isEmpty) {
        return;
      }

      if (_supportFiles.length + files.length > _maximumSupportFiles) {
        if (!mounted) {
          return;
        }

        _showMessage('File pendukung maksimal $_maximumSupportFiles file.');

        return;
      }

      for (final XFile file in files) {
        final int fileSize = await file.length();

        if (fileSize > _maximumFileSize) {
          if (!mounted) {
            return;
          }

          _showMessage('File ${file.name} melebihi batas maksimal 5 MB.');

          return;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _supportFiles.addAll(files);
      });

      _showMessage('${files.length} file berhasil dipilih.');
    } catch (e) {
      debugPrint('ERROR PILIH FILE PENDUKUNG: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Gagal memilih file pendukung.');
    }
  }

  void _removeSupportFile(int index) {
    if (index < 0 || index >= _supportFiles.length) {
      return;
    }

    setState(() {
      _supportFiles.removeAt(index);
    });
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),

      filled: true,

      fillColor: const Color(0xFFE3E3E3),

      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF3AA7F5), width: 1.5),
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
    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
        ),
      ),

      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

        padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // JUDUL
            // =================================================
            Text(
              'Permintaan Data ${widget.categoryName}',
              style: const TextStyle(
                color: Color(0xFF202020),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),

            // =================================================
            // BREADCRUMB
            // =================================================
            Text(
              'Home / Permintaan Data / ${widget.categoryName}',
              style: const TextStyle(
                color: Color(0xFF168DE2),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // =================================================
            // FORM CONTAINER
            // =================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(10, 14, 10, 19),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(10),

                border: Border.all(color: const Color(0xFFD6E9F7), width: 0.7),

                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =========================================
                    // HEADER FORM
                    // =========================================
                    const Text(
                      'INPUT PERMINTAAN DATA',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Lengkapi data berikut sesuai dengan data yang ingin diminta:',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 10.5,
                      ),
                    ),

                    const SizedBox(height: 27),

                    // =========================================
                    // NAMA LENGKAP
                    // =========================================
                    _buildLabeledField(
                      label: 'Nama Lengkap',

                      child: TextFormField(
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
                    ),

                    // =========================================
                    // NIM / NIP
                    // =========================================
                    _buildLabeledField(
                      label: widget.identifierLabel,

                      child: TextFormField(
                        controller: _identifierController,

                        keyboardType: TextInputType.number,

                        textInputAction: TextInputAction.next,

                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],

                        decoration: _fieldDecoration(
                          hintText: 'Masukkan ${widget.identifierLabel}',
                        ),

                        validator: (String? value) {
                          final String identifier = value?.trim() ?? '';

                          if (identifier.isEmpty) {
                            return '${widget.identifierLabel} wajib diisi';
                          }

                          if (identifier.length < 5) {
                            return '${widget.identifierLabel} belum sesuai';
                          }

                          return null;
                        },
                      ),
                    ),

                    // =========================================
                    // EMAIL
                    // =========================================
                    _buildLabeledField(
                      label: 'Email',

                      child: TextFormField(
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
                    ),

                    // =========================================
                    // UNIT KERJA
                    // HANYA JIKA DIPERLUKAN
                    // =========================================
                    if (widget.showUnitKerjaField)
                      _buildLabeledField(
                        label: 'Nama Unit\nKerja',

                        child: DropdownButtonFormField<String>(
                          key: ValueKey('unit-kerja-$_formVersion'),

                          initialValue: _selectedUnitKerja,

                          isExpanded: true,

                          decoration: _fieldDecoration(),

                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19,
                          ),

                          style: const TextStyle(
                            color: Color(0xFF202020),
                            fontSize: 11.5,
                          ),

                          items: _unitKerjaOptions.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,

                              child: Text(
                                unit,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),

                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedUnitKerja = value;
                            });
                          },
                        ),
                      ),

                    // =========================================
                    // NO TELEPON
                    // =========================================
                    _buildLabeledField(
                      label: 'No Telepon',

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            height: 42,

                            padding: const EdgeInsets.symmetric(horizontal: 8),

                            alignment: Alignment.center,

                            decoration: BoxDecoration(
                              color: const Color(0xFFE3E3E3),
                              borderRadius: BorderRadius.circular(5),
                            ),

                            child: const Text(
                              '+62',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF202020),
                              ),
                            ),
                          ),

                          const SizedBox(width: 7),

                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,

                              keyboardType: TextInputType.phone,

                              textInputAction: TextInputAction.next,

                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,

                                LengthLimitingTextInputFormatter(13),
                              ],

                              decoration: _fieldDecoration(
                                hintText: '81234567890',
                              ),

                              validator: (String? value) {
                                final String phone = value?.trim() ?? '';

                                if (phone.isEmpty) {
                                  return 'Nomor telepon wajib diisi';
                                }

                                if (phone.length < 9) {
                                  return 'Nomor telepon belum sesuai';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =========================================
                    // KATEGORI PERMINTAAN
                    // =========================================
                    _buildLabeledField(
                      label: 'Kategori\nPermintaan',

                      child: DropdownButtonFormField<String>(
                        key: ValueKey('kategori-$_formVersion'),

                        initialValue: _selectedRequestCategory,

                        isExpanded: true,

                        decoration: _fieldDecoration(),

                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 19,
                        ),

                        style: const TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 11.5,
                        ),

                        items: _requestCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,

                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),

                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedRequestCategory = value;
                          });
                        },
                      ),
                    ),

                    _buildLabeledField(
                      label: 'Informasi yang\nDibutuhkan',

                      child: SizedBox(
                        height: 135,

                        child: TextFormField(
                          controller: _informationController,

                          expands: true,

                          minLines: null,

                          maxLines: null,

                          keyboardType: TextInputType.multiline,

                          textAlignVertical: TextAlignVertical.top,

                          decoration: _fieldDecoration(
                            hintText: 'Tuliskan informasi yang dibutuhkan',
                          ),

                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informasi yang dibutuhkan wajib diisi';
                            }

                            return null;
                          },
                        ),
                      ),
                    ),

                    _buildLabeledField(
                      label: 'Alasan\nPermintaan',

                      child: SizedBox(
                        height: 135,

                        child: TextFormField(
                          controller: _reasonController,

                          expands: true,

                          minLines: null,

                          maxLines: null,

                          keyboardType: TextInputType.multiline,

                          textAlignVertical: TextAlignVertical.top,

                          decoration: _fieldDecoration(
                            hintText: 'Tuliskan alasan permintaan',
                          ),

                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Alasan permintaan wajib diisi';
                            }

                            return null;
                          },
                        ),
                      ),
                    ),

                    // =========================================
                    // PRIORITAS
                    // =========================================
                    _buildLabeledField(
                      label: 'Prioritas',

                      child: DropdownButtonFormField<String>(
                        key: ValueKey('prioritas-$_formVersion'),

                        initialValue: _selectedPriority,

                        isExpanded: true,

                        decoration: _fieldDecoration(),

                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 19,
                        ),

                        style: const TextStyle(
                          color: Color(0xFF202020),
                          fontSize: 11,
                        ),

                        items: _priorities.map((String priority) {
                          return DropdownMenuItem<String>(
                            value: priority,

                            child: Text(priority),
                          );
                        }).toList(),

                        onChanged: (String? value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedPriority = value;
                          });
                        },
                      ),
                    ),

                    // =========================================
                    // UPLOAD FILE PENDUKUNG
                    // MULTI FILE
                    // =========================================
                    _buildLabeledField(
                      label: 'Upload File\nPendukung',

                      child: _buildMultiFileInput(),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 80),

                      child: Text(
                        'Format: JPG, JPEG, PNG, PDF, DOC, DOCX, XLS atau XLSX. '
                        'Maksimal 5 file, masing-masing 5 MB.',
                        style: TextStyle(color: Color(0xFF777777), fontSize: 8),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Divider(thickness: 1, color: Color(0xFF666666)),

                    const SizedBox(height: 17),

                    // =========================================
                    // BUTTON
                    // =========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        // =====================================
                        // KIRIM
                        // =====================================
                        SizedBox(
                          width: 100,
                          height: 40,

                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C8CF5),

                              disabledBackgroundColor: const Color(0xFFABB4ED),

                              foregroundColor: Colors.white,

                              elevation: 0,

                              padding: EdgeInsets.zero,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // =====================================
                        // RESET
                        // =====================================
                        SizedBox(
                          width: 70,
                          height: 40,

                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _resetForm,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF58C761),

                              foregroundColor: Colors.white,

                              elevation: 0,

                              padding: EdgeInsets.zero,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),

                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 10,
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
    );
  }

  // =========================================================
  // FIELD DENGAN LABEL
  // =========================================================

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 70,

            child: Padding(
              padding: const EdgeInsets.only(top: 11),

              child: Text(
                label,

                textAlign: TextAlign.right,

                style: const TextStyle(
                  color: Color(0xFF202020),
                  fontSize: 10.5,
                  height: 1.05,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(child: child),
        ],
      ),
    );
  }

  // =========================================================
  // MULTI FILE INPUT
  // =========================================================

  Widget _buildMultiFileInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // =====================================================
        // PILIH FILE
        // =====================================================
        SizedBox(
          height: 42,

          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: double.infinity,

                  padding: const EdgeInsets.symmetric(horizontal: 8),

                  alignment: Alignment.centerLeft,

                  decoration: const BoxDecoration(
                    color: Color(0xFFE3E3E3),

                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(5),
                    ),
                  ),

                  child: Text(
                    _supportFiles.isEmpty
                        ? 'Belum ada file'
                        : '${_supportFiles.length} file dipilih',

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: _supportFiles.isEmpty
                          ? const Color(0xFF777777)
                          : const Color(0xFF202020),

                      fontSize: 9,

                      fontWeight: _supportFiles.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // =================================================
              // BUTTON CHOOSE FILE
              // =================================================
              SizedBox(
                width: 105,
                height: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: _supportFiles.length >= _maximumSupportFiles
                      ? null
                      : _pickSupportFiles,

                  icon: const Icon(
                    Icons.folder,
                    color: Color(0xFFFFB52D),
                    size: 18,
                  ),

                  label: const Text(
                    'Choose File',
                    style: TextStyle(fontSize: 8.5),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58C761),

                    disabledBackgroundColor: const Color(0xFFA8D9AC),

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(horizontal: 4),

                    elevation: 0,

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
        ),

        // =====================================================
        // DAFTAR FILE
        // =====================================================
        if (_supportFiles.isNotEmpty) ...[
          const SizedBox(height: 6),

          for (int index = 0; index < _supportFiles.length; index++)
            Container(
              margin: const EdgeInsets.only(bottom: 5),

              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),

                borderRadius: BorderRadius.circular(5),

                border: Border.all(color: const Color(0xFFD3D3D3), width: 0.6),
              ),

              child: Row(
                children: [
                  // ===========================================
                  // ICON FILE
                  // ===========================================
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    size: 15,
                    color: Color(0xFF168DE2),
                  ),

                  const SizedBox(width: 6),

                  // ===========================================
                  // NAMA FILE
                  // ===========================================
                  Expanded(
                    child: Text(
                      _supportFiles[index].name,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 8.5,
                      ),
                    ),
                  ),

                  // ===========================================
                  // HAPUS FILE
                  // ===========================================
                  InkWell(
                    onTap: () {
                      _removeSupportFile(index);
                    },

                    borderRadius: BorderRadius.circular(20),

                    child: const Padding(
                      padding: EdgeInsets.all(3),

                      child: Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  // =========================================================
  // SUBMIT KE LARAVEL
  // =========================================================

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      _showMessage('Silakan lengkapi data yang masih kosong.');

      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String requesterType = _getRequesterType();

    final String fullName = _nameController.text.trim();

    final String identifierValue = _identifierController.text.trim();

    final String phone = _getFormattedPhone();

    final String requestCategory = _selectedRequestCategory;

    final String informationNeeded = _informationController.text.trim();

    final String requestReason = _reasonController.text.trim();

    final String priority = _selectedPriority;

    final String? unitKerja = widget.showUnitKerjaField
        ? _selectedUnitKerja
        : null;

    try {
      final Uri url = Uri.parse(ApiConfig.createPermintaanData);

      final http.MultipartRequest request = http.MultipartRequest('POST', url);

      // =====================================================
      // FIELD
      // =====================================================

      request.fields.addAll({
        'requester_type': requesterType,

        'full_name': fullName,

        'identifier_value': identifierValue,

        'email': _emailController.text.trim(),

        'phone': phone,

        'request_category': requestCategory,

        'information_needed': informationNeeded,

        'request_reason': requestReason,

        'priority': priority,
      });

      if (unitKerja != null) {
        request.fields['unit_name'] = unitKerja;
      }

      // =====================================================
      // MULTI FILE PENDUKUNG
      // support_files[]
      // =====================================================

      for (final XFile file in _supportFiles) {
        final Uint8List bytes = await file.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'support_files[]',
            bytes,
            filename: file.name,
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
        'PERMINTAAN DATA STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'PERMINTAAN DATA RESPONSE: '
        '${response.body}',
      );

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response bukan JSON object.');
      }

      final Map<String, dynamic> responseData = decoded;

      // =====================================================
      // BERHASIL
      // =====================================================

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['success'] == true) {
        final dynamic rawData = responseData['data'];

        if (rawData is! Map<String, dynamic>) {
          throw const FormatException('Data response API tidak valid.');
        }

        final Map<String, dynamic> data = rawData;

        final String requestNumber = data['request_number']?.toString() ?? '';

        final String status =
            data['status']?.toString() ?? 'menunggu_verifikasi';

        final String estimatedResponse =
            data['estimated_response']?.toString() ?? '1-2 Hari Kerja';

        if (requestNumber.isEmpty) {
          throw const FormatException('Nomor permintaan tidak ditemukan.');
        }

        if (!mounted) {
          return;
        }

        // ===================================================
        // CLEAR FORM
        // ===================================================

        _clearForm();

        // ===================================================
        // SUCCESS PAGE
        // ===================================================

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return PermintaanDataSuccessPage(
                categoryName: widget.categoryName,

                identifierLabel: widget.identifierLabel,

                identifierValue: identifierValue,

                requestCategory: requestCategory,

                requestNumber: requestNumber,

                status: status,

                estimatedResponse: estimatedResponse,

                unitKerja: unitKerja,
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
          responseData['message']?.toString() ?? 'Permintaan gagal dikirim.';

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
    // FORMAT ERROR
    // =======================================================
    on FormatException catch (e) {
      debugPrint('FORMAT ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Response dari server tidak valid.');
    }
    // =======================================================
    // ERROR LAIN
    // =======================================================
    catch (e) {
      debugPrint('ERROR KIRIM DATA: $e');

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
  // CLEAR FORM
  // =========================================================

  void _clearForm() {
    _nameController.clear();

    _identifierController.clear();

    _emailController.clear();

    _phoneController.clear();

    _informationController.clear();

    _reasonController.clear();

    setState(() {
      _selectedUnitKerja = 'BAK';

      _selectedRequestCategory = 'SIAKAD';

      _selectedPriority = 'Tidak Mendesak';

      // ===============================================
      // HAPUS SELURUH FILE
      // ===============================================

      _supportFiles.clear();

      _formVersion++;
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
