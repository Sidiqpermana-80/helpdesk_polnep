import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class FasilitasDeviceSyncService {
  FasilitasDeviceSyncService._();

  static final instance = FasilitasDeviceSyncService._();

  final _prefs = SharedPreferencesAsync();

  static const _storageKey = 'fasilitas_device_bindings_v1';

  Future<void> _writes = Future<void>.value();

  Timer? _retry;
  String? _token;

  bool _running = false;
  bool _again = false;

  int _attempt = 0;

  Future<Map<String, String>> _read() async {
    final raw = await _prefs.getString(_storageKey);

    if (raw == null) {
      return {};
    }

    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  Future<void> _edit(void Function(Map<String, String>) edit) {
    final task = _writes.then((_) async {
      final bindings = await _read();

      edit(bindings);

      await _prefs.setString(_storageKey, jsonEncode(bindings));
    });

    _writes = task.catchError((Object _) {});

    return task;
  }

  Future<int> _nextVersion() {
    final task = _writes.then((_) async {
      final version = (await _prefs.getInt('fasilitas_sync_version') ?? 0) + 1;

      await _prefs.setInt('fasilitas_sync_version', version);

      return version;
    });

    _writes = task.then<void>((_) {}).catchError((Object _) {});

    return task;
  }

  Future<void> rememberTicket({required int id, required String key}) async {
    if (id <= 0 || !RegExp(r'^[a-f0-9]{64}$').hasMatch(key)) {
      return;
    }

    await _edit((bindings) {
      bindings[id.toString()] = key;
    });

    if (_token != null) {
      unawaited(syncToken(_token!));
    }
  }

  Future<void> syncToken(String value) async {
    if (value.trim().isEmpty) {
      return;
    }

    _token = value.trim();
    _attempt = 0;
    _retry?.cancel();

    await _drain();
  }

  Future<void> _drain() async {
    if (_running) {
      _again = true;
      return;
    }

    _running = true;

    var failed = false;

    try {
      do {
        _again = false;
        failed = false;

        final token = _token;

        if (token == null) {
          return;
        }

        await _writes;

        final bindings = await _read();

        final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

        for (final entry in bindings.entries) {
          try {
            final response = await http
                .post(
                  Uri.parse('$base/fasilitas-ruangan/device-token'),
                  headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'request_id': int.parse(entry.key),
                    'device_sync_key': entry.value,
                    'fcm_token': token,
                    'device_platform': 'android',
                    'sync_version': await _nextVersion(),
                  }),
                )
                .timeout(const Duration(seconds: 8));

            bool remove = false;

            if (response.statusCode == 404) {
              final error = jsonDecode(response.body);

              remove = error is Map && error['code'] == 'INVALID_BINDING';
            }

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body) as Map<String, dynamic>;

              if (data['success'] != true) {
                failed = true;
              } else {
                remove = (data['data'] as Map?)?['active'] == false;
              }
            } else if (!remove) {
              failed = true;
            }

            if (remove) {
              await _edit((current) {
                if (current[entry.key] == entry.value) {
                  current.remove(entry.key);
                }
              });
            }
          } catch (_) {
            failed = true;
          }
        }
      } while (_again);
    } catch (_) {
      failed = true;
    } finally {
      _running = false;
    }

    if (failed && ++_attempt < 3) {
      _retry = Timer(const Duration(seconds: 30), () {
        unawaited(_drain());
      });
    }

    if (kDebugMode) {
      debugPrint(
        failed
            ? 'FASILITAS TOKEN SYNC: tertunda'
            : 'FASILITAS TOKEN SYNC: selesai',
      );
    }
  }
}
