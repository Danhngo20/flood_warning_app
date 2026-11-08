import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db.dart';
import 'screens/home_screen.dart';

const teal = Color(0xFF2A7F7F);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit(); // chỉ cần khi chạy desktop
    databaseFactory = databaseFactoryFfi;
  }
  await db; // mở DB ngay khi khởi động để tạo bảng + seed
  runApp(
    MaterialApp(
      title: 'Flood Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // không login: vào thẳng Home
    ),
  );
}
