import 'package:flutter/material.dart';

import 'request_form_widget.dart';

class MahasiswaPage extends StatelessWidget {
  const MahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestFormWidget(
      categoryName: 'Mahasiswa',
      identifierLabel: 'NIM',
    );
  }
}
