import 'package:flutter/material.dart';
import 'package:my_resturant/core/helpers/responsive.dart';

class PromoErrorText extends StatelessWidget {
  const PromoErrorText({super.key, required this.message, required this.cs});

  final String message;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(color: cs.error, fontSize: R.fontSm(context)),
    );
  }
}
