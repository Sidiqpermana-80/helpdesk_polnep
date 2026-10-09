class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://192.168.101.132:8000/api';

  static String get units => '$baseUrl/units';

  static String get requestCategories => '$baseUrl/request-categories';

  static String get announcements => '$baseUrl/announcements';

  static String get createPermintaanData => '$baseUrl/requests';

  static String get createAplikasi => '$baseUrl/aplikasi';

  static String get createWebsite => '$baseUrl/website';

  static String get websiteList =>
      '$baseUrl/master-options/website/website_list';

  static String get websiteIssueTypes =>
      '$baseUrl/master-options/website/issue_type';

  static String get createWifiInternet => '$baseUrl/wifi-internet';

  static String get wifiBuildingOptions =>
      '$baseUrl/master-options/wifi_internet/building_name';

  static String get createFasilitasRuangan => '$baseUrl/fasilitas-ruangan';

  static String get fasilitasBuildingOptions =>
      '$baseUrl/master-options/fasilitas_ruangan/building_name';

  static String get fasilitasTypeOptions =>
      '$baseUrl/master-options/fasilitas_ruangan/facility_type';

  static String get createAntrianTiket => '$baseUrl/antrian-tiket';

  static String get antrianSemesterOptions =>
      '$baseUrl/master-options/antrian_tiket/semester';

  static String get antrianStudentServiceOptions =>
      '$baseUrl/master-options/antrian_tiket/student_service';

  static String get antrianGeneralServiceOptions =>
      '$baseUrl/master-options/antrian_tiket/general_service';

  static String get cekStatus => '$baseUrl/cek-status';

  static String get requestStatus => '$baseUrl/status/requests';

  static String get statusPermintaanData => '$baseUrl/status/requests';
}
