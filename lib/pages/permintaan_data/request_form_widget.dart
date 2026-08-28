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
  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _identifierController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _informationController = TextEditingController();

  final TextEditingController _reasonController = TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  String _selectedUnitKerja = 'BAK';
  String _selectedRequestCategory = 'SIAKAD';
  String _selectedPriority = 'Tidak Mendesak';

  bool _isSubmitting = false;

  int _formVersion = 0;

  // =========================================================
  // FILE
  // =========================================================

  XFile? _identityFile;
  XFile? _supportFile;

  // =========================================================
  // UNIT KERJA
  // =========================================================

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

  // =========================================================
  // KATEGORI PERMINTAAN
  // =========================================================

  static const List<String> _requestCategories = [
    'SIAKAD',
    'Kepegawaian',
    'Remunerasi',
    'Aplikasi',
    'Website',
    'Access Point',
    'Fasilitas Ruangan',
    'Lainnya',
  ];

  // =========================================================
  // PRIORITAS
  // =========================================================

  static const List<String> _priorities = [
    'Tidak Mendesak',
    'Normal',
    'Mendesak',
  ];

  // =========================================================
  // DISPOSE
  // =========================================================

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

  // =========================================================
  // JENIS PEMOHON
  // =========================================================

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

  // =========================================================
  // FORMAT NOMOR TELEPON
  // =========================================================

  String _getFormattedPhone() {
    String phone = _phoneController.text.trim();

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    return '+62$phone';
  }

  // =========================================================
  // PILIH FILE IDENTITAS
  // =========================================================

  Future<void> _pickIdentityFile() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'File Identitas',
        extensions: <String>['jpg', 'jpeg', 'png', 'pdf'],
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

        _showMessage('Ukuran file identitas maksimal 5 MB.');

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _identityFile = file;
      });

      _showMessage('File identitas berhasil dipilih.');
    } catch (e) {
      debugPrint('ERROR PILIH IDENTITAS: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Gagal memilih file identitas.');
    }
  }

  // =========================================================
  // PILIH FILE PENDUKUNG
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

        _showMessage('Ukuran file pendukung maksimal 5 MB.');

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
      debugPrint('ERROR PILIH FILE PENDUKUNG: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Gagal memilih file pendukung.');
    }
  }

  // =========================================================
  // DESIGN INPUT
  // =========================================================

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

  // =========================================================
  // BUILD
  // =========================================================

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
            Text(
              'Permintaan Data ${widget.categoryName}',
              style: const TextStyle(
                color: Color(0xFF202020),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Home / Permintaan Data / ${widget.categoryName}',
              style: const TextStyle(
                color: Color(0xFF168DE2),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

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

                    // NAMA LENGKAP
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

                    // NIP / NIM
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

                    // UNIT KERJA
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

                    // TELEPON
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

                    // KATEGORI PERMINTAAN
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

                    // INFORMASI
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

                    // ALASAN
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

                    // PRIORITAS
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

                    // IDENTITAS
                    _buildLabeledField(
                      label: 'Upload Identitas\nAnda',
                      child: _buildFileInput(
                        selectedFile: _identityFile,
                        onChooseFile: _pickIdentityFile,
                        onClear: () {
                          setState(() {
                            _identityFile = null;
                          });
                        },
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 80, bottom: 12),
                      child: Text(
                        'Format: JPG, JPEG, PNG atau PDF. Maksimal 5 MB.',
                        style: TextStyle(color: Color(0xFF777777), fontSize: 8),
                      ),
                    ),

                    // FILE PENDUKUNG
                    _buildLabeledField(
                      label: 'Upload File\nPendukung',
                      child: _buildFileInput(
                        selectedFile: _supportFile,
                        onChooseFile: _pickSupportFile,
                        onClear: () {
                          setState(() {
                            _supportFile = null;
                          });
                        },
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 80),
                      child: Text(
                        'Format: JPG, PNG, PDF, DOC, DOCX, XLS atau XLSX. Maksimal 5 MB.',
                        style: TextStyle(color: Color(0xFF777777), fontSize: 8),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Divider(thickness: 1, color: Color(0xFF666666)),

                    const SizedBox(height: 17),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
  // LABEL + FIELD
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
  // FILE INPUT
  // =========================================================

  Widget _buildFileInput({
    required XFile? selectedFile,
    required VoidCallback onChooseFile,
    required VoidCallback onClear,
  }) {
    final bool hasFile = selectedFile != null;

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFE3E3E3),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasFile ? selectedFile.name : 'Belum ada file',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasFile
                            ? const Color(0xFF202020)
                            : const Color(0xFF777777),
                        fontSize: 9,
                        fontWeight: hasFile ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),

                  if (hasFile)
                    InkWell(
                      onTap: onClear,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF777777),
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
              onPressed: onChooseFile,
              icon: const Icon(
                Icons.folder,
                color: Color(0xFFFFB52D),
                size: 18,
              ),
              label: const Text('Choose File', style: TextStyle(fontSize: 8.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58C761),
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
    );
  }

  // =========================================================
  // KIRIM KE API
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
      // =====================================================
      // URL SEKARANG DIAMBIL DARI api_config.dart
      // =====================================================

      final Uri url = Uri.parse(ApiConfig.createPermintaanData);

      final http.MultipartRequest request = http.MultipartRequest('POST', url);

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
      // IDENTITAS
      // =====================================================

      if (_identityFile != null) {
        final Uint8List bytes = await _identityFile!.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'identity_file',
            bytes,
            filename: _identityFile!.name,
          ),
        );
      }

      // =====================================================
      // FILE PENDUKUNG
      // =====================================================

      if (_supportFile != null) {
        final Uint8List bytes = await _supportFile!.readAsBytes();

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
          .timeout(const Duration(seconds: 30));

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('PERMINTAAN DATA STATUS: ${response.statusCode}');

      debugPrint('PERMINTAAN DATA RESPONSE: ${response.body}');

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response bukan JSON object.');
      }

      final Map<String, dynamic> responseData = decoded;

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

        _clearForm();

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

      final String message =
          responseData['message']?.toString() ?? 'Permintaan gagal dikirim.';

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
      debugPrint('FORMAT ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Response dari server tidak valid.');
    } catch (e) {
      debugPrint('ERROR KIRIM DATA: $e');

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

  // =========================================================
  // CLEAR
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

      _identityFile = null;
      _supportFile = null;

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
