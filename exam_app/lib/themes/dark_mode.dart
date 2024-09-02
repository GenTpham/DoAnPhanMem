import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface:  Color.fromARGB(255, 20, 24, 33), // Màu xanh dương đậm, gần như đen cho nền bề mặt.
    primary:  Color.fromARGB(255, 45, 70, 90), // Màu xanh dương đậm vừa, làm màu chính cho các thành phần.
    secondary:  Color.fromARGB(255, 35, 55, 75), // Màu xanh dương đậm nhẹ hơn cho các thành phần phụ.
    tertiary:  Color.fromARGB(255, 60, 80, 100), // Màu xanh dương trung tính cho các điểm nhấn.
    inversePrimary:  Color.fromARGB(255, 238, 193, 193), // Màu xám nhạt tạo sự tương phản với nền tối.
    onPrimary: Colors.black,

  ),
);

