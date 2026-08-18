import 'package:flutter/material.dart';

/// Official LARC logo, loaded from the local bundled asset
/// (assets/images/larc_logo.png). Never fetched from the network.
class LarcLogo extends StatelessWidget {
  const LarcLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/larc_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
