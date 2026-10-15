import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

class CekStatusPage extends StatefulWidget {
  const CekStatusPage({
    super.key,
    this.initialKeyword = '',
    this.notificationKeyword,
  });

  final String initialKeyword;

  final ValueListenable<String?>? notificationKeyword;

  @override
  State<CekStatusPage> createState() => _CekStatusPageState();
}

class _CekStatusPageState extends State<CekStatusPage>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _keywordController = TextEditingController();

  bool _isLoading = false;

  int _searchVersion = 0;

  bool _hasSearched = false;

  List<StatusTicketData> _results = [];

  Timer? _countdownTimer;

  String? _lastSearchedKeyword;
  bool _autoRefreshing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _keywordController.text = widget.initialKeyword.trim();

    widget.notificationKeyword?.addListener(_onNotificationKeyword);

    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        if (_results.isNotEmpty) {
          setState(() {});
        }

        unawaited(_autoRefreshStatus());
      }
    });
  }

  @override
  void didUpdateWidget(covariant CekStatusPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.notificationKeyword != widget.notificationKeyword) {
      oldWidget.notificationKeyword?.removeListener(_onNotificationKeyword);

      widget.notificationKeyword?.addListener(_onNotificationKeyword);
    }

    if (oldWidget.initialKeyword != widget.initialKeyword) {
      _applyNotificationKeyword(widget.initialKeyword);
    }
  }

  void _onNotificationKeyword() {
    _applyNotificationKeyword(widget.notificationKeyword?.value ?? '');
  }

  void _applyNotificationKeyword(String value) {
    final String keyword = value.trim();

    if (!mounted || keyword.isEmpty) {
      return;
    }

    // Abaikan respons pencarian lama ketika tiket yang dituju berubah.
    _searchVersion++;

    _lastSearchedKeyword = null;

    _formKey.currentState?.reset();

    _keywordController.value = TextEditingValue(
      text: keyword,
      selection: TextSelection.collapsed(offset: keyword.length),
    );

    setState(() {
      _isLoading = false;
      _hasSearched = false;
      _results = [];
    });
  }

  Future<void> _refreshPage() async {
    final String keyword = _keywordController.text.trim();

    if (keyword.isEmpty || _isLoading) {
      return;
    }

    await _submitSearch();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_autoRefreshStatus());
    }
  }

  @override
  void dispose() {
    widget.notificationKeyword?.removeListener(_onNotificationKeyword);

    WidgetsBinding.instance.removeObserver(this);

    _searchVersion++;
    _countdownTimer?.cancel();
    _keywordController.dispose();

    super.dispose();
  }

  Future<void> _autoRefreshStatus() async {
    if (!mounted) {
      return;
    }

    final String? keyword = _lastSearchedKeyword;

    if (_isLoading ||
        _autoRefreshing ||
        !_hasSearched ||
        keyword == null ||
        keyword != _keywordController.text.trim() ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    final bool hasActiveUlt = _results.any(
      (ticket) =>
          ticket.type == 'antrian_tiket' &&
          const [
            'menunggu_antrian',
            'dipanggil',
            'sedang_dilayani',
          ].contains(ticket.status),
    );

    if (!hasActiveUlt) {
      return;
    }

    _autoRefreshing = true;

    final int requestVersion = _searchVersion;

    try {
      final http.Response response = await http
          .post(
            Uri.parse(ApiConfig.cekStatus),
            headers: const {'Accept': 'application/json'},
            body: {'keyword': keyword},
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted ||
          requestVersion != _searchVersion ||
          keyword != _keywordController.text.trim()) {
        return;
      }

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          decoded is! Map ||
          decoded['success'] != true ||
          decoded['data'] is! List) {
        return;
      }

      final List<StatusTicketData> tickets = [];

      for (final dynamic item in decoded['data'] as List) {
        if (item is Map) {
          tickets.add(
            StatusTicketData.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }

      setState(() {
        _results = tickets;
      });
    } catch (_) {
      // Pertahankan hasil terakhir jika koneksi gagal.
      // Pemeriksaan berikutnya akan mencoba lagi.
    } finally {
      _autoRefreshing = false;
    }
  }

  Future<void> _submitSearch() async {
    FocusScope.of(context).unfocus();

    final bool isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _isLoading) {
      return;
    }

    final int requestVersion = ++_searchVersion;

    final String keyword = _keywordController.text.trim();

    setState(() {
      _isLoading = true;
      _hasSearched = false;
      _results = [];
    });

    try {
      final http.Response response = await http
          .post(
            Uri.parse(ApiConfig.cekStatus),
            headers: const {'Accept': 'application/json'},
            body: {'keyword': keyword},
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted || requestVersion != _searchVersion) {
        return;
      }

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map<String, dynamic> &&
          decoded['success'] == true) {
        final dynamic rawData = decoded['data'];

        final List<StatusTicketData> tickets = [];

        if (rawData is List) {
          for (final dynamic item in rawData) {
            if (item is Map<String, dynamic>) {
              tickets.add(StatusTicketData.fromJson(item));
            } else if (item is Map) {
              tickets.add(
                StatusTicketData.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }

        setState(() {
          _results = tickets;
          _lastSearchedKeyword = keyword;
          _hasSearched = true;
        });

        return;
      }

      String message = 'Gagal mengambil data status.';

      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }

      _showMessage(message);
    } on TimeoutException {
      if (!mounted || requestVersion != _searchVersion) {
        return;
      }

      _showMessage('Layanan belum merespons. Silakan coba kembali.');
    } catch (error) {
      if (!mounted || requestVersion != _searchVersion) {
        return;
      }

      debugPrint('CEK STATUS ERROR: $error');

      _showMessage(
        'Tidak dapat terhubung ke layanan. '
        'Periksa koneksi dan coba kembali.',
      );
    } finally {
      if (mounted && requestVersion == _searchVersion) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
              stops: [0.00, 0.48, 1.00],
            ),
          ),

          child: RefreshIndicator(
            onRefresh: _refreshPage,

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),

              padding: const EdgeInsets.fromLTRB(20, 17, 20, 25),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  _buildHeader(),

                  const SizedBox(height: 43),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),

                    child: Text(
                      'Untuk mengecek status permintaan, harap masukkan\n'
                      'Email atau Kode Tiket Anda.',
                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 11,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 17),

                  const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFF333333),
                  ),

                  const SizedBox(height: 40),

                  // FORM PENCARIAN
                  Form(
                    key: _formKey,

                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const SizedBox(
                              width: 90,

                              child: Padding(
                                padding: EdgeInsets.only(top: 13),

                                child: Text(
                                  'Email / Kode Tiket',
                                  textAlign: TextAlign.right,

                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 9.5,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 9),

                            Expanded(
                              child: TextFormField(
                                controller: _keywordController,

                                keyboardType: TextInputType.text,

                                textInputAction: TextInputAction.done,

                                onFieldSubmitted: (_) {
                                  _submitSearch();
                                },

                                decoration: InputDecoration(
                                  hintText: 'Masukkan Email atau Kode Tiket',

                                  hintStyle: const TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 8.5,
                                  ),

                                  filled: true,

                                  fillColor: const Color(0xFFF0F0F0),

                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),

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
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3AA7F5),
                                      width: 1.4,
                                    ),
                                  ),

                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1,
                                    ),
                                  ),

                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 1.2,
                                    ),
                                  ),
                                ),

                                validator: (String? value) {
                                  final String keyword = value?.trim() ?? '';

                                  if (keyword.isEmpty) {
                                    return 'Email atau Kode Tiket wajib diisi';
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // KIRIM
                        SizedBox(
                          width: 105,
                          height: 38,

                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitSearch,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6E7EF4),

                              disabledBackgroundColor: const Color(0xFFAAB3F7),

                              foregroundColor: Colors.white,

                              elevation: 0,

                              padding: EdgeInsets.zero,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),

                            child: _isLoading
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,

                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Kirim',

                                    style: TextStyle(
                                      fontSize: 9.5,

                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_hasSearched) ...[
                    const SizedBox(height: 22),

                    _buildResultContainer(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },

          padding: EdgeInsets.zero,

          constraints: const BoxConstraints(),

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,

            color: Color(0xFF111111),

            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        const Text(
          'Cek Status',

          style: TextStyle(
            color: Color(0xFF111111),

            fontSize: 16,

            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultContainer() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: const Color(0xFFDCEAF4), width: 0.7),

        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),

            blurRadius: 4,

            offset: Offset(0, 2),
          ),
        ],
      ),

      child: _results.isEmpty ? _buildEmptyResult() : _buildTicketResults(),
    );
  }

  Widget _buildTicketResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Status Permintaan',

          style: TextStyle(
            color: Color(0xFF202020),

            fontSize: 12,

            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          'Ditemukan ${_results.length} tiket',

          style: const TextStyle(color: Color(0xFF777777), fontSize: 8.5),
        ),

        const SizedBox(height: 10),

        for (int index = 0; index < _results.length; index++) ...[
          _buildTicketCard(_results[index]),

          if (index != _results.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildEmptyResult() {
    return SizedBox(
      height: 210,

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 55,
              height: 55,

              decoration: const BoxDecoration(
                color: Color(0xFFE9F5FF),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.search_rounded,

                size: 29,

                color: Color(0xFF168DE2),
              ),
            ),

            const SizedBox(height: 11),

            const Text(
              'Tiket Tidak Ditemukan',

              style: TextStyle(
                color: Color(0xFF202020),

                fontSize: 12,

                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Belum ada permintaan yang ditemukan\n'
              'dengan Email atau Kode Tiket tersebut.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Color(0xFF777777),

                fontSize: 9,

                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(StatusTicketData ticket) {
    if (ticket.type.toLowerCase() == 'antrian_tiket') {
      return _buildQueueTicketCard(ticket);
    }

    return _buildRegularTicketCard(ticket);
  }

  Widget _buildRegularTicketCard(StatusTicketData ticket) {
    final Color statusColor = _getStatusColor(ticket.status);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: const Color(0xFFD0D0D0), width: 0.7),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // STATUS TIKET
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  ticket.requestNumber.toUpperCase(),

                  style: const TextStyle(
                    color: Color(0xFF315D9D),

                    fontSize: 10.5,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.13),

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(color: statusColor, width: 0.7),
                ),

                child: Text(
                  ticket.statusLabel,

                  style: TextStyle(
                    color: statusColor,

                    fontSize: 7.5,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // JENIS LAYANAN
          Text(
            ticket.typeLabel,

            style: const TextStyle(
              color: Color(0xFF202020),

              fontSize: 9,

              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 9),

          // DETAIL
          _resultRow('Layanan', ticket.service),

          const SizedBox(height: 5),

          _resultRow('Tanggal', ticket.dateLabel),
        ],
      ),
    );
  }

  // CARD ANTRIAN TIKET
  Widget _buildQueueTicketCard(StatusTicketData ticket) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(11, 11, 11, 12),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: const Color(0xFFD0D0D0), width: 0.7),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      ticket.requestNumber.toUpperCase(),

                      style: const TextStyle(
                        color: Color(0xFF315D9D),

                        fontSize: 10.5,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Antrian Tiket',

                      style: TextStyle(
                        color: Color(0xFF202020),

                        fontSize: 9,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8EC),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: const Color(0xFF2EAA42),

                    width: 2.5,
                  ),
                ),

                alignment: Alignment.center,

                child: Text(
                  ticket.queueNumber ?? '-',

                  style: const TextStyle(
                    color: Color(0xFF2EAA42),

                    fontSize: 16,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(height: 1, thickness: 0.7, color: Color(0xFFD4D4D4)),

          const SizedBox(height: 11),

          _resultRow('Layanan', ticket.service),

          const SizedBox(height: 8),

          if (ticket.type == 'antrian_tiket') ...[
            _resultRow('Jam Pilihan', ticket.queueTimeLabel ?? '-'),

            const SizedBox(height: 8),

            if (ticket.status == 'menunggu_antrian' &&
                ticket.peopleAhead != null) ...[
              _resultRow('Di Depan', '${ticket.peopleAhead} orang'),

              const SizedBox(height: 8),
            ],
          ],

          if (ticket.type == 'antrian_tiket' &&
              ticket.status == 'dibatalkan' &&
              (ticket.cancellationReason?.trim().isNotEmpty ?? false)) ...[
            _resultRow('Alasan', ticket.cancellationReason!),

            const SizedBox(height: 8),
          ],

          _resultRow('Estimasi', ticket.estimatedStart ?? '-'),

          if (ticket.estimatedStartTime != null) ...[
            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(left: 88),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Icon(
                    _queueCountdownIcon(ticket),

                    size: 13,

                    color: _queueCountdownColor(ticket),
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: Text(
                      _queueCountdownText(ticket),

                      style: TextStyle(
                        color: _queueCountdownColor(ticket),

                        fontSize: 8.5,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          _resultRow('Tanggal', ticket.dateLabel),
        ],
      ),
    );
  }

  String _queueCountdownText(StatusTicketData ticket) {
    final String status = ticket.status.toLowerCase();

    switch (status) {
      case 'dipanggil':
        return 'Anda sedang dipanggil';

      case 'sedang_dilayani':
        return 'Sedang dilayani';

      case 'selesai':
        return 'Layanan selesai';

      case 'dibatalkan':
        return 'Tiket dibatalkan';
    }

    final DateTime? estimated = ticket.estimatedStartTime;

    if (estimated == null) {
      return '';
    }

    final Duration difference = estimated.difference(DateTime.now());

    if (difference.inSeconds <= 0) {
      return 'Estimasi giliran telah tiba';
    }

    final int minutes = (difference.inSeconds / 60).ceil();

    if (minutes <= 1) {
      return 'Kurang dari 1 menit lagi';
    }

    if (minutes < 60) {
      return '$minutes menit lagi';
    }

    final int hours = minutes ~/ 60;

    final int remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours jam lagi';
    }

    return '$hours jam $remainingMinutes menit lagi';
  }

  Color _queueCountdownColor(StatusTicketData ticket) {
    switch (ticket.status.toLowerCase()) {
      case 'dipanggil':
        return const Color(0xFF7C68E8);

      case 'sedang_dilayani':
        return const Color(0xFF168DE2);

      case 'selesai':
        return const Color(0xFF39B54A);

      case 'dibatalkan':
        return const Color(0xFFE84B4B);

      default:
        return const Color(0xFF2EAA42);
    }
  }

  IconData _queueCountdownIcon(StatusTicketData ticket) {
    switch (ticket.status.toLowerCase()) {
      case 'dipanggil':
        return Icons.notifications_active_rounded;

      case 'sedang_dilayani':
        return Icons.support_agent_rounded;

      case 'selesai':
        return Icons.check_circle_outline_rounded;

      case 'dibatalkan':
        return Icons.cancel_outlined;

      default:
        return Icons.access_time_rounded;
    }
  }

  // BARIS DETAIL
  Widget _resultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(
          width: 82,

          child: Text(
            label,

            style: const TextStyle(color: Color(0xFF777777), fontSize: 8),
          ),
        ),

        const Text(
          ':',

          style: TextStyle(color: Color(0xFF777777), fontSize: 8),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,

            style: const TextStyle(
              color: Color(0xFF222222),

              fontSize: 8.5,

              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF39B54A);

      case 'diproses':
      case 'sedang_dilayani':
      case 'terverifikasi':
      case 'dijawab':
        return const Color(0xFF168DE2);

      case 'dipanggil':
        return const Color(0xFF7C68E8);

      case 'ditolak':
      case 'dibatalkan':
        return const Color(0xFFE84B4B);

      case 'menunggu_verifikasi':
      case 'menunggu_antrian':
      default:
        return const Color(0xFFFFA726);
    }
  }
}

