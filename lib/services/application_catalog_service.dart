import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApplicationOption {
  const ApplicationOption({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isFeatured,
  });

  final int id;
  final String name;
  final int sortOrder;
  final bool isFeatured;
}

class ApplicationCatalogService {
  static Future<List<ApplicationOption>> fetch() async {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

    final response = await http
        .get(
          Uri.parse('$base/application-options'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw const FormatException('Daftar aplikasi belum bisa dimuat.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map ||
        decoded['success'] != true ||
        decoded['data'] is! List) {
      throw const FormatException('Respons daftar aplikasi tidak valid.');
    }

    final applications = <int, ApplicationOption>{};

    for (final raw in decoded['data'] as List) {
      if (raw is! Map) {
        throw const FormatException('Data aplikasi tidak valid.');
      }

      final id = int.tryParse(raw['id']?.toString() ?? '') ?? 0;

      final name = raw['name']?.toString().trim() ?? '';

      if (id <= 0 || name.isEmpty) {
        throw const FormatException('Data aplikasi tidak lengkap.');
      }

      applications[id] = ApplicationOption(
        id: id,
        name: name,

        sortOrder: int.tryParse(raw['sort_order']?.toString() ?? '') ?? 0,

        isFeatured:
            raw['is_featured'] == true ||
            raw['is_featured'] == 1 ||
            raw['is_featured'] == '1',
      );
    }

    final result = applications.values.toList();

    result.sort((a, b) {
      final order = a.sortOrder.compareTo(b.sortOrder);

      if (order != 0) {
        return order;
      }

      final name = a.name.compareTo(b.name);

      return name != 0 ? name : a.id.compareTo(b.id);
    });

    return result;
  }
}
