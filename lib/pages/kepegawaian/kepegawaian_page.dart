import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'kepegawaian_success_page.dart';

class KepegawaianPage extends StatefulWidget {
  const KepegawaianPage({super.key});

  @override
  State<KepegawaianPage> createState() => _KepegawaianPageState();
}

class _KepegawaianPageState extends State<KepegawaianPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  String? _selectedUserCategory;
  String? _selectedUnitKerja;

  XFile? _supportFile;

  bool _isSubmitting = false;
  int _formVersion = 0;

  static const List<String> _userCategories = [
    'Dosen',
    'Tenaga Kependidikan',
    'Unit Kerja',
  ];

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

  @override
  void dispose() {
    _nameController.dispose();
    _nipController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  String _getApiUserCategory() {
    switch (_selectedUserCategory) {
      case 'Dosen':
        return 'dosen';

      case 'Tenaga Kependidikan':
        return 'tenaga_kependidikan';

      case 'Unit Kerja':
        return 'unit_kerja';

      default:
        return '';
    }
  }

  String _formattedPhone() {
    String phone = _phoneController.text.trim();

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    return '+62$phone';
  }

  Future<void> _pickSupportFile() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'File Pendukung',
        extensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

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
      debugPrint('FILE KEPEGAWAIAN ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Gagal memilih file.');
    }
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 11),
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
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //HEADER
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
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'Pusat Pertanyaan Kepegawaian',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 19),

                // =================================================
                // HERO
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 125,
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 28,
                        top: 0,
                        child: Text(
                          'Ada\nPertanyaan?',
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 28,
                            height: 0.95,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 28,
                        top: 70,
                        child: Text(
                          'Kirimkan Pertanyaan Anda, Tim Kami\nsiap Membantu.',
                          style: TextStyle(
                            color: Color(0xFF222222),
                            fontSize: 10,
                            height: 1.1,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                      Positioned(
                        right: 23,
                        top: 0,
                        child: Image.asset(
                          'assets/images/call.png',
                          width: 103,
                          height: 103,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Permintaan Data Kepegawaian',
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Home / Permintaan Data Kepegawaian',
                  style: TextStyle(
                    color: Color(0xFF1B63CB),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 15),

                // =================================================
                // FORM
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 13, 10, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
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
                          'Lengkapi data berikut sesuai dengan permasalahan anda:',
                          style: TextStyle(
                            color: Color(0xFF202020),
                            fontSize: 9.5,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // =================================================
                        // KATEGORI PENGGUNA
                        // =================================================
                        _fieldTitle('Kategori Pengguna'),

                        DropdownButtonFormField<String>(
                          key: ValueKey('kategori-$_formVersion'),
                          initialValue: _selectedUserCategory,
                          isExpanded: true,
                          decoration: _fieldDecoration(
                            hintText: 'Pilih kategori pengguna',
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19,
                          ),
                          items: _userCategories.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedUserCategory = value;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Kategori pengguna wajib dipilih';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        // =================================================
                        // UNIT KERJA
                        // =================================================
                        _fieldTitle('Unit Kerja'),

                        DropdownButtonFormField<String>(
                          key: ValueKey('unit-$_formVersion'),
                          initialValue: _selectedUnitKerja,
                          isExpanded: true,
                          decoration: _fieldDecoration(
                            hintText: 'Pilih unit kerja',
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19,
                          ),
                          items: _unitKerjaOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedUnitKerja = value;
                            });
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Unit kerja wajib dipilih';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        // =================================================
                        // NAMA LENGKAP
                        // =================================================
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

                        const SizedBox(height: 11),

                        // =================================================
                        // NIP
                        // =================================================
                        _fieldTitle('NIP'),

                        TextFormField(
                          controller: _nipController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(25),
                          ],
                          decoration: _fieldDecoration(
                            hintText: 'Masukkan NIP',
                          ),
                          validator: (String? value) {
                            final String nip = value?.trim() ?? '';

                            if (nip.isEmpty) {
                              return 'NIP wajib diisi';
                            }

                            if (nip.length < 5) {
                              return 'NIP belum sesuai';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        // =================================================
                        // EMAIL
                        // =================================================
                        _fieldTitle('Email'),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            hintText: 'Masukkan email',
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
                              return 'Format email belum sesuai';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        // =================================================
                        // TELEPON
                        // =================================================
                        _fieldTitle('No Telepon'),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4E4E4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '+62',
                                style: TextStyle(
                                  color: Color(0xFF202020),
                                  fontSize: 11,
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
                                  String phone = value?.trim() ?? '';

                                  if (phone.isEmpty) {
                                    return 'Nomor telepon wajib diisi';
                                  }

                                  if (phone.startsWith('0')) {
                                    phone = phone.substring(1);
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

                        const SizedBox(height: 11),

                        // =================================================
                        // JUDUL PERTANYAAN
                        // =================================================
                        _fieldTitle('Judul Pertanyaan'),

                        TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _fieldDecoration(
                            hintText: 'Masukkan judul pertanyaan',
                          ),
                          validator: (String? value) {
                            final String title = value?.trim() ?? '';

                            if (title.isEmpty) {
                              return 'Judul pertanyaan wajib diisi';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        // =================================================
                        // ISI PERTANYAAN
                        // =================================================
                        _fieldTitle('Isi Pertanyaan'),

                        SizedBox(
                          height: 115,
                          child: TextFormField(
                            controller: _questionController,
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: _fieldDecoration(
                              hintText:
                                  'Tuliskan pertanyaan atau permasalahan Anda',
                            ),
                            validator: (String? value) {
                              final String question = value?.trim() ?? '';

                              if (question.isEmpty) {
                                return 'Isi pertanyaan wajib diisi';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 13),

                        // =================================================
                        // FILE PENDUKUNG
                        // =================================================
                        _fieldTitle('Upload File Pendukung'),

                        _buildFileInput(),

                        const SizedBox(height: 6),

                        const Center(
                          child: Text(
                            'Upload hanya jika diperlukan file pendukung. Maksimal 5 MB.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Divider(color: Color(0xFF555555), thickness: 1),

                        const SizedBox(height: 18),

                        // =================================================
                        // BUTTON
                        // =================================================
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
  // SUBMIT
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

    setState(() {
      _isSubmitting = true;
    });

    // Simpan isi form sebelum form dikosongkan.
    final String userCategory = _getApiUserCategory();

    final String unitKerja = _selectedUnitKerja!;

    final String fullName = _nameController.text.trim();

    final String nip = _nipController.text.trim();

    final String email = _emailController.text.trim();

    final String phone = _formattedPhone();

    final String questionTitle = _titleController.text.trim();

    final String questionContent = _questionController.text.trim();

    try {
      final Uri url = Uri.parse(ApiConfig.createKepegawaian);

      final http.MultipartRequest request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'user_category': userCategory,
        'unit_name': unitKerja,
        'full_name': fullName,
        'nip': nip,
        'email': email,
        'phone': phone,
        'question_title': questionTitle,
        'question_content': questionContent,
      });

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

      // =====================================================
      // KIRIM KE SERVER
      // =====================================================

      final http.StreamedResponse streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 30));

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('KEPEGAWAIAN STATUS: ${response.statusCode}');

      debugPrint('KEPEGAWAIAN RESPONSE: ${response.body}');

      // =====================================================
      // JSON
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

        final String questionNumber = data['question_number']?.toString() ?? '';

        final String status =
            data['status']?.toString() ?? 'menunggu_verifikasi';

        final String estimatedResponse =
            data['estimated_response']?.toString() ?? '1-2 Hari Kerja';

        if (questionNumber.isEmpty) {
          throw const FormatException('Nomor pertanyaan tidak ditemukan.');
        }

        if (!mounted) {
          return;
        }

        // Kosongkan hanya setelah API berhasil.
        _clearForm();

        // ===================================================
        // MASUK KE HALAMAN SUCCESS
        // ===================================================

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return KepegawaianSuccessPage(
                questionNumber: questionNumber,
                userCategory: userCategory,
                fullName: fullName,
                nip: nip,
                unitKerja: unitKerja,
                questionTitle: questionTitle,
                status: status,
                estimatedResponse: estimatedResponse,
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
          responseData['message']?.toString() ?? 'Pertanyaan gagal dikirim.';

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
      debugPrint('FORMAT KEPEGAWAIAN ERROR: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Response dari server tidak valid.');
    } catch (e) {
      debugPrint('KEPEGAWAIAN ERROR: $e');

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
  // CLEAR FORM
  // =========================================================

  void _clearForm() {
    _nameController.clear();
    _nipController.clear();
    _emailController.clear();
    _phoneController.clear();
    _titleController.clear();
    _questionController.clear();

    setState(() {
      _selectedUserCategory = null;
      _selectedUnitKerja = null;
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
  // SNACKBAR
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
