import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/akademik_queue_service.dart';
import '../../services/akademik_device_sync_service.dart';
import '../../services/queue_notification_service.dart';
import '../cek_status/cek_status_page.dart';
import 'akademik_queue_time_field.dart';
import 'akademik_success_page.dart';

class AkademikPage extends StatefulWidget {
  const AkademikPage({super.key});

  @override
  State<AkademikPage> createState() => _AkademikPageState();
}

class _AkademikPageState extends State<AkademikPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _description = TextEditingController();

  AkademikQueueOptions? _options;

  String? _studentStatusId;
  String? _purposeId;
  String? _optionsError;

  bool _loadingOptions = false;
  bool _submitting = false;
  bool _datePickerOpen = false;

  int _formVersion = 0;

  DateTime _selectedQueueDate = DateUtils.dateOnly(AkademikQueueSchedule.now());

  int? _selectedQueueMinute;

  DateTime get _today {
    return DateUtils.dateOnly(AkademikQueueSchedule.now());
  }

  bool get _optionsReady {
    return !_loadingOptions &&
        _optionsError == null &&
        _options != null &&
        _options!.studentStatuses.isNotEmpty &&
        _options!.purposes.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadOptions());
  }

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _phone.dispose();
    _email.dispose();
    _description.dispose();
    super.dispose();
  }

  // =======================================================
  // PILIHAN DARI ADMIN
  // =======================================================

  Future<void> _loadOptions() async {
    if (_loadingOptions || _submitting) return;

    setState(() {
      _loadingOptions = true;
      _optionsError = null;
    });

    try {
      final options = await AkademikQueueService.loadOptions();

      if (!mounted) return;

      setState(() {
        _options = options;

        if (!options.studentStatuses.any(
          (item) => item.id == _studentStatusId,
        )) {
          _studentStatusId = null;
        }

        if (!options.purposes.any((item) => item.id == _purposeId)) {
          _purposeId = null;
        }

        _formVersion++;
      });
    } on AkademikQueueException catch (error) {
      if (mounted) {
        setState(() => _optionsError = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _optionsError = 'Pilihan belum dapat dimuat dari server.';
        });
      }
    } finally {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  // =======================================================
  // TANGGAL ANTRIAN
  // =======================================================

  String _displayDate(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectQueueDate() async {
    if (_submitting || _datePickerOpen) return;

    FocusScope.of(context).unfocus();
    setState(() => _datePickerOpen = true);

    try {
      final calendar = await AkademikQueueService.loadCalendar();

      if (!mounted) return;

      final first = _today.isAfter(calendar.firstDate)
          ? _today
          : calendar.firstDate;

      final last = calendar.lastDate;

      if (first.isAfter(last)) {
        _message('Kalender layanan perlu diperbarui.');
        return;
      }

      var initial = _selectedQueueDate;

      if (initial.isBefore(first) || initial.isAfter(last)) {
        initial = first;
      }

      final openDate = calendar.nextOpen(initial) ?? calendar.nextOpen(first);

      if (openDate == null) {
        _message('Belum ada tanggal layanan yang tersedia.');
        return;
      }

      final selected = await showDatePicker(
        context: context,
        initialDate: openDate,
        firstDate: first,
        lastDate: last,
        selectableDayPredicate: calendar.isOpen,
        initialEntryMode: DatePickerEntryMode.calendar,
        helpText: 'Pilih Tanggal Antrian',
        cancelText: 'Batal',
        confirmText: 'Pilih',
      );

      if (!mounted || selected == null) return;

      if (selected.isBefore(_today) || !calendar.isOpen(selected)) {
        _message('Tanggal layanan tidak tersedia. Pilih tanggal lain.');
        return;
      }

      setState(() {
        if (!DateUtils.isSameDay(selected, _selectedQueueDate)) {
          _selectedQueueMinute = null;
        }

        _selectedQueueDate = DateUtils.dateOnly(selected);
      });
    } catch (_) {
      if (mounted) {
        _message('Kalender layanan belum dapat dimuat. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _datePickerOpen = false);
    }
  }

  // =======================================================
  // RESET DAN PESAN
  // =======================================================

  void _resetForm({bool notify = true}) {
    FocusScope.of(context).unfocus();

    _formKey.currentState?.reset();

    _name.clear();
    _nim.clear();
    _phone.clear();
    _email.clear();
    _description.clear();

    setState(() {
      _studentStatusId = null;
      _purposeId = null;
      _selectedQueueDate = _today;
      _selectedQueueMinute = null;
      _formVersion++;
    });

    if (notify) _message('Form berhasil dikosongkan.');
  }

  void _message(String message, {bool checkStatus = false}) {
    final keyword = _email.text.trim();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: checkStatus ? 10 : 4),
          action: checkStatus
              ? SnackBarAction(
                  label: 'Cek Status',
                  onPressed: () {
                    if (!mounted) return;

                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CekStatusPage(initialKeyword: keyword),
                      ),
                    );
                  },
                )
              : null,
        ),
      );
  }

  // =======================================================
  // KIRIM PENGAJUAN
  // =======================================================

  Future<void> _submit() async {
    if (_submitting || _datePickerOpen) return;

    FocusScope.of(context).unfocus();

    if (!_optionsReady) {
      _message('Pilihan Status Mahasiswa dan Keperluan harus tersedia dahulu.');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final date = _selectedQueueDate;
    final minute = _selectedQueueMinute;

    if (minute == null || !AkademikQueueSchedule.isSelectable(date, minute)) {
      _message('Silakan pilih tanggal dan jam antrian yang belum lewat.');
      return;
    }

    final fullName = _name.text.trim();
    final nim = _nim.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final description = _description.text.trim();

    final studentStatus = _options!.studentStatuses.firstWhere(
      (item) => item.id == _studentStatusId,
    );

    final purpose = _options!.purposes.firstWhere(
      (item) => item.id == _purposeId,
    );

    setState(() => _submitting = true);

    var submissionStarted = false;

    try {
      final notifications = QueueNotificationService.instance;

      String? token;

      try {
        token = await notifications.tokenForSubmission();
      } catch (_) {
        debugPrint('AKADEMIK: token notifikasi belum tersedia.');
      }

      if (!mounted) return;

      final slots = await AkademikQueueService.slots(date);

      if (!mounted) return;

      if (!slots.open) {
        _message(slots.reason ?? 'Layanan tutup pada tanggal ini.');
        return;
      }

      final available = slots.slots.any(
        (slot) => slot.minute == minute && slot.available,
      );

      if (!AkademikQueueSchedule.isSelectable(date, minute) || !available) {
        setState(() => _selectedQueueMinute = null);

        _message('Jam sudah dipesan atau sudah lewat. Silakan pilih ulang.');
        return;
      }

      submissionStarted = true;

      final ticket = await AkademikQueueService.createTicket(
        fullName: fullName,
        nim: nim,
        phone: phone,
        email: email,
        studentStatusId: studentStatus.id,
        purposeId: purpose.id,
        description: description,
        queueDate: date,
        queueTime: AkademikQueueSchedule.formatMinute(minute, separator: ':'),
        fcmToken: token,
      );

      final key = ticket.deviceSyncKey;

      if (key != null && key.isNotEmpty) {
        try {
          await AkademikDeviceSyncService.instance.rememberTicket(
            id: ticket.id,
            key: key,
          );
        } catch (_) {
          debugPrint('AKADEMIK: kunci sinkronisasi belum tersimpan.');
        }
      }

      unawaited(
        notifications.showAcademicTicketCreated(
          ticketId: ticket.id,
          requestNumber: ticket.requestNumber,
          queueDateLabel: ticket.dateLabel,
          queueTimeLabel: ticket.timeLabel,
        ),
      );

      if (!mounted) return;

      _resetForm(notify: false);

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AkademikSuccessPage(
            ticket: ticket,
            fullName: fullName,
            nim: nim,
            phone: phone,
            email: email,
            studentStatus: studentStatus.name,
            purpose: purpose.name,
            description: description,
          ),
        ),
      );
    } on AkademikQueueException catch (error) {
      if (mounted) {
        _message(error.message, checkStatus: error.checkStatus);
      }
    } catch (_) {
      if (mounted) {
        _message(
          submissionStarted
              ? 'Hasil pengajuan belum dapat dipastikan. '
                    'Cek Status dengan email sebelum mengirim ulang.'
              : 'Tidak dapat terhubung ke server. Silakan coba lagi.',
          checkStatus: submissionStarted,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // =======================================================
  // TAMPILAN FIELD MENGIKUTI ULT
  // =======================================================

  Widget _asset(String path, IconData fallback, {bool service = false}) {
    final size = service ? 21.0 : 20.0;

    return Padding(
      padding: EdgeInsets.all(service ? 7.0 : 8.0),
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) {
          return Icon(fallback, size: size, color: const Color(0xFF168DE2));
        },
      ),
    );
  }

  InputDecoration _decoration(String hint, {Widget? icon}) {
    OutlineInputBorder border(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),
      prefixIcon: icon,
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 42),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      border: border(const Color(0xFF8D8D8D), 0.8),
      enabledBorder: border(const Color(0xFF8D8D8D), 0.8),
      focusedBorder: border(const Color(0xFF3AA7F5), 1.4),
      errorBorder: border(Colors.red, 1),
      focusedErrorBorder: border(Colors.red, 1.3),
    );
  }

  Widget _field(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202020),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<AkademikQueueOption> options,
    required ValueChanged<String?> onChanged,
    required Widget icon,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$_formVersion'),
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 300,
      dropdownColor: const Color(0xFFF0F7FF),
      decoration: _decoration(
        _loadingOptions ? 'Memuat pilihan...' : 'Pilih $label',
        icon: icon,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: Color(0xFF222222),
      ),
      style: const TextStyle(color: Color(0xFF202020), fontSize: 14),
      items: options.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: _submitting || !_optionsReady ? null : onChanged,
      validator: (selected) {
        return options.any((item) => item.id == selected)
            ? null
            : '$label wajib dipilih';
      },
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _submitting || _datePickerOpen ? null : _selectQueueDate,
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
                _datePickerOpen
                    ? 'Memuat kalender...'
                    : '${DateUtils.isSameDay(_selectedQueueDate, _today) ? 'Hari ini, ' : ''}'
                          '${_displayDate(_selectedQueueDate)}',
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

  Widget _dateInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF9CCDF2), width: 0.7),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 17, color: Color(0xFF168DE2)),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tekan kalender untuk memilih tanggal kedatangan. '
              'Sabtu, Minggu, dan libur nasional tidak melayani antrian.',
              style: TextStyle(
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

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 40,
          child: ElevatedButton(
            onPressed: _submitting || _datePickerOpen ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5868FF),
              disabledBackgroundColor: const Color(0xFFADB5F5),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: _submitting
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
            onPressed: _submitting || _datePickerOpen
                ? null
                : () => _resetForm(),
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
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // =======================================================
  // HALAMAN UTAMA
  // =======================================================

  @override
  Widget build(BuildContext context) {
    final options = _options;

    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9FF),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0F9FF),
                  Color(0xFFD7EEFF),
                  Color(0xFFB9E1FF),
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: _loadOptions,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 21,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Akademik',
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // HERO SAMA SEPERTI ULT
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
                            _field('Tanggal Antrian', _dateField()),

                            _field(
                              'Jam Antrian',
                              AkademikQueueTimeField(
                                key: ValueKey(
                                  akademikDateKey(_selectedQueueDate),
                                ),
                                date: _selectedQueueDate,
                                selectedMinute: _selectedQueueMinute,
                                enabled: !_submitting && !_datePickerOpen,
                                onChanged: (minute) {
                                  setState(() {
                                    _selectedQueueMinute = minute;
                                  });
                                },
                              ),
                            ),

                            _dateInformation(),

                            const SizedBox(height: 18),
                            const Divider(
                              color: Color(0xFF555555),
                              thickness: 1,
                            ),
                            const SizedBox(height: 10),

                            const Text(
                              'Silakan isi data mahasiswa berikut.',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 9.5,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // NAMA
                            _field(
                              'Nama',
                              TextFormField(
                                controller: _name,
                                enabled: !_submitting,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(150),
                                ],
                                decoration: _decoration(
                                  'Masukkan nama lengkap',
                                  icon: _asset(
                                    'assets/images/pp.png',
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                                validator: (value) {
                                  final name = value?.trim() ?? '';

                                  if (name.isEmpty) return 'Nama wajib diisi';
                                  if (name.length < 3)
                                    return 'Nama belum sesuai';

                                  return null;
                                },
                              ),
                            ),

                            // NIM
                            _field(
                              'NIM',
                              TextFormField(
                                controller: _nim,
                                enabled: !_submitting,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                decoration: _decoration(
                                  'Masukkan NIM',
                                  icon: _asset(
                                    'assets/images/book.png',
                                    Icons.badge_outlined,
                                  ),
                                ),
                                validator: (value) {
                                  final nim = value?.trim() ?? '';

                                  if (nim.isEmpty) return 'NIM wajib diisi';
                                  if (nim.length < 5) return 'NIM belum sesuai';

                                  return null;
                                },
                              ),
                            ),

                            // NO. HP
                            _field(
                              'No. HP',
                              TextFormField(
                                controller: _phone,
                                enabled: !_submitting,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(13),
                                ],
                                decoration: _decoration(
                                  'Masukkan nomor HP aktif',
                                  icon: const Icon(
                                    Icons.phone_android_rounded,
                                    size: 20,
                                    color: Color(0xFF168DE2),
                                  ),
                                ),
                                validator: (value) {
                                  final phone = value?.trim() ?? '';

                                  if (phone.isEmpty) {
                                    return 'Nomor HP wajib diisi';
                                  }

                                  if (phone.length < 10) {
                                    return 'Nomor HP belum sesuai';
                                  }

                                  return null;
                                },
                              ),
                            ),

                            // EMAIL
                            _field(
                              'Email',
                              TextFormField(
                                controller: _email,
                                enabled: !_submitting,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(150),
                                ],
                                decoration: _decoration(
                                  'Masukkan email aktif',
                                  icon: _asset(
                                    'assets/images/email.png',
                                    Icons.mail_outline_rounded,
                                  ),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';

                                  if (email.isEmpty) return 'Email wajib diisi';

                                  if (!RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(email)) {
                                    return 'Format email tidak valid';
                                  }

                                  return null;
                                },
                              ),
                            ),

                            if (_loadingOptions) ...[
                              const LinearProgressIndicator(minHeight: 2),
                              const SizedBox(height: 10),
                            ],

                            if (_optionsError != null ||
                                (!_loadingOptions && !_optionsReady)) ...[
                              Text(
                                _optionsError ??
                                    'Pilihan Status Mahasiswa atau '
                                        'Keperluan belum tersedia.',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _submitting || _loadingOptions
                                      ? null
                                      : _loadOptions,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Coba Lagi',
                                    style: TextStyle(fontSize: 9),
                                  ),
                                ),
                              ),
                            ],

                            // STATUS MAHASISWA
                            _field(
                              'Status Mahasiswa',
                              _dropdown(
                                label: 'Status Mahasiswa',
                                value: _studentStatusId,
                                options:
                                    options?.studentStatuses ??
                                    const <AkademikQueueOption>[],
                                icon: const Icon(
                                  Icons.school_rounded,
                                  size: 20,
                                  color: Color(0xFF3EA94C),
                                ),
                                onChanged: (value) {
                                  setState(() => _studentStatusId = value);
                                },
                              ),
                            ),

                            // KEPERLUAN
                            _field(
                              'Keperluan',
                              _dropdown(
                                label: 'Keperluan',
                                value: _purposeId,
                                options:
                                    options?.purposes ??
                                    const <AkademikQueueOption>[],
                                icon: _asset(
                                  'assets/images/layanan.png',
                                  Icons.list_alt_rounded,
                                  service: true,
                                ),
                                onChanged: (value) {
                                  setState(() => _purposeId = value);
                                },
                              ),
                            ),

                            // KETERANGAN
                            _field(
                              'Keterangan',
                              SizedBox(
                                height: 115,
                                child: TextFormField(
                                  controller: _description,
                                  enabled: !_submitting,
                                  expands: true,
                                  minLines: null,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textAlignVertical: TextAlignVertical.top,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(2000),
                                  ],
                                  decoration: _decoration(
                                    'Tuliskan keterangan pengajuan Anda',
                                  ),
                                  validator: (value) {
                                    if (value?.trim().isEmpty ?? true) {
                                      return 'Keterangan wajib diisi';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                            ),

                            // Field di atas sudah memiliki jarak bawah 13.
                            // Tambahan 12 membuat jarak ke tombol menjadi 25.
                            const SizedBox(height: 12),

                            _buttons(),

                            const SizedBox(height: 5),
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
      ),
    );
  }
}
