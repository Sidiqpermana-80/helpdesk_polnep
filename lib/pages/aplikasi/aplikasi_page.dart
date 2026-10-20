import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/application_catalog_service.dart';
import 'aplikasi_form_page.dart';
import 'pilih_aplikasi_page.dart';

class AplikasiPage extends StatefulWidget {
  const AplikasiPage({super.key});

  @override
  State<AplikasiPage> createState() => _AplikasiPageState();
}

class _AplikasiPageState extends State<AplikasiPage>
    with WidgetsBindingObserver {
  String? _selectedIssue;

  ApplicationOption? _selectedApplication;

  List<ApplicationOption> _applications = [];

  bool _loading = true;
  bool _fetching = false;

  String? _error;

  static const _issues = <Map<String, String>>[
    {'title': 'Tidak Bisa Login', 'asset': 'assets/images/lock.png'},
    {'title': 'Data Tidak Sesuai', 'asset': 'assets/images/doc.png'},
    {'title': 'Error Sistem', 'asset': 'assets/images/error.png'},
  ];

  List<ApplicationOption> get _featured {
    return _applications.where((item) => item.isFeatured).take(3).toList();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    unawaited(_loadApplications());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadApplications());
    }
  }

  // =========================================================
  // AMBIL DAFTAR APLIKASI
  // =========================================================

  Future<void> _loadApplications() async {
    if (!mounted || _fetching) {
      return;
    }

    _fetching = true;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await ApplicationCatalogService.fetch();

      if (!mounted) {
        return;
      }

      setState(() {
        final selectedId = _selectedApplication?.id;

        _applications = items;
        _selectedApplication = null;

        // Pertahankan pilihan jika masih menjadi aplikasi utama.
        for (final item in _featured) {
          if (item.id == selectedId) {
            _selectedApplication = item;
            break;
          }
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _applications = [];
          _selectedApplication = null;

          _error =
              'Daftar aplikasi belum bisa dimuat. '
              'Silakan coba lagi.';
        });
      }
    } finally {
      _fetching = false;

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =========================================================
  // HALAMAN
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

          child: RefreshIndicator(
            onRefresh: _loadApplications,

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),

              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // HEADER
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
                        'Layanan Aplikasi',

                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // PENJELASAN
                  SizedBox(
                    width: double.infinity,
                    height: 116,

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 6, top: 3),

                            child: Text(
                              'Pilih Aplikasi dan\n'
                              'jenis kendala yang\n'
                              'ingin anda\n'
                              'keluhkan',

                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 20,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 135,
                          height: 110,

                          child: Image.asset(
                            'assets/images/settings.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Padding(
                    padding: EdgeInsets.only(left: 6),

                    child: Text(
                      'Jenis Kendala',

                      style: TextStyle(
                        color: Color(0xFF202020),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  _buildIssueSelection(),

                  const SizedBox(height: 13),

                  _buildApplicationSection(),

                  const SizedBox(height: 34),

                  // TOMBOL LANJUT
                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton(
                      onPressed:
                          _loading || _error != null || _applications.isEmpty
                          ? null
                          : _submitSelection,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B48FF),
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Image.asset(
                            'assets/images/papperplane.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(width: 5),

                          const Text(
                            'Ajukan Permintaan',

                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // PILIHAN JENIS KENDALA
  // =========================================================

  Widget _buildIssueSelection() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(11, 14, 11, 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: const Color(0xFFD6E9F7)),
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;

          final columns = constraints.maxWidth < 270 ? 1 : 3;

          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,

            children: _issues.map((issue) {
              final title = issue['title']!;
              final selected = _selectedIssue == title;

              return SizedBox(
                width: width,

                child: Semantics(
                  button: true,
                  selected: selected,

                  child: Material(
                    color: selected ? const Color(0xFFEAF0FF) : Colors.white,

                    borderRadius: BorderRadius.circular(9),
                    clipBehavior: Clip.antiAlias,

                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIssue = title;
                        });
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),

                        constraints: const BoxConstraints(minHeight: 110),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 12,
                        ),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),

                          border: Border.all(
                            color: selected
                                ? const Color(0xFF5368FF)
                                : const Color(0xFFD6E9F7),

                            width: selected ? 1.2 : 0.8,
                          ),
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Container(
                              width: 36,
                              height: 36,

                              padding: const EdgeInsets.all(4),

                              decoration: BoxDecoration(
                                color: _issueBackground(title),

                                borderRadius: BorderRadius.circular(9),
                              ),

                              child: Image.asset(
                                issue['asset']!,
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 9),

                            Text(
                              title,
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: const Color(0xFF202020),
                                fontSize: 10.5,
                                height: 1.25,

                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Color _issueBackground(String title) {
    switch (title) {
      case 'Tidak Bisa Login':
        return const Color(0xFF5A5CEB);

      case 'Data Tidak Sesuai':
        return const Color(0xFFC99700);

      case 'Error Sistem':
        return const Color(0xFFFFC967);

      default:
        return const Color(0xFFEAEAEA);
    }
  }

  // =========================================================
  // DAFTAR APLIKASI UTAMA
  // =========================================================

  Widget _buildApplicationSection() {
    final featured = _featured;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(9, 10, 9, 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: const Color(0xFFD6E9F7)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Pilih Aplikasi',

            style: TextStyle(
              color: Color(0xFF202020),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(18),

              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,

                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_error != null) ...[
            Text(
              _error!,

              style: const TextStyle(fontSize: 11, color: Colors.red),
            ),

            TextButton(
              onPressed: _loadApplications,
              child: const Text('Coba Lagi'),
            ),
          ] else if (_applications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),

              child: Text(
                'Belum ada aplikasi yang tersedia.',
                style: TextStyle(fontSize: 11),
              ),
            )
          else ...[
            if (featured.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),

                child: Text(
                  'Pilih aplikasi melalui daftar lengkap di bawah.',
                  style: TextStyle(fontSize: 11),
                ),
              ),

            ...featured.map(
              (application) => Padding(
                padding: const EdgeInsets.only(bottom: 5),

                child: _buildApplicationItem(application),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,

              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: _openAllApplications,

                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),

                  child: Text(
                    'Aplikasi Lainnya',

                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationItem(ApplicationOption application) {
    final selected = _selectedApplication?.id == application.id;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () {
          setState(() {
            _selectedApplication = application;
          });
        },

        borderRadius: BorderRadius.circular(9),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),

          width: double.infinity,

          constraints: const BoxConstraints(minHeight: 56),

          padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),

          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0F4FF) : const Color(0xFFFAFAFA),

            borderRadius: BorderRadius.circular(9),

            border: Border.all(
              color: selected
                  ? const Color(0xFF5368FF)
                  : const Color(0xFFA8A8A8),

              width: selected ? 1.4 : 0.8,
            ),
          ),

          child: Row(
            children: [
              Expanded(
                child: Text(
                  application.name,

                  style: TextStyle(
                    color: const Color(0xFF202020),
                    fontSize: 11,

                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,

                color: selected
                    ? const Color(0xFF5368FF)
                    : const Color(0xFF8793FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // NAVIGASI
  // =========================================================

  Future<void> _openAllApplications() async {
    if (_selectedIssue == null) {
      _showMessage('Silakan pilih jenis kendala terlebih dahulu.');

      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PilihAplikasiPage(selectedIssue: _selectedIssue),
      ),
    );

    await _loadApplications();
  }

  Future<void> _submitSelection() async {
    if (_selectedIssue == null) {
      _showMessage('Silakan pilih jenis kendala terlebih dahulu.');

      return;
    }

    final application = _selectedApplication;

    if (application == null) {
      _showMessage('Silakan pilih aplikasi terlebih dahulu.');

      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AplikasiFormPage(
          issueType: _selectedIssue!,
          applicationId: application.id,
          applicationName: application.name,
        ),
      ),
    );

    await _loadApplications();
  }

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
