import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance =
      DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir =
        await getApplicationDocumentsDirectory();

    final path =
        join(dir.path, 'sudanrx.db');

    final exists = await File(path).exists();

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    if (!exists) {
      await _seedInitialData(db);
    }

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE guidelines (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        slug TEXT UNIQUE NOT NULL,
        category_id INTEGER,
        overview TEXT,
        diagnosis TEXT,
        management TEXT,
        complications TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guideline_id INTEGER UNIQUE
      )
    ''');

    // 🔥 FTS5 TABLE
    await db.execute('''
      CREATE VIRTUAL TABLE guidelines_fts USING fts5(
        title,
        overview,
        diagnosis,
        management,
        content='guidelines',
        content_rowid='id'
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    final jsonString =
        await rootBundle.loadString(
      'assets/data/guidelines.json',
    );

    final data = jsonDecode(jsonString);

    for (var cat in data['categories']) {
      await db.insert('categories', {
        'id': cat['id'],
        'name': cat['name'],
      });
    }

    for (var g in data['guidelines']) {
      await db.insert('guidelines', {
        'id': g['id'],
        'title': g['title'],
        'slug': g['slug'],
        'category_id': g['category_id'],
        'overview': g['overview'],
        'diagnosis': g['diagnosis'],
        'management': g['management'],
        'complications': g['complications'],
        'updated_at': g['updated_at'],
      });

      // 🔥 Sync FTS
      await db.insert('guidelines_fts', {
        'rowid': g['id'],
        'title': g['title'],
        'overview': g['overview'],
        'diagnosis': g['diagnosis'],
        'management': g['management'],
      });
    }
  }

  // =========================
  // Categories
  // =========================
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.query(
      'categories',
      orderBy: 'name',
    );
  }

  // =========================
  // Guidelines
  // =========================
  Future<List<Map<String, dynamic>>> getGuidelines({int? categoryId}) async {
    final db = await database;

    if (categoryId != null) {
      return db.query(
        'guidelines',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'title',
      );
    }

    return db.query(
      'guidelines',
      orderBy: 'title',
    );
  }

  Future<Map<String, dynamic>?> getGuidelineBySlug(String slug) async {
    final db = await database;

    final res = await db.query(
      'guidelines',
      where: 'slug = ?',
      whereArgs: [slug],
    );

    if (res.isEmpty) return null;

    final g = res.first;

    if (g['category_id'] != null) {
      final cat = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [g['category_id']],
      );

      if (cat.isNotEmpty) {
        g['category_name'] =
            cat.first['name'];
      }
    }

    return g;
  }

  // =========================
  // 🔥 FULL TEXT SEARCH (FTS5)
  // =========================
  Future<List<Map<String, dynamic>>> searchGuidelinesFTS(String query) async {
    final db = await database;

    if (query.trim().isEmpty) return [];

    return db.rawQuery('''
      SELECT g.*, c.name as category_name
      FROM guidelines_fts f
      JOIN guidelines g ON g.id = f.rowid
      LEFT JOIN categories c ON c.id = g.category_id
      WHERE guidelines_fts MATCH ?
      ORDER BY rank
    ''', [query]);
  }

  // =========================
  // Bookmarks
  // =========================
  Future<void> addBookmark(int id) async {
    final db = await database;

    await db.insert(
      'bookmarks',
      {'guideline_id': id},
      conflictAlgorithm:
          ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeBookmark(int id) async {
    final db = await database;

    await db.delete(
      'bookmarks',
      where: 'guideline_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarkedGuidelines() async {
    final db = await database;

    return db.rawQuery('''
      SELECT g.*, c.name as category_name
      FROM guidelines g
      LEFT JOIN categories c ON c.id = g.category_id
      WHERE g.id IN (
        SELECT guideline_id FROM bookmarks
      )
      ORDER BY g.title
    ''');
  }

  Future<bool> isBookmarked(int id) async {
    final db = await database;

    final res = await db.query(
      'bookmarks',
      where: 'guideline_id = ?',
      whereArgs: [id],
    );

    return res.isNotEmpty;
  }
}