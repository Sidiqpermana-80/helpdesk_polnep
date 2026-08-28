class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://192.168.101.101:8000/api';

  static String get units => '$baseUrl/units';

  static String get requestCategories => '$baseUrl/request-categories';

  static String get announcements => '$baseUrl/announcements';

  static String get createPermintaanData => '$baseUrl/requests';

  static String get createKepegawaian => '$baseUrl/kepegawaian';

  static String get createRemunerasi => '$baseUrl/remunerasi';

  static String get createAplikasi => '$baseUrl/aplikasi';

  static String get createWebsite => '$baseUrl/website';

  static String get createWifiInternet => '$baseUrl/wifi-internet';

  static String get statusPermintaanData => '$baseUrl/status/requests';

  static String get statusKepegawaian => '$baseUrl/status/kepegawaian';
}
