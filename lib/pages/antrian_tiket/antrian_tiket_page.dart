import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import 'antrian_tiket_success_page.dart';

class AntrianTiketPage extends StatefulWidget {
  const AntrianTiketPage({super.key});

  @override
  State<AntrianTiketPage> createState() => _AntrianTiketPageState();
}

class _AntrianTiketPageState extends State<AntrianTiketPage> {
  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // =========================================================
  // FIELD BERSAMA
  // =========================================================

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  // =========================================================
  // FIELD MAHASISWA
  // =========================================================

  final TextEditingController _identifierController = TextEditingController();

  final TextEditingController _departmentController = TextEditingController();

  String? _selectedSemester;

  String? _selectedService;

  // =========================================================
  // FIELD UMUM
  // =========================================================

  final TextEditingController _originController = TextEditingController();

  final TextEditingController _destinationController = TextEditingController();

  String? _selectedGeneralService;

  // =========================================================
  // KATEGORI
  // =========================================================

  String? _selectedCategory;

  // =========================================================
  // JENIS ANTRIAN
  //
  // langsung = hari ini
  // booking  = pilih tanggal
  // =========================================================

  String? _selectedQueueType;

  DateTime? _selectedBookingDate;

  // =========================================================
  // LAINNYA
  // =========================================================

  bool _isSubmitting = false;

  int _formVersion = 0;

  // =========================================================
  // SEMESTER
  // =========================================================

