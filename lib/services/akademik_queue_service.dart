import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'ult_availability_service.dart';

typedef AkademikCalendar = UltServiceCalendarData;

String akademikDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class AkademikQueueException implements Exception {
  const AkademikQueueException(this.message, {this.checkStatus = false});

  final String message;
  final bool checkStatus;
}

class AkademikQueueOption {
  const AkademikQueueOption({required this.id, required this.name});

  final String id;
  final String name;

  factory AkademikQueueOption.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    final name = json['name']?.toString().trim() ?? '';

    if (id.isEmpty || name.isEmpty) {
      throw const FormatException('Pilihan layanan tidak lengkap.');
    }

    return AkademikQueueOption(id: id, name: name);
  }
}

class AkademikQueueOptions {
  const AkademikQueueOptions({
    required this.studentStatuses,
    required this.purposes,
  });

  final List<AkademikQueueOption> studentStatuses;
  final List<AkademikQueueOption> purposes;

  factory AkademikQueueOptions.fromJson(Map<String, dynamic> json) {
    List<AkademikQueueOption> readOptions(String key) {
      final raw = json[key];

      if (raw is! List) {
        throw const FormatException('Daftar pilihan belum sesuai.');
      }

      final result = <String, AkademikQueueOption>{};

      for (final item in raw) {
        if (item is! Map) {
          throw const FormatException('Pilihan layanan belum sesuai.');
        }

        final option = AkademikQueueOption.fromJson(
          Map<String, dynamic>.from(item),
        );

        result[option.id] = option;
      }

      return result.values.toList();
    }

    return AkademikQueueOptions(
      studentStatuses: readOptions('student_statuses'),
      purposes: readOptions('purposes'),
    );
  }
}

class AkademikSlotOption {
  AkademikSlotOption(Map<String, dynamic> json)
    : minute = json['minute'] as int,
      state = json['state'] as String;

  final int minute;
  final String state;

  bool get available => state == 'available';
}

class AkademikDaySlots {
  AkademikDaySlots(Map<String, dynamic> json)
    : open = json['open'] == true,
      reason = json['reason']?.toString(),
      slots = (json['slots'] as List)
          .map(
            (item) =>
                AkademikSlotOption(Map<String, dynamic>.from(item as Map)),
          )
          .toList();

  final bool open;
  final String? reason;
  final List<AkademikSlotOption> slots;
}

class AkademikQueueTicket {
  const AkademikQueueTicket({
    required this.id,
    required this.requestNumber,
    required this.queueNumber,
    required this.queueDate,
    required this.queueTime,
    required this.status,
    this.deviceSyncKey,
    this.estimatedLabel,
    this.emailSent = false,
  });

  final int id;
  final String requestNumber;
  final int queueNumber;
  final DateTime queueDate;
  final String queueTime;
  final String status;

  final String? deviceSyncKey;
  final String? estimatedLabel;

  // Hasil pengiriman email dari Laravel.
  final bool emailSent;

  String get numberLabel {
    return queueNumber.toString().padLeft(3, '0');
  }

  String get dateLabel {
    return '${queueDate.day.toString().padLeft(2, '0')}-'
        '${queueDate.month.toString().padLeft(2, '0')}-'
        '${queueDate.year}';
  }

  String get timeLabel {
    return '${queueTime.replaceAll(':', '.')} WIB';
  }

  String get statusLabel {
    return const <String, String>{
          'menunggu_antrian': 'Menunggu Antrian',
          'dipanggil': 'Dipanggil',
          'sedang_dilayani': 'Sedang Dilayani',
          'selesai': 'Selesai',
          'dibatalkan': 'Dibatalkan',
        }[status] ??
        status;
  }

  factory AkademikQueueTicket.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse(json['id']?.toString() ?? '');

    final code = json['request_number']?.toString().trim() ?? '';

    final number = int.tryParse(json['queue_number']?.toString() ?? '');

    final dateText = json['queue_date']?.toString() ?? '';
    final date = DateTime.tryParse(dateText);

    final time = json['queue_time']?.toString() ?? '';
    final status = json['status']?.toString().trim() ?? '';

    final validTime = RegExp(r'^(?:0[89]|1[01345]):[0-5][05]$').hasMatch(time);

