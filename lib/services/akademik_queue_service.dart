import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

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
    List<AkademikQueueOption> read(String key) {
      final raw = json[key];

      if (raw is! List) {
        throw const FormatException('Daftar pilihan tidak sesuai.');
      }

      final options = <String, AkademikQueueOption>{};

      for (final item in raw) {
        if (item is! Map) {
          throw const FormatException('Pilihan layanan tidak sesuai.');
        }

        final option = AkademikQueueOption.fromJson(
          Map<String, dynamic>.from(item),
        );

        options[option.id] = option;
      }

      return options.values.toList();
    }

    return AkademikQueueOptions(
      studentStatuses: read('student_statuses'),
      purposes: read('purposes'),
    );
  }
}

class AkademikQueueTicket {
  const AkademikQueueTicket({
    required this.requestNumber,
    required this.queueNumber,
    required this.queueDate,
    required this.status,
    this.estimatedLabel,
  });

  final String requestNumber;
  final int queueNumber;
  final DateTime queueDate;
  final String status;
  final String? estimatedLabel;

  String get numberLabel {
    return queueNumber.toString().padLeft(3, '0');
  }

  String get dateLabel {
    return '${queueDate.day.toString().padLeft(2, '0')}-'
        '${queueDate.month.toString().padLeft(2, '0')}-'
        '${queueDate.year}';
  }

  String get statusLabel {
    return const {
          'menunggu_antrian': 'Menunggu Antrean',
          'dipanggil': 'Dipanggil',
          'sedang_dilayani': 'Sedang Dilayani',
          'selesai': 'Selesai',
          'dibatalkan': 'Dibatalkan',
        }[status] ??
        status;
  }

  factory AkademikQueueTicket.fromJson(Map<String, dynamic> json) {
    final code = json['request_number']?.toString().trim() ?? '';

    final number = int.tryParse(json['queue_number']?.toString() ?? '');

    final dateText = json['queue_date']?.toString() ?? '';
    final date = DateTime.tryParse(dateText);

    final status = json['status']?.toString().trim() ?? '';

    final normalizedDate = date == null
        ? ''
        : '${date.year.toString().padLeft(4, '0')}-'
              '${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}';

    if (code.isEmpty ||
        number == null ||
        number < 1 ||
        date == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateText) ||
        dateText != normalizedDate ||
        status.isEmpty) {
      throw const FormatException('Data tiket antrean belum lengkap.');
    }

    return AkademikQueueTicket(
      requestNumber: code,
      queueNumber: number,
      queueDate: date,
      status: status,
      estimatedLabel: json['estimated_start_label']?.toString(),
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
        'API antrean Akademik belum tersedia. '
        'Integrasi Laravel belum dipasang.',
      );
    }

    if (submission && response.statusCode >= 500) {
      throw const AkademikQueueException(
        'Server mengalami kendala. '
        'Periksa Cek Status dengan email sebelum mengirim ulang.',
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
            : 'Data pilihan dari server belum sesuai.',
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

  static Future<AkademikQueueTicket> createTicket({
    required String fullName,
    required String nim,
    required String phone,
    required String email,
    required String studentStatusId,
    required String purposeId,
    required String description,
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
          }),
        )
        .timeout(const Duration(seconds: 30));

    final data = _data(response, submission: true);

    try {
      return AkademikQueueTicket.fromJson(data);
    } on FormatException {
      throw const AkademikQueueException(
        'Server merespons, tetapi data tiket belum lengkap. '
        'Periksa Cek Status sebelum mengirim ulang.',
        checkStatus: true,
      );
    }
  }
}
