import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color transparent = Colors.transparent;
  static const Color primary = Color.fromRGBO(242, 82, 99, 1);
  static const Color white = Color.fromRGBO(240, 240, 240, 1);
  static const Color black = Colors.black87;
  static const Color lightGrey = Colors.black12;
  static const Color grey = Colors.grey;

  static MaterialColor primarySwatch = const MaterialColor(0xFFf25263, {
    50: Color.fromRGBO(242, 82, 99, .1),
    100: Color.fromRGBO(242, 82, 99, .2),
    200: Color.fromRGBO(242, 82, 99, .3),
    300: Color.fromRGBO(242, 82, 99, .4),
    400: Color.fromRGBO(242, 82, 99, .5),
    500: Color.fromRGBO(242, 82, 99, .6),
    600: Color.fromRGBO(242, 82, 99, .7),
    700: Color.fromRGBO(242, 82, 99, .8),
    800: Color.fromRGBO(242, 82, 99, .9),
    900: Color.fromRGBO(242, 82, 99, 1),
  });
}
