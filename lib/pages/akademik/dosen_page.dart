import 'package:flutter/material.dart';

import 'request_form_widget.dart';

class DosenPage extends StatelessWidget {
  const DosenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestFormWidget(
      categoryName: 'Dosen',
      identifierLabel: 'NIP',
    );
  }
}
