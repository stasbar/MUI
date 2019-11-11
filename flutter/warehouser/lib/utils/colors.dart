
import 'package:flutter/material.dart';

const primaryColor = const Color(0xFF3393fa);
const primaryLight = const Color(0xFF7ebafc);
const primaryDark = const Color(0xFF067bf9);

const secondaryColor = const Color(0xFF06e7f9);
const secondaryLight = const Color(0xFF06e7f9);
const secondaryDark = const Color(0xFF06e7f9);

const Color gradientStart = const Color(0xFF06e7f9);
const Color gradientEnd = const Color(0xFF3393fa);

const primaryGradient = const LinearGradient(
  colors: const [gradientStart, gradientEnd],
  stops: const [0.0, 1.0],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);