class StatusTicketData {
  const StatusTicketData({
    required this.requestNumber,
    required this.type,
    required this.typeLabel,
    required this.service,
    required this.status,
    required this.statusLabel,
    required this.dateLabel,
    this.queueNumber,
    this.peopleAhead,
    this.queueTimeLabel,
    this.estimatedStart,
    this.estimatedStartTime,
    this.cancellationReason,
  });

  final String requestNumber;
  final String type;
  final String typeLabel;
  final String service;
  final String status;
  final String statusLabel;
  final String dateLabel;

  final String? queueNumber;
  final int? peopleAhead;
  final String? queueTimeLabel;

  final String? estimatedStart;
  final DateTime? estimatedStartTime;

  final String? cancellationReason;

  factory StatusTicketData.fromJson(Map<String, dynamic> json) {
    return StatusTicketData(
      requestNumber: json['request_number']?.toString() ?? '-',

      type: json['type']?.toString() ?? '',

      typeLabel: json['type_label']?.toString() ?? '-',

      service: json['service']?.toString() ?? '-',

      status: json['status']?.toString() ?? '',

      statusLabel: json['status_label']?.toString() ?? '-',

      dateLabel: json['date_label']?.toString() ?? '-',

      queueNumber: json['queue_number']?.toString(),

      peopleAhead: int.tryParse(json['people_ahead']?.toString() ?? ''),

      queueTimeLabel: json['queue_time_label']?.toString(),

      estimatedStart: json['estimated_start_label']?.toString(),

      estimatedStartTime: _parseEstimatedStartTime(
        json['estimated_start_time'],
      ),

      cancellationReason: json['cancellation_reason']?.toString(),
    );
  }

  static DateTime? _parseEstimatedStartTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final String text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}
