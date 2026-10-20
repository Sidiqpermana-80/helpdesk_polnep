import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/application_catalog_service.dart';
import 'aplikasi_form_page.dart';

class PilihAplikasiPage extends StatefulWidget {
  const PilihAplikasiPage({this.selectedIssue, super.key});

  final String? selectedIssue;

  @override
  State<PilihAplikasiPage> createState() => _PilihAplikasiPageState();
}

class _PilihAplikasiPageState extends State<PilihAplikasiPage>
    with WidgetsBindingObserver {
  ApplicationOption? _selectedApplication;

  List<ApplicationOption> _applications = [];

  bool _loading = true;
  bool _fetching = false;

  String? _error;

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

        for (final item in items) {
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

          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),

                child: Row(
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
                      'Pilih Aplikasi',

                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // DAFTAR APLIKASI
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadApplications,
                  child: _buildList(),
                ),
              ),

              // TOMBOL LANJUT
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),

                child: SizedBox(
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
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(width: 10),

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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ISI DAFTAR / LOADING / ERROR
  // =========================================================

  Widget _buildList() {
    if (_loading || _error != null || _applications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(24),

        children: [
          if (_loading)
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,

                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            Text(
              _error ?? 'Belum ada aplikasi yang tersedia.',
              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 8),

            Center(
              child: TextButton(
                onPressed: _loadApplications,
                child: const Text('Muat Ulang'),
              ),
            ),
          ],
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),

      itemCount: _applications.length,

      separatorBuilder: (_, index) {
        return const SizedBox(height: 5);
      },

      itemBuilder: (_, index) {
        return _buildApplicationItem(_applications[index]);
      },
    );
  }

  // =========================================================
  // KARTU APLIKASI
  // =========================================================

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
            color: selected ? const Color(0xFFF0F4FF) : Colors.white,

            borderRadius: BorderRadius.circular(9),

            border: Border.all(
              color: selected
                  ? const Color(0xFF5368FF)
                  : const Color(0xFF929292),

              width: selected ? 1.5 : 0.8,
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
                    ? const Color(0xFF4B48FF)
                    : const Color(0xFF8793FF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MASUK FORM
  // =========================================================

  Future<void> _submitSelection() async {
    final issue = widget.selectedIssue;

    if (issue == null || issue.isEmpty) {
      _showMessage('Silakan kembali dan pilih jenis kendala terlebih dahulu.');

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
          issueType: issue,
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
