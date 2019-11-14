import 'package:flutter/material.dart';

const primaryColor = const Color(0xFF009688);
const primaryLight = const Color(0xFFB2DFDB);
const primaryDark = const Color(0xFF00796B);

const secondaryColor = const Color(0xFF009688);
const secondaryLight = const Color(0xFF009688);
const secondaryDark = const Color(0xFF009688);

const Color gradientStart = const Color(0xFF4CAF50);
const Color gradientEnd = const Color(0xFF009688);

const primaryGradient = const LinearGradient(
  colors: const [gradientStart, gradientEnd],
  stops: const [0.0, 1.0],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);