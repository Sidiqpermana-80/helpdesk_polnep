import 'dart:async';
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import 'website_success_page.dart';
import '../../services/queue_notification_service.dart';
import '../../services/website_device_sync_service.dart';

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

  List<String> _issueOptions = <String>[];

  bool _isLoadingIssues = true;
  bool _hasIssueLoadError = false;

  @override
  void initState() {
    super.initState();

    _loadIssueOptions();
  }

  Future<void> _refreshPage() async {
    await _loadIssueOptions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  String _apiIssueType() {
    final String issue = _selectedIssue?.trim() ?? '';

    if (issue.isEmpty) {
      return '';
    }

    return issue
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  Future<void> _loadIssueOptions() async {
    if (mounted) {
      setState(() {
        _isLoadingIssues = true;
        _hasIssueLoadError = false;
      });
    }

    try {
      final http.Response response = await http
          .get(Uri.parse(ApiConfig.websiteIssueTypes))
          .timeout(const Duration(seconds: 20));

      debugPrint('WEBSITE ISSUE STATUS: ${response.statusCode}');
      debugPrint('WEBSITE ISSUE RESPONSE: ${response.body}');

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          decoded is! Map<String, dynamic> ||
          decoded['success'] != true) {
        throw const FormatException('Data jenis kendala tidak valid.');
      }

      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        throw const FormatException('Daftar jenis kendala tidak valid.');
      }

      final List<String> issues = rawData
          .whereType<Map<String, dynamic>>()
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
        _issueOptions = issues;

        if (_selectedIssue != null && !_issueOptions.contains(_selectedIssue)) {
          _selectedIssue = null;
        }

        _isLoadingIssues = false;
        _hasIssueLoadError = false;
      });
    } on TimeoutException {
      debugPrint('LOAD WEBSITE ISSUES ERROR: TimeoutException');

      if (!mounted) {
        return;
      }

      setState(() {
        _issueOptions = <String>[];
        _isLoadingIssues = false;
        _hasIssueLoadError = true;
      });
    } catch (e) {
      debugPrint('LOAD WEBSITE ISSUES ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _issueOptions = <String>[];
        _isLoadingIssues = false;
        _hasIssueLoadError = true;
      });
    }
  }

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

  InputDecoration _decoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),
      isDense: false,
      filled: true,
      fillColor: const Color(0xFFF3F4F8),
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
      errorStyle: const TextStyle(fontSize: 9),
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
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 11, 10, 16),
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
                          const Text(
                            'FORM PERTANYAAN',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 2),

                          const Text(
                            'Lengkapi data berikut sesuai dengan pilihan anda:',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10,
                            ),
                          ),

                          const SizedBox(height: 19),

                          _title('Nama Lengkap'),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 16,
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

                          const SizedBox(height: 13),

                          _title('NIM / NIP'),
                          TextFormField(
                            controller: _identifierController,
                            style: const TextStyle(
                              fontSize: 16,
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

                          const SizedBox(height: 13),

                          _title('Email'),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 16),
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

                          const SizedBox(height: 13),

                          _title('Pilihan Website'),

                          _lockedWebsite(),

                          const SizedBox(height: 13),

                          _title('Jenis Kendala'),
                          DropdownButtonFormField<String>(
                            key: ValueKey('issue-$_formVersion'),
                            initialValue: _selectedIssue,
                            isExpanded: true,
                            isDense: true,
                            dropdownColor: const Color(0xFFF0F7FF),
                            menuMaxHeight: 220,
                            style: const TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 16,
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: Color(0xFF555555),
                            ),
                            decoration: _decoration(
                              hintText: _isLoadingIssues
                                  ? 'Memuat jenis kendala...'
                                  : _hasIssueLoadError
                                  ? 'Gagal memuat jenis kendala'
                                  : 'Pilih jenis kendala',
                            ),
                            items: _issueOptions.map((String issue) {
                              return DropdownMenuItem<String>(
                                value: issue,
                                child: Text(
                                  issue,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged:
                                _isLoadingIssues ||
                                    _hasIssueLoadError ||
                                    _issueOptions.isEmpty
                                ? null
                                : (String? value) {
                                    setState(() {
                                      _selectedIssue = value;
                                    });
                                  },
                            validator: (String? value) {
                              if (_isLoadingIssues) {
                                return 'Jenis kendala masih dimuat';
                              }

                              if (_hasIssueLoadError) {
                                return 'Jenis kendala gagal dimuat';
                              }

                              if (_issueOptions.isEmpty) {
                                return 'Jenis kendala tidak tersedia';
                              }

                              if (value == null || value.isEmpty) {
                                return 'Jenis kendala wajib dipilih';
                              }
                              return null;
                            },
                          ),

                          if (_hasIssueLoadError)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _loadIssueOptions,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 13,
                                  ),
                                  label: const Text(
                                    'Coba Lagi',
                                    style: TextStyle(fontSize: 10.5),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF168DE2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    minimumSize: const Size(0, 25),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 13),

                          _title('Deskripsikan Permasalahan Anda'),
                          SizedBox(
                            height: 115,
                            child: TextFormField(
                              controller: _descriptionController,
                              style: const TextStyle(
                                fontSize: 16,
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

                          const SizedBox(height: 13),

                          _title('Upload File Pendukung'),

                          _fileInput(),

                          const SizedBox(height: 5),

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

                          const SizedBox(height: 23),

                          const Divider(
                            color: Color(0xFF555555),
                            thickness: 0.8,
                            height: 1,
                          ),

                          const SizedBox(height: 18),

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
                                    'Pastikan website yang dipilih dan data laporan sudah benar.\n'
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submit,
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
                                  onPressed: _isSubmitting ? null : _reset,
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

  Widget _lockedWebsite() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF),
        borderRadius: BorderRadius.circular(5),
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
                fontSize: 16,
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

  Widget _fileInput() {
    final bool hasFile = _supportFile != null;

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.centerLeft,
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
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 10.5,
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
            width: 105,
            height: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _pickSupportFile,
              icon: const Icon(
                Icons.folder,
                color: Color(0xFFFFB52D),
                size: 15,
              ),
              label: const Text('Choose File', style: TextStyle(fontSize: 9.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58C761),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 3),
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

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final issue = _apiIssueType();

    if (issue.isEmpty) {
      _message('Jenis kendala tidak valid.');
      return;
    }

    final fullName = _nameController.text.trim();
    final identifier = _identifierController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final description = _descriptionController.text.trim();
    final websiteName = widget.websiteName;
    final supportFile = _supportFile;
    final issueLabel = _selectedIssue?.trim() ?? '';
    final supportFileName = _supportFile?.name ?? '';

    setState(() {
      _isSubmitting = true;
    });

    try {
      await QueueNotificationService.instance.enableNotifications();

      final fcmToken = await QueueNotificationService.instance
          .tokenForSubmission();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.createWebsite),
      );

      request.headers['Accept'] = 'application/json';

      request.fields.addAll({
        'full_name': fullName,
        'identifier_value': identifier,
        'email': email,
        'website_name': websiteName,
        'issue_type': issue,
        'description': description,

        if (fcmToken != null && fcmToken.isNotEmpty) ...{
          'fcm_token': fcmToken,
          'device_platform': 'android',
        },
      });

      if (supportFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'support_file',
            await supportFile.readAsBytes(),
            filename: supportFile.name,
          ),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(
        streamed,
      ).timeout(const Duration(seconds: 30));

      debugPrint('WEBSITE STATUS: ${response.statusCode}');

      final dynamic decoded = jsonDecode(response.body);

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
          return;
        }

        var message =
            decoded['message']?.toString() ??
            'Pengajuan Website gagal dikirim.';

        final errors = decoded['errors'];

        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;

          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        }

        _message(message);
        return;
      }

      final rawData = decoded['data'];

      if (rawData is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final id = int.tryParse(rawData['id']?.toString() ?? '') ?? 0;

      final ticket = rawData['request_number']?.toString().trim() ?? '';

      if (id <= 0 || ticket.isEmpty) {
        throw const FormatException();
      }

      final submittedAt =
          DateTime.tryParse(
            rawData['submitted_at']?.toString() ?? '',
          )?.toLocal() ??
          DateTime.now();

      final syncKey = rawData['device_sync_key']?.toString() ?? '';

      if (syncKey.isNotEmpty) {
        try {
          await WebsiteDeviceSyncService.instance.rememberTicket(
            id: id,
            key: syncKey,
          );
        } catch (_) {
          debugPrint('WEBSITE: kunci sinkronisasi belum berhasil disimpan.');
        }
      }

      unawaited(
        QueueNotificationService.instance.showWebsiteTicketCreated(
          ticketId: id,
          requestNumber: ticket,
        ),
      );

      if (!mounted) {
        return;
      }

      _clear();

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => WebsiteSuccessPage(
            requestNumber: ticket,
            fullName: fullName,
            identifierValue: identifier,
            websiteName: websiteName,
            issueType: issue,
            issueLabel: issueLabel,
            submittedAt: submittedAt,
            email: email,
            description: description,
            supportFileName: supportFileName,
            status: rawData['status']?.toString() ?? 'menunggu_verifikasi',
            estimatedResponse: rawData['estimated_response']?.toString() ?? '',
            emailSent: rawData['email_sent'] == true,
          ),
        ),
      );
    } catch (error) {
      debugPrint('WEBSITE SUBMIT ERROR: ${error.runtimeType}');

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

  void _reset() {
    FocusScope.of(context).unfocus();

    _clear();

    _message('Form berhasil dikosongkan.');
  }

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