    if (id == null ||
        id <= 0 ||
        number == null ||
        number < 1 ||
        code.isEmpty ||
        date == null ||
        dateText != akademikDateKey(date) ||
        !validTime ||
        status.isEmpty) {
      throw const FormatException('Data tiket antrian belum lengkap.');
    }

    return AkademikQueueTicket(
      id: id,
      requestNumber: code,
      queueNumber: number,
      queueDate: date,
      queueTime: time,
      status: status,
      deviceSyncKey: json['device_sync_key']?.toString(),
      estimatedLabel: json['estimated_start_label']?.toString(),
      emailSent: json['email_sent'] == true,
    );
  }
}

class AkademikQueueService {
  static Uri _uri(String path) {
    final base = ApiConfig.baseUrl.replaceFirst(RegExp(r'/+$'), '');

    return Uri.parse('$base/akademik/queue$path');
  }

  static Map<String, dynamic> _data(
    http.Response response, {
    bool submission = false,
  }) {
    if (response.statusCode == 404) {
      throw const AkademikQueueException(
        'API antrian Akademik belum tersedia.',
      );
    }

    if (submission && response.statusCode >= 500) {
      throw const AkademikQueueException(
        'Server mengalami kendala. Periksa Cek Status dengan email '
        'sebelum mengirim ulang.',
        checkStatus: true,
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw AkademikQueueException(
        submission
            ? 'Jawaban server belum dapat dibaca. '
                  'Periksa Cek Status sebelum mengirim ulang.'
            : 'Data dari server belum dapat dibaca.',
        checkStatus: submission,
      );
    }

    if (decoded is! Map) {
      throw AkademikQueueException(
        'Jawaban server belum sesuai.',
        checkStatus: submission,
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['success'] != true) {
      var message =
          decoded['message']?.toString() ?? 'Permintaan belum berhasil.';

      final errors = decoded['errors'];

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            message = value.first.toString();
            break;
          }
        }
      }

      throw AkademikQueueException(message);
    }

    if (decoded['data'] is! Map) {
      throw AkademikQueueException(
        'Data dari server belum lengkap.',
        checkStatus: submission,
      );
    }

    return Map<String, dynamic>.from(decoded['data'] as Map);
  }

  static Future<AkademikQueueOptions> loadOptions() async {
    final response = await http
        .get(_uri('/options'), headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    return AkademikQueueOptions.fromJson(_data(response));
  }

  static Future<AkademikCalendar> loadCalendar() {
    // Kalender libur kampus digunakan bersama.
    // Slot antrian tetap diambil dari endpoint Akademik.
    return UltAvailabilityService.calendar();
  }

  static Future<AkademikDaySlots> slots(DateTime date) async {
    final response = await http
        .get(
          _uri(
            '/slots',
          ).replace(queryParameters: {'date': akademikDateKey(date)}),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    return AkademikDaySlots(_data(response));
  }

  static Future<AkademikQueueTicket> createTicket({
    required String fullName,
    required String nim,
    required String phone,
    required String email,
    required String studentStatusId,
    required String purposeId,
    required String description,
    required DateTime queueDate,
    required String queueTime,
    String? fcmToken,
  }) async {
    final response = await http
        .post(
          _uri(''),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'full_name': fullName,
            'nim': nim,
            'phone': phone,
            'email': email,
            'student_status_id': studentStatusId,
            'purpose_id': purposeId,
            'description': description,
            'queue_date': akademikDateKey(queueDate),
            'queue_time': queueTime,
            if (fcmToken != null && fcmToken.trim().isNotEmpty) ...{
              'fcm_token': fcmToken.trim(),
              'device_platform': 'android',
            },
          }),
        )
        .timeout(const Duration(seconds: 30));

    final data = _data(response, submission: true);

    try {
      final ticket = AkademikQueueTicket.fromJson(data);

      if (akademikDateKey(ticket.queueDate) != akademikDateKey(queueDate) ||
          ticket.queueTime != queueTime) {
        throw const FormatException('Jadwal tiket berbeda.');
      }

      return ticket;
    } on FormatException {
      throw const AkademikQueueException(
        'Server merespons, tetapi data tiket belum lengkap. '
        'Periksa Cek Status sebelum mengirim ulang.',
        checkStatus: true,
      );
    }
  }
}
