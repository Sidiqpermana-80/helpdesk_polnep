import 'package:flutter/material.dart';

import 'home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hero.webp',
            fit: BoxFit.cover,
            alignment: const Alignment(-0.30, 0),
          ),

          const ColoredBox(color: Color(0x14000000)),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenSize.height * 0.14),

                Image.asset(
                  'assets/images/logopolnep-BESAR.png',
                  width: screenSize.width * 0.44,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                // Tombol lanjutkan.
                ContinueButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const HomePage();
                        },
                      ),
                    );
                  },
                ),

                SizedBox(height: screenSize.height * 0.105),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContinueButton extends StatelessWidget {
  const ContinueButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.sizeOf(context).width * 0.60;

    return Container(
      width: buttonWidth,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF6A70F2), Color(0xFF25275F)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: const Center(
            child: Text(
              'Lanjutkan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
