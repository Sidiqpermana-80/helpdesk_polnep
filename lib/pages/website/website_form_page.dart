import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'website_success_page.dart';

class WebsiteFormPage extends StatefulWidget {
  const WebsiteFormPage({required this.websiteName, super.key});

  final String websiteName;

  @override
  State<WebsiteFormPage> createState() => _WebsiteFormPageState();
}

class _WebsiteFormPageState extends State<WebsiteFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _identifierController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedIssue;
  XFile? _supportFile;

  bool _isSubmitting = false;
  int _formVersion = 0;

  static const List<String> _issueOptions = [
    'Lainnya',
    'Tidak Bisa Login',
    'Error Sistem',
    'Data Tidak Sesuai',
    'Permintaan Akses',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // =========================================================
  // UBAH JENIS KENDALA KE FORMAT API
  // =========================================================

  String _apiIssueType() {
    switch (_selectedIssue) {
      case 'Lainnya':
        return 'lainnya';

      case 'Tidak Bisa Login':
        return 'tidak_bisa_login';

      case 'Error Sistem':
        return 'error_sistem';

      case 'Data Tidak Sesuai':
        return 'data_tidak_sesuai';

      case 'Permintaan Akses':
        return 'permintaan_akses';

      default:
        return '';
    }
  }

  // =========================================================
  // PILIH FILE
  // =========================================================

  Future<void> _pickSupportFile() async {
    try {
      const XTypeGroup group = XTypeGroup(
        label: 'File Pendukung',
        extensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      final XFile? file = await openFile(acceptedTypeGroups: [group]);

      if (file == null) {
        return;
      }

      final int fileSize = await file.length();

      if (fileSize > 5 * 1024 * 1024) {
        if (!mounted) {
          return;
        }

        _message('Ukuran file maksimal 5 MB.');

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _supportFile = file;
      });
    } catch (e) {
      debugPrint('WEBSITE FILE ERROR: $e');

      if (!mounted) {
        return;
      }

      _message('Gagal memilih file.');
    }
  }

  // =========================================================
  // DECORATION INPUT
  //
  // Dibuat lebih kecil agar sesuai Figma
  // =========================================================

  InputDecoration _decoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,

      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 9),

      isDense: true,

      filled: true,

      fillColor: const Color(0xFFF3F4F8),

      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.7),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.7),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Color(0xFF3AA7F5), width: 1),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Colors.red, width: 0.8),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),

      errorStyle: const TextStyle(fontSize: 7.5, height: 0.9),
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

          // Tetap mengikuti background halaman lain.
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
            ),
          ),

          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            padding: const EdgeInsets.fromLTRB(16, 13, 16, 25),

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
                        size: 20,
                        color: Color(0xFF111111),
                      ),
                    ),

                    const SizedBox(width: 9),

                    const Text(
                      'Layanan Website',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Jarak header ke card dibuat seperti Figma.
                const SizedBox(height: 30),

                // =================================================
                // FORM CARD
                // =================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(8, 11, 8, 16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(9),

                    border: Border.all(
                      color: const Color(0xFFD8E6F0),
                      width: 0.5,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================================
                        // JUDUL FORM
                        // =========================================
                        const Text(
                          'FORM PERTANYAAN',
                          style: TextStyle(
                            color: Color(0xFF202020),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 2),

                        const Text(
                          'Lengkapi data berikut sesuai dengan pilihan anda:',
                          style: TextStyle(
                            color: Color(0xFF202020),
                            fontSize: 8,
                          ),
                        ),

                        const SizedBox(height: 19),

                        // =========================================
                        // NAMA
                        // =========================================
                        _title('Nama Lengkap'),

                        TextFormField(
                          controller: _nameController,

                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF202020),
                          ),

                          textCapitalization: TextCapitalization.words,

                          textInputAction: TextInputAction.next,

                          decoration: _decoration(),

                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama lengkap wajib diisi';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // =========================================
                        // NIM / NIP
                        // =========================================
                        _title('NIM / NIP'),

                        TextFormField(
                          controller: _identifierController,

                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF202020),
                          ),

                          keyboardType: TextInputType.number,

                          textInputAction: TextInputAction.next,

                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,

                            LengthLimitingTextInputFormatter(30),
                          ],

                          decoration: _decoration(),

                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'NIM/NIP wajib diisi';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        //Email
                        _title('Email'),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontSize: 9.5),
                          decoration: _decoration(
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
                        // PILIHAN WEBSITE
                        // =========================================
                        _title('Pilihan Website'),

                        _lockedWebsite(),

                        const SizedBox(height: 8),

                        // =========================================
                        // JENIS KENDALA
                        // =========================================
                        _title('Jenis Kendala'),

                        DropdownButtonFormField<String>(
                          key: ValueKey('issue-$_formVersion'),

                          initialValue: _selectedIssue,

                          isExpanded: true,

                          isDense: true,

                          menuMaxHeight: 220,

                          style: const TextStyle(
                            color: Color(0xFF202020),
                            fontSize: 9.5,
                          ),

                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: Color(0xFF555555),
                          ),

                          decoration: _decoration(),

                          items: _issueOptions.map((String issue) {
                            return DropdownMenuItem<String>(
                              value: issue,

                              child: Text(
                                issue,
                                style: const TextStyle(fontSize: 9.5),
                              ),
                            );
                          }).toList(),

                          onChanged: (String? value) {
                            setState(() {
                              _selectedIssue = value;
                            });
                          },

                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis kendala wajib dipilih';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // =========================================
                        // DESKRIPSI
                        // =========================================
                        _title('Deskripsikan Permasalahan Anda'),

                        SizedBox(
                          height: 72,

                          child: TextFormField(
                            controller: _descriptionController,

                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF202020),
                            ),

                            expands: true,
                            minLines: null,
                            maxLines: null,

                            keyboardType: TextInputType.multiline,

                            textCapitalization: TextCapitalization.sentences,

                            textAlignVertical: TextAlignVertical.top,

                            decoration: _decoration(),

                            validator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Deskripsi permasalahan wajib diisi';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 9),

                        // =========================================
                        // FILE
                        // =========================================
                        _title('Upload File Pendukung'),

                        _fileInput(),

                        const SizedBox(height: 5),

                        const Center(
                          child: Text(
                            'Upload hanya jika diperlukan file pendukung',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 7,
                            ),
                          ),
                        ),

                        const SizedBox(height: 23),

                        const Divider(
                          color: Color(0xFF555555),
                          thickness: 0.8,
                          height: 1,
                        ),

                        const SizedBox(height: 18),

                        // =========================================
                        // BUTTON
                        // =========================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            // KIRIM DATA
                            SizedBox(
                              width: 84,
                              height: 32,

                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submit,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8C99F2),

                                  disabledBackgroundColor: const Color(
                                    0xFFADB5F5,
                                  ),

                                  foregroundColor: Colors.white,

                                  elevation: 0,

                                  padding: EdgeInsets.zero,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),

                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,

                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.7,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Kirim Data',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            // RESET
                            SizedBox(
                              width: 60,
                              height: 32,

                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _reset,

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
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
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
    );
  }

  // =========================================================
  // LABEL FIELD
  // =========================================================

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),

      child: Text(
        text,

        style: const TextStyle(
          color: Color(0xFF202020),
          fontSize: 8.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // =========================================================
  // WEBSITE TERKUNCI
  // =========================================================

  Widget _lockedWebsite() {
    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(minHeight: 31),

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF),

        borderRadius: BorderRadius.circular(3),

        border: Border.all(color: const Color(0xFF3AA7F5), width: 0.9),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.websiteName,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                color: Color(0xFF1769AA),
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 5),

          const Icon(
            Icons.lock_outline_rounded,
            size: 13,
            color: Color(0xFF168DE2),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILE INPUT
  // =========================================================

  Widget _fileInput() {
    final bool hasFile = _supportFile != null;

    return SizedBox(
      height: 30,

      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 7),

              alignment: Alignment.centerLeft,

              decoration: const BoxDecoration(
                color: Color(0xFFD7D7D7),

                borderRadius: BorderRadius.horizontal(left: Radius.circular(3)),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasFile ? _supportFile!.name : 'Belum ada file',

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 7.5,
                      ),
                    ),
                  ),

                  if (hasFile)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _supportFile = null;
                        });
                      },

                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: 90,
            height: double.infinity,

            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _pickSupportFile,

              icon: const Icon(
                Icons.folder,
                color: Color(0xFFFFB52D),
                size: 15,
              ),

              label: const Text('Choose File', style: TextStyle(fontSize: 7)),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58C761),

                foregroundColor: Colors.white,

                elevation: 0,

                padding: const EdgeInsets.symmetric(horizontal: 3),

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(3),
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
  // SUBMIT KE LARAVEL
  // =========================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final String issue = _apiIssueType();

    if (issue.isEmpty) {
      _message('Jenis kendala tidak valid.');

      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String fullName = _nameController.text.trim();

    final String identifier = _identifierController.text.trim();

    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.createWebsite),
      );

      request.fields.addAll({
        'full_name': fullName,

        'identifier_value': identifier,

        'email': _emailController.text.trim(),

        'website_name': widget.websiteName,

        'issue_type': issue,

        'description': _descriptionController.text.trim(),
      });

      if (_supportFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'support_file',
            await _supportFile!.readAsBytes(),
            filename: _supportFile!.name,
          ),
        );
      }

      final http.StreamedResponse streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final http.Response response = await http.Response.fromStream(streamed);

      debugPrint('WEBSITE STATUS: ${response.statusCode}');

      debugPrint('WEBSITE RESPONSE: ${response.body}');

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final dynamic rawData = decoded['data'];

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true &&
          rawData is Map<String, dynamic>) {
        final String ticket = rawData['request_number']?.toString() ?? '';

        if (ticket.isEmpty) {
          throw const FormatException();
        }

        DateTime submittedAt = DateTime.now();

        final String? serverDate = rawData['submitted_at']?.toString();

        if (serverDate != null) {
          submittedAt = DateTime.tryParse(serverDate) ?? submittedAt;
        }

        if (!mounted) {
          return;
        }

        _clear();

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return WebsiteSuccessPage(
                requestNumber: ticket,

                fullName: fullName,

                identifierValue: identifier,

                websiteName: widget.websiteName,

                issueType: issue,

                submittedAt: submittedAt,
              );
            },
          ),
        );

        return;
      }

      if (!mounted) {
        return;
      }

      _message(
        decoded['message']?.toString() ?? 'Pengajuan Website gagal dikirim.',
      );
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      _message('Server tidak merespon. Periksa koneksi jaringan.');
    } on FormatException {
      if (!mounted) {
        return;
      }

      _message('Response dari server tidak valid.');
    } catch (e) {
      debugPrint('WEBSITE ERROR: $e');

      if (!mounted) {
        return;
      }

      _message('Tidak dapat terhubung ke server.');
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

  void _clear() {
    _nameController.clear();
    _identifierController.clear();
    _descriptionController.clear();
    _emailController.clear();

    setState(() {
      _selectedIssue = null;
      _supportFile = null;
      _formVersion++;
    });

    _formKey.currentState?.reset();
  }

  // =========================================================
  // RESET
  // =========================================================

  void _reset() {
    FocusScope.of(context).unfocus();

    _clear();

    _message('Form berhasil dikosongkan.');
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _message(String message) {
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
