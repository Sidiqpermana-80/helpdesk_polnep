import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/ult_availability_service.dart';

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
    required this.category,
    required this.selectedMinute,
    required this.onChanged,
    this.enabled = true,
  });

  final DateTime date;
  final String category;
  final int? selectedMinute;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  State<UltQueueTimeField> createState() {
    return _UltQueueTimeFieldState();
  }
}

class _UltQueueTimeFieldState extends State<UltQueueTimeField> {
  Timer? _clockTimer;
  bool _isPickerOpen = false;

  @override
  void initState() {
    super.initState();

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
    final String category = widget.category.trim().toLowerCase();

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
        builder: (_) {
          return _UltSlotPicker(
            date: date,
            category: category,
            selectedMinute: widget.selectedMinute,
          );
        },
      );

      if (!mounted || selected == null || !widget.enabled) {
        return;
      }

      if (!DateUtils.isSameDay(date, widget.date) ||
          category != widget.category.trim().toLowerCase()) {
        _message(
          'Tanggal atau kategori berubah. '
          'Silakan pilih ulang jam antrian.',
        );
        return;
      }

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
            onTap: widget.enabled && !_isPickerOpen ? _pickTime : null,
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
                          : 'Pilih jam antrian',
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
          'Istirahat 12.00–13.00 WIB. '
          'Jam abu-abu tidak dapat dipilih.',
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
                : 'Jam yang dipilih sudah lewat. '
                      'Silakan pilih ulang.',
            style: TextStyle(
              color: valid ? const Color(0xFF135F91) : const Color(0xFFD32F2F),
              fontSize: 9.5,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

// Daftar jam yang mengambil ketersediaan dari Laravel.
class _UltSlotPicker extends StatefulWidget {
  const _UltSlotPicker({
    required this.date,
    required this.category,
    required this.selectedMinute,
  });

  final DateTime date;
  final String category;
  final int? selectedMinute;

  @override
  State<_UltSlotPicker> createState() => _UltSlotPickerState();
}

class _UltSlotPickerState extends State<_UltSlotPicker>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;

  bool _loading = false;
  bool _failed = false;

  UltDaySlots? _data;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    unawaited(_loadSlots());

    // Selama daftar terbuka, perbarui ketersediaan setiap 15 detik.
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(_loadSlots());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadSlots());
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSlots() async {
    if (!mounted || _loading) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final UltDaySlots data = await UltAvailabilityService.slots(
        widget.date,
        widget.category,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _data = data;
        _failed = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildSlots() {
    final UltDaySlots? data = _data;

    if (data == null) {
      return Center(
        child: Text(
          _failed
              ? 'Tidak dapat mengambil jadwal. '
                    'Periksa koneksi ke server.'
              : 'Memuat jam antrian…',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!data.open) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            data.reason ?? 'Layanan tutup pada tanggal ini.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Untuk hari ini, sembunyikan jam yang sudah lewat.
    // Untuk tanggal mendatang, seluruh jam layanan tetap ditampilkan.
    // Slot yang dipesan tetap muncul selama jamnya belum lewat.
    final List<UltSlotOption> slots = data.slots.where((slot) {
      return UltQueueSchedule.isSelectable(widget.date, slot.minute);
    }).toList();

    if (slots.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Tidak ada jam antrian yang tersisa pada tanggal ini. '
            'Silakan pilih tanggal layanan berikutnya.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: slots.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final UltSlotOption slot = slots[index];

        final bool booked = slot.state == 'booked';

        final bool available =
            slot.available &&
            !_failed &&
            UltQueueSchedule.isSelectable(widget.date, slot.minute);

        final Color color = available
            ? const Color(0xFF168DE2)
            : const Color(0xFF9E9E9E);

        final String description;

        if (booked) {
          description = 'Dipesan';
        } else if (_failed) {
          description = 'Ketersediaan belum dapat diperbarui';
        } else if (available) {
          description = 'Estimasi ${UltQueueSchedule.estimate(slot.minute)}';
        } else {
          description = 'Tidak tersedia';
        }

        return Material(
          color: available ? Colors.white : const Color(0xFFEEEEEE),
          child: ListTile(
            enabled: available,
            leading: Icon(
              available ? Icons.schedule_rounded : Icons.lock_outline_rounded,
              color: color,
            ),
            title: Text(
              '${UltQueueSchedule.formatMinute(slot.minute)} WIB',
              style: TextStyle(
                color: available ? const Color(0xFF202020) : color,
              ),
            ),
            subtitle: Text(
              description,
              style: TextStyle(color: color, fontSize: 12),
            ),
            trailing: available && widget.selectedMinute == slot.minute
                ? Icon(Icons.check_rounded, color: color)
                : null,
            onTap: available
                ? () {
                    Navigator.of(context).pop(slot.minute);
                  }
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
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
                  tooltip: 'Perbarui jam',
                  onPressed: _loading ? null : _loadSlots,
                  icon: const Icon(Icons.refresh_rounded),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () {
                    Navigator.of(context).pop();
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
              'Istirahat 12.00–13.00 WIB. '
              'Jam bertanda Dipesan sudah digunakan '
              'pada tanggal dan kategori yang sama.',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_failed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ketersediaan jam belum dapat diperbarui.',
                      style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _loadSlots,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Expanded(child: _buildSlots()),
        ],
      ),
    );
  }
}
