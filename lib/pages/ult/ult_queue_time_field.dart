import 'dart:async';

import 'package:flutter/material.dart';

class UltQueueSchedule {
  static const int minutesPerQueue = 5;

  // Jam kampus WIB, direpresentasikan sebagai komponen tanggal/jam lokal.
  static DateTime now() {
    final DateTime wib = DateTime.now().toUtc().add(const Duration(hours: 7));

    return DateTime(
      wib.year,
      wib.month,
      wib.day,
      wib.hour,
      wib.minute,
      wib.second,
      wib.millisecond,
      wib.microsecond,
    );
  }

  static DateTime at(DateTime date, int minute) {
    return DateTime(date.year, date.month, date.day, minute ~/ 60, minute % 60);
  }

  static List<int> minutesForDate(DateTime date, {DateTime? currentTime}) {
    final DateTime current = currentTime ?? now();
    final DateTime day = DateUtils.dateOnly(date);
    final DateTime today = DateUtils.dateOnly(current);

    if (day.isBefore(today)) {
      return <int>[];
    }

    final List<int> result = <int>[];

    // Pagi 08.00–12.00 dan sore 13.00–16.00.
    for (final List<int> session in const <List<int>>[
      <int>[8 * 60, 12 * 60],
      <int>[13 * 60, 16 * 60],
    ]) {
      for (
        int minute = session[0];
        minute + minutesPerQueue <= session[1];
        minute += minutesPerQueue
      ) {
        // Pada tanggal hari ini, jam yang sudah lewat tidak ditawarkan.
        if (DateUtils.isSameDay(day, today) &&
            at(day, minute).isBefore(current)) {
          continue;
        }

        result.add(minute);
      }
    }

    return result;
  }

  static bool isSelectable(DateTime date, int minute) {
    return minutesForDate(date).contains(minute);
  }

  static String formatMinute(int minute, {String separator = '.'}) {
    final String hour = (minute ~/ 60).toString().padLeft(2, '0');

    final String part = (minute % 60).toString().padLeft(2, '0');

    return '$hour$separator$part';
  }

  static String estimate(int minute) {
    return '${formatMinute(minute)}'
        '–${formatMinute(minute + minutesPerQueue)} WIB';
  }
}

class UltQueueTimeField extends StatefulWidget {
  const UltQueueTimeField({
    super.key,
    required this.date,
    required this.selectedMinute,
    required this.onChanged,
    this.enabled = true,
  });

  final DateTime date;
  final int? selectedMinute;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  State<UltQueueTimeField> createState() => _UltQueueTimeFieldState();
}

class _UltQueueTimeFieldState extends State<UltQueueTimeField> {
  Timer? _clockTimer;

  bool _isPickerOpen = false;

  @override
  void initState() {
    super.initState();

    // Memperbarui tampilan jika pilihan jam sudah lewat.
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && widget.enabled) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickTime() async {
    if (!widget.enabled || _isPickerOpen) {
      return;
    }

    final DateTime date = DateUtils.dateOnly(widget.date);

    final List<int> minutes = UltQueueSchedule.minutesForDate(date);

    if (minutes.isEmpty) {
      _message(
        'Tidak ada pilihan jam untuk tanggal ini. '
        'Pilih tanggal berikutnya.',
      );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isPickerOpen = true;
    });

    try {
      final int? selected = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext sheetContext) {
          return SafeArea(
            top: false,
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * 0.65,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Pilih Jam Antrian',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tutup',
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      'Estimasi 5 menit per antrian. '
                      'Istirahat 12.00–13.00 WIB.',
                      style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                    ),
                  ),

                  const Divider(height: 1),

                  Expanded(
                    child: ListView.separated(
                      itemCount: minutes.length,
                      separatorBuilder: (_, index) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final int minute = minutes[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.schedule_rounded,
                            color: Color(0xFF168DE2),
                          ),
                          title: Text(
                            '${UltQueueSchedule.formatMinute(minute)} WIB',
                          ),
                          subtitle: Text(
                            'Estimasi ${UltQueueSchedule.estimate(minute)}',
                          ),
                          trailing: widget.selectedMinute == minute
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF168DE2),
                                )
                              : null,
                          onTap: () {
                            Navigator.of(sheetContext).pop(minute);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!mounted || selected == null || !widget.enabled) {
        return;
      }

      // Tanggal dapat berubah ketika data layanan dimuat ulang.
      if (!DateUtils.isSameDay(date, widget.date)) {
        _message('Tanggal berubah. Silakan pilih ulang jam antrian.');

        return;
      }

      // Periksa kembali karena jam mungkin sudah lewat
      // ketika daftar pilihan masih terbuka.
      if (!UltQueueSchedule.isSelectable(date, selected)) {
        _message(
          'Jam tersebut sudah lewat. '
          'Silakan pilih jam berikutnya.',
        );

        return;
      }

      widget.onChanged(selected);
    } finally {
      if (mounted) {
        setState(() {
          _isPickerOpen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int? minute = widget.selectedMinute;

    final bool hasOptions = UltQueueSchedule.minutesForDate(
      widget.date,
    ).isNotEmpty;

    final bool valid =
        minute != null && UltQueueSchedule.isSelectable(widget.date, minute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: const Color(0xFFF5F6FA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: const BorderSide(color: Color(0xFF8D8D8D), width: 0.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.enabled && hasOptions && !_isPickerOpen
                ? _pickTime
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: Color(0xFF168DE2),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      minute != null
                          ? '${UltQueueSchedule.formatMinute(minute)} WIB'
                          : hasOptions
                          ? 'Pilih jam antrian'
                          : 'Tidak ada pilihan jam',
                      style: TextStyle(
                        color: minute != null
                            ? const Color(0xFF202020)
                            : const Color(0xFF888888),
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
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Jam layanan 08.00–16.00 WIB. '
          'Istirahat 12.00–13.00 WIB.',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 9.5,
            height: 1.35,
          ),
        ),

        if (minute != null) ...[
          const SizedBox(height: 6),
          Text(
            valid
                ? 'Estimasi pelayanan: '
                      '${UltQueueSchedule.estimate(minute)} (5 menit).'
                : 'Jam yang dipilih sudah tidak berlaku. '
                      'Silakan pilih ulang.',
            style: TextStyle(
              color: valid ? const Color(0xFF135F91) : const Color(0xFFD32F2F),
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ] else if (!hasOptions) ...[
          const SizedBox(height: 6),
          const Text(
            'Tidak ada pilihan jam untuk tanggal ini. '
            'Pilih tanggal berikutnya.',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
