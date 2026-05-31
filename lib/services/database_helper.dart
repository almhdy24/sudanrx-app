import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'sudanrx.db');

    // Check if database exists
    bool dbExists = await _dbFileExists(path);
    Database db = await openDatabase(path, version: 1, onCreate: _onCreate);

    if (!dbExists) {
      await _seedInitialData(db);
    }
    return db;
  }

  Future<bool> _dbFileExists(String path) async {
    try {
      await openDatabase(path);
      return true;
    } catch (_) {
      return false;
    }
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
        updated_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY,
        guideline_id INTEGER,
        FOREIGN KEY (guideline_id) REFERENCES guidelines (id)
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    final jsonString = await rootBundle.loadString('assets/data/guidelines.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> categories = data['categories'];
    final List<dynamic> guidelines = data['guidelines'];

    // Insert categories
    for (var cat in categories) {
      await db.insert('categories', {'id': cat['id'], 'name': cat['name']});
    }

    // Insert guidelines
    for (var g in guidelines) {
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
    }
  }

  // Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'name');
  }

  // Guidelines (all or by category)
  Future<List<Map<String, dynamic>>> getGuidelines({int? categoryId}) async {
    final db = await database;
    if (categoryId != null) {
      return await db.query('guidelines', where: 'category_id = ?', whereArgs: [categoryId], orderBy: 'title');
    }
    return await db.query('guidelines', orderBy: 'title');
  }

  // Single guideline by slug
  Future<Map<String, dynamic>?> getGuidelineBySlug(String slug) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('guidelines', where: 'slug = ?', whereArgs: [slug]);
    if (results.isEmpty) return null;
    // Fetch category name separately for display
    final guideline = results.first;
    final categoryId = guideline['category_id'];
    if (categoryId != null) {
      final List<Map<String, dynamic>> cat = await db.query('categories', where: 'id = ?', whereArgs: [categoryId]);
      if (cat.isNotEmpty) {
        guideline['category_name'] = cat.first['name'];
      }
    }
    return guideline;
  }

  // Search across title and overview
  Future<List<Map<String, dynamic>>> searchGuidelines(String query) async {
    final db = await database;
    return await db.query(
      'guidelines',
      where: 'title LIKE ? OR overview LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title',
    );
  }

  // Bookmarks
  Future<List<int>> getBookmarkedIds() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('bookmarks');
    return result.map((row) => row['guideline_id'] as int).toList();
  }

  Future<void> addBookmark(int guidelineId) async {
    final db = await database;
    await db.insert('bookmarks', {'guideline_id': guidelineId}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeBookmark(int guidelineId) async {
    final db = await database;
    await db.delete('bookmarks', where: 'guideline_id = ?', whereArgs: [guidelineId]);
  }

  Future<bool> isBookmarked(int guidelineId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('bookmarks', where: 'guideline_id = ?', whereArgs: [guidelineId]);
    return result.isNotEmpty;
  }

  // Get full guideline objects for bookmarks
  Future<List<Map<String, dynamic>>> getBookmarkedGuidelines() async {
    final bookmarkedIds = await getBookmarkedIds();
    if (bookmarkedIds.isEmpty) return [];
    final db = await database;
    final List<Map<String, dynamic>> results = [];
    for (int id in bookmarkedIds) {
      final guideline = await db.query('guidelines', where: 'id = ?', whereArgs: [id]);
      if (guideline.isNotEmpty) {
        final g = guideline.first;
        final catId = g['category_id'];
        if (catId != null) {
          final cat = await db.query('categories', where: 'id = ?', whereArgs: [catId]);
          if (cat.isNotEmpty) g['category_name'] = cat.first['name'];
        }
        results.add(g);
      }
    }
    return results;
  }
}
