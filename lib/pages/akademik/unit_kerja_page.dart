import 'package:flutter/material.dart';

import 'request_form_widget.dart';

class UnitKerjaPage extends StatelessWidget {
  const UnitKerjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestFormWidget(
      categoryName: 'Unit Kerja',
      identifierLabel: 'NIP',
      showUnitKerjaField: true,
    );
  }
}
