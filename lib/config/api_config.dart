class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://192.168.201.20:8000/api';

  // =========================================================
  // MASTER DATA
  // =========================================================

  static String get units => '$baseUrl/units';

  static String get requestCategories => '$baseUrl/request-categories';

  static String get announcements => '$baseUrl/announcements';

  // =========================================================
  // PERMINTAAN DATA
  // =========================================================

  static String get createPermintaanData => '$baseUrl/requests';

  // =========================================================
  // KEPEGAWAIAN
  // =========================================================

  static String get createKepegawaian => '$baseUrl/kepegawaian';

  // =========================================================
  // REMUNERASI
  // =========================================================

  static String get createRemunerasi => '$baseUrl/remunerasi';

  static String get createAplikasi => '$baseUrl/aplikasi';

  static String get createWebsite => '$baseUrl/website';

  // =========================================================
  // CEK STATUS
  // =========================================================

  static String get statusPermintaanData => '$baseUrl/status/requests';

  static String get statusKepegawaian => '$baseUrl/status/kepegawaian';
}
