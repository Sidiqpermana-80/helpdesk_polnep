import 'package:flutter_test/flutter_test.dart';
import 'package:helpdesk_polnep/main.dart';

void main() {
  test('Aplikasi Helpdesk POLNEP berhasil dibuat', () {
    const app = HelpdeskPolnepApp();

    expect(app, isA<HelpdeskPolnepApp>());
  });
}