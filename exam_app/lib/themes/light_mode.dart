import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface:  Color.fromARGB(255, 240, 248, 255), // Màu xanh dương rất nhạt cho nền bề mặt, gần như trắng.
    primary:  Color.fromARGB(255, 173, 216, 230), // Màu xanh dương nhạt cho các thành phần chính.
    secondary:  Color.fromARGB(255, 200, 230, 255), // Màu xanh dương nhạt hơn cho các thành phần phụ.
    tertiary: Colors.white, // Màu trắng cho các khu vực cần sự nổi bật.
    inversePrimary:  Color.fromARGB(255, 30, 60, 90), // Màu xanh dương đậm để tạo sự tương phản.
    onPrimary: Colors.black,
  ),
);
