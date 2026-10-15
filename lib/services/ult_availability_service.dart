import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

String ultDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class UltServiceCalendarData {
  UltServiceCalendarData(Map<String, dynamic> data)
    : firstDate = DateTime.parse(data['min_date'] as String),
      lastDate = DateTime.parse(data['max_date'] as String),
      weekends = Set<int>.from(data['weekend_days'] as List),
      holidays = Map<String, dynamic>.from(data['holidays'] as Map);

  final DateTime firstDate;
  final DateTime lastDate;
  final Set<int> weekends;
  final Map<String, dynamic> holidays;

  bool isOpen(DateTime value) {
    final date = DateUtils.dateOnly(value);

    return !date.isBefore(firstDate) &&
        !date.isAfter(lastDate) &&
        !weekends.contains(date.weekday) &&
        !holidays.containsKey(ultDateKey(date));
  }

  DateTime? nextOpen(DateTime value) {
    var date = DateUtils.dateOnly(value);

    if (date.isBefore(firstDate)) {
      date = firstDate;
    }

    while (!date.isAfter(lastDate)) {
      if (isOpen(date)) {
        return date;
      }

      date = DateTime(date.year, date.month, date.day + 1);
    }

    return null;
  }
}

class UltSlotOption {
  UltSlotOption(Map<String, dynamic> data)
    : minute = data['minute'] as int,
      state = data['state'] as String;

  final int minute;
  final String state;

  bool get available => state == 'available';
}

class UltDaySlots {
  UltDaySlots(Map<String, dynamic> data)
    : open = data['open'] == true,
      reason = data['reason']?.toString(),
      slots = (data['slots'] as List)
          .map((item) => UltSlotOption(Map<String, dynamic>.from(item as Map)))
          .toList();

  final bool open;
  final String? reason;
  final List<UltSlotOption> slots;
}

class UltAvailabilityService {
  static Future<Map<String, dynamic>> _get(Uri uri) async {
    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        decoded is! Map ||
        decoded['success'] != true ||
        decoded['data'] is! Map) {
      throw const FormatException('Data jadwal layanan belum tersedia.');
    }

    return Map<String, dynamic>.from(decoded['data'] as Map);
  }

  static Future<UltServiceCalendarData> calendar() async {
    final data = await _get(Uri.parse('${ApiConfig.baseUrl}/ult/calendar'));

    return UltServiceCalendarData(data);
  }

  static Future<UltDaySlots> slots(DateTime date, String category) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/ult/slots').replace(
      queryParameters: {
        'date': ultDateKey(date),
        'category': category.trim().toLowerCase(),
      },
    );

    return UltDaySlots(await _get(uri));
  }
}
