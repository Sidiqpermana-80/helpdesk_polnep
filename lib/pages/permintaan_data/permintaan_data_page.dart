import 'package:flutter/material.dart';

import 'dosen_page.dart';
import 'mahasiswa_page.dart';
import 'unit_kerja_page.dart';

class PermintaanDataPage extends StatefulWidget {
  const PermintaanDataPage({super.key});

  @override
  State<PermintaanDataPage> createState() => _PermintaanDataPageState();
}

class _PermintaanDataPageState extends State<PermintaanDataPage> {
  int? _selectedIndex;

  static const List<Widget> _pages = [
    UnitKerjaPage(),
    DosenPage(),
    MahasiswaPage(),
  ];

  static const List<String> _menuTitles = ['Unit Kerja', 'Dosen', 'Mahasiswa'];

  void _selectMenu(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F9FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF202020),
            size: 19,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        titleSpacing: 0,

        title: const Text(
          'Permintaan Data',
          style: TextStyle(
            color: Color(0xFF202020),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Container(
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
            _buildCategoryMenu(),

            Expanded(
              child: _selectedIndex == null
                  ? const _InitialContent()
                  : IndexedStack(index: _selectedIndex!, children: _pages),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryMenu() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 3, 8, 8),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_menuTitles.length, (int index) {
          final bool isSelected = _selectedIndex == index;

          return Expanded(
            child: _CategoryMenuItem(
              title: _menuTitles[index],
              isSelected: isSelected,
              onTap: () {
                _selectMenu(index);
              },
            ),
          );
        }),
      ),
    );
  }
}

class _InitialContent extends StatelessWidget {
  const _InitialContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Pilih kategori permintaan data terlebih dahulu.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF666666), fontSize: 14),
        ),
      ),
    );
  }
}

class _CategoryMenuItem extends StatelessWidget {
  const _CategoryMenuItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFEAF7FF) : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: isSelected
                ? Border.all(color: const Color(0xFF3AA7F5), width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/file.jpeg',
                width: 42,
                height: 37,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF202020),
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