  static const List<String> _semesterOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
  ];

  // =========================================================
  // LAYANAN MAHASISWA
  // =========================================================

  static const List<String> _studentServices = [
    'Legalisir Ijazah',
    'Surat Magang',
    'Surat Aktif Kuliah',
    'Surat Permohonan Cuti Kuliah',
    'Surat Permohonan Drop Out',
  ];

  // =========================================================
  // LAYANAN UMUM
  // =========================================================

  static const List<String> _generalServices = [
    'Surat Dari Luar ke Direktur',
    'Surat Cuti Pegawai',
    'Surat ke Wadir 1',
  ];

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();

    _identifierController.dispose();
    _departmentController.dispose();

    _originController.dispose();
    _destinationController.dispose();

    super.dispose();
  }

  // =========================================================
  // FIELD DECORATION
  // =========================================================

  InputDecoration _fieldDecoration({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF888888), fontSize: 10.5),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 42),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF8D8D8D), width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF3AA7F5), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F9FF), Color(0xFFD7EEFF), Color(0xFFB9E1FF)],
            ),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // HEADER
                // =================================================
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Kembali',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 21,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Antrian Tiket',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =================================================
                // HERO
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 7, top: 2),
                          child: Text(
                            'Isi form dibawah\n'
                            'untuk\n'
                            'mendapatkan\n'
                            'nomor antrian tiket',
                            style: TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 20.5,
                              height: 1.08,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 155,
                        height: 115,
                        child: Image.asset(
                          'assets/images/antrian.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 7),

                // =================================================
                // CARD FORM
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD6E9F7),
                      width: 0.7,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =========================================
                        // PILIH KATEGORI
                        // =========================================
                        const Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            color: Color(0xFF202020),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Row(
                          children: [
                            Expanded(
                              child: _categoryButton(
                                title: 'Mahasiswa',
                                value: 'Mahasiswa',
                                asset: 'assets/images/mhs.png',
                                iconColor: const Color(0xFF6757D9),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _categoryButton(
                                title: 'Umum',
                                value: 'Umum',
                                asset: 'assets/images/tendik.png',
                                iconColor: const Color(0xFFFFB74D),
                              ),
                            ),
                          ],
                        ),

                        // =========================================
                        // FORM BARU MUNCUL SETELAH PILIH KATEGORI
                        // =========================================
                        if (_selectedCategory != null) ...[
                          const SizedBox(height: 18),

                          const Divider(color: Color(0xFF555555), thickness: 1),

                          const SizedBox(height: 12),

                          // =======================================
                          // JENIS ANTRIAN
                          // =======================================
                          const Text(
                            'Jenis Antrian',
                            style: TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Row(
                            children: [
                              Expanded(
                                child: _queueTypeButton(
                                  title: 'Langsung',
                                  subtitle: 'Hari Ini',
                                  value: 'langsung',
                                  icon: Icons.flash_on_rounded,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _queueTypeButton(
                                  title: 'Booking',
                                  subtitle: 'Pilih Hari',
                                  value: 'booking',
                                  icon: Icons.calendar_month_rounded,
                                ),
                              ),
                            ],
                          ),

                          // =======================================
                          // LANGSUNG
                          // =======================================
                          if (_selectedQueueType == 'langsung') ...[
                            const SizedBox(height: 10),
                            _todayInformation(),
                          ],

                          // =======================================
                          // BOOKING
                          // =======================================
                          if (_selectedQueueType == 'booking') ...[
                            const SizedBox(height: 13),
                            _fieldTitle('Tanggal Antrian'),
                            _bookingDateField(),
                          ],

                          const SizedBox(height: 18),

                          const Divider(color: Color(0xFF555555), thickness: 1),

                          const SizedBox(height: 10),

                          Text(
                            _selectedCategory == 'Mahasiswa'
                                ? 'Silakan isi data mahasiswa berikut.'
                                : 'Silakan isi data pengunjung berikut.',
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 9.5,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // =======================================
                          // NAMA
                          // =======================================
                          _fieldTitle('Nama'),

                          TextFormField(
                            controller: _nameController,
                            enabled: !_isSubmitting,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              hintText: 'Masukkan nama lengkap',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/images/pp.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            validator: (String? value) {
                              final String name = value?.trim() ?? '';

                              if (name.isEmpty) {
                                return 'Nama wajib diisi';
                              }

                              if (name.length < 3) {
                                return 'Nama belum sesuai';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          // =======================================
                          // MAHASISWA -> NIM
                          // =======================================
                          if (_selectedCategory == 'Mahasiswa') ...[
                            _fieldTitle('NIM'),

                            TextFormField(
                              controller: _identifierController,
                              enabled: !_isSubmitting,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(30),
                              ],
                              decoration: _fieldDecoration(
                                hintText: 'Masukkan NIM',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/images/book.png',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              validator: (String? value) {
                                if (_selectedCategory != 'Mahasiswa') {
                                  return null;
                                }

                                final String nim = value?.trim() ?? '';

                                if (nim.isEmpty) {
                                  return 'NIM wajib diisi';
                                }

                                if (nim.length < 5) {
                                  return 'NIM belum sesuai';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),
                          ],

                          // =======================================
                          // UMUM -> DARI
                          // =======================================
                          if (_selectedCategory == 'Umum') ...[
                            _fieldTitle('Dari'),

                            TextFormField(
                              controller: _originController,
                              enabled: !_isSubmitting,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                hintText: 'Masukkan asal / instansi',
                                prefixIcon: const Icon(
                                  Icons.business_rounded,
                                  size: 20,
                                  color: Color(0xFF6757D9),
                                ),
                              ),
                              validator: (String? value) {
                                if (_selectedCategory != 'Umum') {
                                  return null;
                                }

                                final String origin = value?.trim() ?? '';

                                if (origin.isEmpty) {
                                  return 'Dari wajib diisi';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),
                          ],

                          // =======================================
                          // NO HP
                          // =======================================
                          _fieldTitle('No. HP'),

                          TextFormField(
                            controller: _phoneController,
                            enabled: !_isSubmitting,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                            decoration: _fieldDecoration(
                              hintText: 'Masukkan nomor HP aktif',
                              prefixIcon: const Icon(
                                Icons.phone_android_rounded,
                                size: 20,
                                color: Color(0xFF168DE2),
                              ),
                            ),
                            validator: (String? value) {
                              final String phone = value?.trim() ?? '';

                              if (phone.isEmpty) {
                                return 'Nomor HP wajib diisi';
                              }

                              if (phone.length < 10) {
                                return 'Nomor HP belum sesuai';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          // =======================================
                          // EMAIL
                          // =======================================
                          _fieldTitle('Email'),

                          TextFormField(
                            controller: _emailController,
                            enabled: !_isSubmitting,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: _fieldDecoration(
                              hintText: 'Masukkan email aktif',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/images/email.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            validator: (String? value) {
                              final String email = value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Email wajib diisi';
                              }

                              final RegExp emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );

                              if (!emailRegex.hasMatch(email)) {
                                return 'Format email tidak valid';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 13),

                          // =======================================
                          // MAHASISWA
                          // =======================================
                          if (_selectedCategory == 'Mahasiswa') ...[
                            // =====================================
                            // JURUSAN
                            // =====================================
                            _fieldTitle('Jurusan'),

                            TextFormField(
                              controller: _departmentController,
                              enabled: !_isSubmitting,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                hintText: 'Masukkan nama jurusan',
                                prefixIcon: const Icon(
                                  Icons.account_balance_rounded,
                                  size: 20,
                                  color: Color(0xFF6757D9),
                                ),
                              ),
                              validator: (String? value) {
                                if (_selectedCategory != 'Mahasiswa') {
                                  return null;
                                }

                                final String department = value?.trim() ?? '';

                                if (department.isEmpty) {
                                  return 'Jurusan wajib diisi';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),

                            // =====================================
                            // SEMESTER
                            // =====================================
                            _fieldTitle('Semester'),

                            DropdownButtonFormField<String>(
                              key: ValueKey('semester-$_formVersion'),
                              initialValue: _selectedSemester,
                              isExpanded: true,
                              menuMaxHeight: 300,
                              dropdownColor: const Color(0xFFF0F7FF),
                              decoration: _fieldDecoration(
                                hintText: 'Pilih Semester',
                                prefixIcon: const Icon(
                                  Icons.school_rounded,
                                  size: 20,
                                  color: Color(0xFF3EA94C),
                                ),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF222222),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 14,
                              ),
                              items: _semesterOptions.map((String semester) {
                                return DropdownMenuItem<String>(
                                  value: semester,
                                  child: Text(
                                    'Semester $semester',
                                    style: const TextStyle(
                                      color: Color(0xFF202020),
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (String? value) {
                                      setState(() {
                                        _selectedSemester = value;
                                      });
                                    },
                              validator: (String? value) {
                                if (_selectedCategory != 'Mahasiswa') {
                                  return null;
                                }

                                if (value == null || value.isEmpty) {
                                  return 'Semester wajib dipilih';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),

                            // =====================================
                            // LAYANAN MAHASISWA
                            // =====================================
                            _fieldTitle('Layanan'),

                            DropdownButtonFormField<String>(
                              key: ValueKey('service-$_formVersion'),
                              initialValue: _selectedService,
                              isExpanded: true,
                              menuMaxHeight: 300,
                              dropdownColor: const Color(0xFFF0F7FF),
                              decoration: _fieldDecoration(
                                hintText: 'Pilih Layanan',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Image.asset(
                                    'assets/images/layanan.png',
                                    width: 21,
                                    height: 21,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF222222),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 14,
                              ),
                              items: _studentServices.map((String service) {
                                return DropdownMenuItem<String>(
                                  value: service,
                                  child: Text(
                                    service,
                                    style: const TextStyle(
                                      color: Color(0xFF202020),
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (String? value) {
                                      setState(() {
                                        _selectedService = value;
                                      });
                                    },
                              validator: (String? value) {
                                if (_selectedCategory != 'Mahasiswa') {
                                  return null;
                                }

                                if (value == null || value.isEmpty) {
                                  return 'Layanan wajib dipilih';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),
                          ],

                          // =======================================
                          // UMUM
                          // =======================================
                          if (_selectedCategory == 'Umum') ...[
                            // =====================================
                            // JENIS LAYANAN
                            // =====================================
                            _fieldTitle('Jenis Layanan'),

                            DropdownButtonFormField<String>(
                              key: ValueKey('general-service-$_formVersion'),
                              initialValue: _selectedGeneralService,
                              isExpanded: true,
                              menuMaxHeight: 300,
                              dropdownColor: const Color(0xFFF0F7FF),
                              decoration: _fieldDecoration(
                                hintText: 'Pilih Jenis Layanan',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Image.asset(
                                    'assets/images/layanan.png',
                                    width: 21,
                                    height: 21,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF222222),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 14,
                              ),
                              items: _generalServices.map((String service) {
                                return DropdownMenuItem<String>(
                                  value: service,
                                  child: Text(
                                    service,
                                    style: const TextStyle(
                                      color: Color(0xFF202020),
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isSubmitting
                                  ? null
                                  : (String? value) {
                                      setState(() {
                                        _selectedGeneralService = value;
                                      });
                                    },
                              validator: (String? value) {
                                if (_selectedCategory != 'Umum') {
                                  return null;
                                }

                                if (value == null || value.isEmpty) {
                                  return 'Jenis layanan wajib dipilih';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),

                            // =====================================
                            // UNTUK
                            // =====================================
                            _fieldTitle('Untuk'),

                            TextFormField(
                              controller: _destinationController,
                              enabled: !_isSubmitting,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDecoration(
                                hintText: 'Masukkan tujuan pengajuan',
                                prefixIcon: const Icon(
                                  Icons.send_rounded,
                                  size: 20,
                                  color: Color(0xFF3EA94C),
                                ),
                              ),
                              validator: (String? value) {
                                if (_selectedCategory != 'Umum') {
                                  return null;
                                }

                                final String destination = value?.trim() ?? '';

                                if (destination.isEmpty) {
                                  return 'Untuk wajib diisi';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 13),
                          ],

                          // =======================================
                          // KETERANGAN
                          //
                          // PENTING:
                          // DILUAR BLOK MAHASISWA DAN UMUM
                          // AGAR MUNCUL PADA KEDUANYA
                          // =======================================
                          _fieldTitle('Keterangan'),

                          SizedBox(
                            height: 115,
                            child: TextFormField(
                              controller: _descriptionController,
                              enabled: !_isSubmitting,
                              expands: true,
                              minLines: null,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: _fieldDecoration(
                                hintText: 'Tuliskan keterangan pengajuan Anda',
                              ),
                              validator: (String? value) {
                                final String description = value?.trim() ?? '';

                                if (description.isEmpty) {
                                  return 'Keterangan wajib diisi';
                                }

                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 25),

                          // =======================================
                          // BUTTON
                          // =======================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5868FF),
                                    disabledBackgroundColor: const Color(
                                      0xFFADB5F5,
                                    ),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Kirim Data',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 22),
                              SizedBox(
                                width: 72,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _resetForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF59C467),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // CATEGORY BUTTON
  // =========================================================

  Widget _categoryButton({
    required String title,
    required String value,
    required String asset,
    required Color iconColor,
  }) {
    final bool selected = _selectedCategory == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: _isSubmitting
            ? null
            : () {
                if (_selectedCategory == value) {
                  return;
                }

                setState(() {
                  // =========================================
                  // KATEGORI BARU
                  // =========================================

                  _selectedCategory = value;

                  // =========================================
                  // RESET JENIS ANTRIAN
                  // =========================================

                  _selectedQueueType = null;

                  _selectedBookingDate = null;

                  // =========================================
                  // RESET MAHASISWA
                  // =========================================

                  _identifierController.clear();

                  _departmentController.clear();

                  _selectedSemester = null;

                  _selectedService = null;

                  // =========================================
                  // RESET UMUM
                  // =========================================

                  _originController.clear();

                  _destinationController.clear();

                  _selectedGeneralService = null;

                  // =========================================
                  // RESET KETERANGAN
                  // =========================================

                  _descriptionController.clear();

                  _formVersion++;
                });

                _formKey.currentState?.reset();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF5FF) : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: selected
                  ? const Color(0xFF3AA7F5)
                  : const Color(0xFF8D8D8D),
              width: selected ? 1.3 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 25,
                height: 25,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF202020),
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // JENIS ANTRIAN BUTTON
  // =========================================================

  Widget _queueTypeButton({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final bool selected = _selectedQueueType == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: _isSubmitting
            ? null
            : () {
                setState(() {
                  _selectedQueueType = value;

                  if (value == 'langsung') {
                    _selectedBookingDate = null;
                  }
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF5FF) : const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? const Color(0xFF3AA7F5)
                  : const Color(0xFFB8B8B8),
              width: selected ? 1.3 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF3AA7F5)
                      : const Color(0xFFE1E6EC),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: selected ? Colors.white : const Color(0xFF555555),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF202020),
                        fontSize: 10.5,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // INFORMASI HARI INI
  // =========================================================

  Widget _todayInformation() {
    final DateTime today = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF9CCDF2), width: 0.7),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 17,
            color: Color(0xFF168DE2),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tanggal antrian: Hari ini, ${_formatDisplayDate(today)}',
              style: const TextStyle(color: Color(0xFF303030), fontSize: 9.5),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FIELD TANGGAL BOOKING
  // =========================================================

  Widget _bookingDateField() {
    final bool hasDate = _selectedBookingDate != null;

    return InkWell(
      onTap: _isSubmitting ? null : _selectBookingDate,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFF8D8D8D), width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: Color(0xFF168DE2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasDate
                    ? _formatDisplayDate(_selectedBookingDate!)
                    : 'Pilih tanggal booking',
                style: TextStyle(
                  color: hasDate
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
    );
  }

  // =========================================================
  // PILIH TANGGAL BOOKING
  // =========================================================

  Future<void> _selectBookingDate() async {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime firstBookingDate = today.add(const Duration(days: 1));

    final DateTime lastBookingDate = DateTime(now.year + 1, 12, 31);

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedBookingDate ?? firstBookingDate,
      firstDate: firstBookingDate,
      lastDate: lastBookingDate,
      helpText: 'Pilih Tanggal Antrian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selected == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedBookingDate = DateTime(
        selected.year,
        selected.month,
        selected.day,
      );
    });
  }

  // =========================================================
  // FIELD TITLE
  // =========================================================

  Widget _fieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF202020),
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // =========================================================
  // FORMAT TANGGAL TAMPILAN
  // =========================================================

  String _formatDisplayDate(DateTime date) {
    const List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // =========================================================
  // FORMAT TANGGAL API
  // =========================================================

  String _formatApiDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');

    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  // =========================================================
  // TANGGAL ANTRIAN AKTIF
  // =========================================================

  DateTime? get _activeQueueDate {
    if (_selectedQueueType == 'langsung') {
      final DateTime now = DateTime.now();

      return DateTime(now.year, now.month, now.day);
    }

    if (_selectedQueueType == 'booking') {
      return _selectedBookingDate;
    }

    return null;
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    // =========================================================
    // KATEGORI
    // =========================================================

    if (_selectedCategory == null) {
      _showMessage('Silakan pilih kategori terlebih dahulu.');

      return;
    }

    // =========================================================
    // JENIS ANTRIAN
    // =========================================================

    if (_selectedQueueType == null) {
      _showMessage('Silakan pilih jenis antrian.');

      return;
    }

    // =========================================================
    // BOOKING
    // =========================================================

    if (_selectedQueueType == 'booking' && _selectedBookingDate == null) {
      _showMessage('Silakan pilih tanggal booking.');

      return;
    }

    // =========================================================
    // VALIDASI FORM
    // =========================================================

    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      _showMessage('Silakan lengkapi data yang masih kosong.');

      return;
    }

    if (_isSubmitting) {
      return;
    }

    final DateTime? queueDate = _activeQueueDate;

    if (queueDate == null) {
      _showMessage('Tanggal antrian tidak valid.');

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // =======================================================
      // ENDPOINT
      // =======================================================

      final Uri uri = Uri.parse(ApiConfig.createAntrianTiket);

      final http.MultipartRequest request = http.MultipartRequest('POST', uri);

      // =======================================================
      // DATA BERSAMA
      // =======================================================

      request.fields.addAll({
        'full_name': _nameController.text.trim(),

        'phone': _phoneController.text.trim(),

        'email': _emailController.text.trim(),

        'category': _selectedCategory!.trim().toLowerCase(),

        'queue_type': _selectedQueueType!,

        'queue_date': _formatApiDate(queueDate),

        'description': _descriptionController.text.trim(),
      });

      // =======================================================
      // MAHASISWA
      // =======================================================

      if (_selectedCategory == 'Mahasiswa') {
        request.fields.addAll({
          'identifier_value': _identifierController.text.trim(),

          'department': _departmentController.text.trim(),

          'semester': _selectedSemester!,

          'service': _selectedService!,
        });
      }

      // =======================================================
      // UMUM
      // =======================================================

      if (_selectedCategory == 'Umum') {
        request.fields.addAll({
          'origin': _originController.text.trim(),

          'service': _selectedGeneralService!,

          'destination': _destinationController.text.trim(),
        });
      }

      // =======================================================
      // KIRIM
      // =======================================================

      final http.StreamedResponse streamedResponse = await request.send();

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        'ANTRIAN STATUS: '
        '${response.statusCode}',
      );

      debugPrint(
        'ANTRIAN RESPONSE: '
        '${response.body}',
      );

      // =======================================================
      // PARSE JSON
      // =======================================================

      Map<String, dynamic> jsonResponse;

      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          jsonResponse = decoded;
        } else {
          throw const FormatException('Response bukan object JSON.');
        }
      } catch (e) {
        if (!mounted) {
          return;
        }

        _showMessage('Response server tidak valid.');

        return;
      }

      // =======================================================
      // SUCCESS
      // =======================================================

      final bool success = jsonResponse['success'] == true;

      if (response.statusCode == 201 && success) {
        final dynamic rawData = jsonResponse['data'];

        if (rawData is! Map<String, dynamic>) {
          if (!mounted) {
            return;
          }

          _showMessage('Data tiket dari server tidak valid.');

          return;
        }

        final Map<String, dynamic> data = rawData;

        if (!mounted) {
          return;
        }

        // =====================================================
        // SUCCESS PAGE
        // =====================================================

        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return AntrianTiketSuccessPage(
                queueNumber: data['queue_number']?.toString() ?? '-',

                requestNumber: data['request_number']?.toString() ?? '-',

                queueType:
                    data['queue_type']?.toString() ?? _selectedQueueType!,

                queueDateLabel:
                    data['queue_date_label']?.toString() ??
                    _formatDisplayDate(queueDate),

                fullName:
                    data['full_name']?.toString() ??
                    _nameController.text.trim(),

                phone:
                    data['phone']?.toString() ?? _phoneController.text.trim(),

                category:
                    data['category_label']?.toString() ?? _selectedCategory!,

                service:
                    data['service']?.toString() ??
                    (_selectedCategory == 'Mahasiswa'
                        ? (_selectedService ?? '-')
                        : (_selectedGeneralService ?? '-')),

                identifierValue: _selectedCategory == 'Mahasiswa'
                    ? (data['identifier_value']?.toString() ??
                          _identifierController.text.trim())
                    : null,

                department: _selectedCategory == 'Mahasiswa'
                    ? (data['department']?.toString() ??
                          _departmentController.text.trim())
                    : null,

                semester: _selectedCategory == 'Mahasiswa'
                    ? (data['semester']?.toString() ?? _selectedSemester)
                    : null,

                origin: _selectedCategory == 'Umum'
                    ? (data['origin']?.toString() ??
                          _originController.text.trim())
                    : null,

                destination: _selectedCategory == 'Umum'
                    ? (data['destination']?.toString() ??
                          _destinationController.text.trim())
                    : null,

                email:
                    data['email']?.toString() ?? _emailController.text.trim(),

                emailSent: data['email_sent'] == true,
              );
            },
          ),
        );

        return;
      }

      // =======================================================
      // ERROR BACKEND
      // =======================================================

      if (!mounted) {
        return;
      }

      final String message =
          jsonResponse['message']?.toString() ?? 'Tiket antrian gagal dibuat.';

      _showMessage(message);
    } catch (e, stackTrace) {
      debugPrint('ANTRIAN TIKET ERROR: $e');

      debugPrint('ANTRIAN STACK TRACE: $stackTrace');

      if (!mounted) {
        return;
      }

      _showMessage(
        'Tidak dapat terhubung ke server. '
        'Pastikan perangkat dan server berada pada jaringan yang sama.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // =========================================================
  // CLEAR FORM
  // =========================================================

  void _clearForm() {
    // =======================================================
    // FIELD BERSAMA
    // =======================================================

    _nameController.clear();

    _phoneController.clear();

    _emailController.clear();

    _descriptionController.clear();

    // =======================================================
    // MAHASISWA
    // =======================================================

    _identifierController.clear();

    _departmentController.clear();

    // =======================================================
    // UMUM
    // =======================================================

    _originController.clear();

    _destinationController.clear();

    setState(() {
      _selectedCategory = null;

      _selectedQueueType = null;

      _selectedBookingDate = null;

      _selectedSemester = null;

      _selectedService = null;

      _selectedGeneralService = null;

      _formVersion++;
    });

    _formKey.currentState?.reset();
  }

  // =========================================================
  // RESET
  // =========================================================

  void _resetForm() {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) {
      return;
    }

    _clearForm();

    _showMessage('Form berhasil dikosongkan.');
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
