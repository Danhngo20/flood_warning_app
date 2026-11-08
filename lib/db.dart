import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

// ===== TOÀN BỘ DB nằm ở file này =====
// Đổi tên bảng / cột: sửa các hằng số + CREATE TABLE bên dưới (và toMap/fromMap trong models.dart).
// Đổi data mẫu: sửa assets/seed.json (key = tên bảng, mỗi phần tử = 1 row, key = tên cột).
// Muốn seed lại: đổi dbName (vd 'gallery_v2.db') hoặc xóa file db / gỡ app khỏi máy.
const dbName = 'flood.db';
const tFlood = 'floods';

Database? _db;

Future<Database> get db async {
  if (_db != null) return _db!;
  // Windows: ghi vào local_data/ trong project để DB client mở được; Android: thư mục mặc định
  String path;
  if (Platform.isWindows) {
    final dir = Directory(join(Directory.current.path, 'local_data'))
      ..createSync(recursive: true);
    path = join(dir.path, 'flood.db');
  } else {
    path = join(await getDatabasesPath(), dbName);
  }
  return _db = await openDatabase(
    path,
    version: 1,
    onCreate: (d, _) async {
      await d.execute('''CREATE TABLE $tFlood(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          area_name TEXT NOT NULL,
          location TEXT NOT NULL,
          expected_depth_em INTEGER NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          alert_level TEXT NOT NULL)''');
    },
  );
}

Future<List<Flood>> getFloods() async => (await (await db).query(
  tFlood,
  orderBy: 'id DESC',
)).map(Flood.fromMap).toList();

Future<void> addFlood(Flood a) async =>
    (await db).insert(tFlood, a.toMap()..remove('id'));

Future<void> updateFlood(Flood a) async => (await db).update(
  tFlood,
  a.toMap()..remove('id'),
  where: 'id = ?',
  whereArgs: [a.id],
);

Future<void> deleteFlood(int id) async =>
    (await db).delete(tFlood, where: 'id = ?', whereArgs: [id]);
