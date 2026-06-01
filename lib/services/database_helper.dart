import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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

    final exists = await File(path).exists();

    final db = await openDatabase(
      path,
      version: 2,   // bumped version – you may need onUpgrade if already installed
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    if (!exists) {
      await _seedInitialData(db);
    }

    return db;
  }

  // =====================
  // SCHEMA V2
  // =====================
  Future<void> _onCreate(Database db, int version) async {
    // Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    // Guidelines (core – content moved to sections)
    await db.execute('''
      CREATE TABLE guidelines (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        slug TEXT UNIQUE NOT NULL,
        category_id INTEGER,
        status TEXT DEFAULT 'draft',
        updated_at TEXT
      )
    ''');

    // Guideline sections (Markdown content blocks)
    await db.execute('''
      CREATE TABLE guideline_sections (
        id INTEGER PRIMARY KEY,
        guideline_id INTEGER REFERENCES guidelines(id) ON DELETE CASCADE,
        section_type TEXT NOT NULL,
        title TEXT DEFAULT '',
        content TEXT DEFAULT '',
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // Bookmarks (unchanged)
    await db.execute('''
      CREATE TABLE bookmarks (
        guideline_id INTEGER PRIMARY KEY,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Meta for sync tracking
    await db.execute('''
      CREATE TABLE meta (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // FTS5 over sections content + guideline title
    await db.execute('''
      CREATE VIRTUAL TABLE guidelines_fts USING fts5(
        title,
        content,
        content='guideline_sections',
        content_rowid='id'
      )
    ''');

    // Triggers for FTS
    await db.execute('''
      CREATE TRIGGER sections_ai AFTER INSERT ON guideline_sections BEGIN
        INSERT INTO guidelines_fts(rowid, title, content)
        VALUES (new.id, 
                (SELECT title FROM guidelines WHERE id = new.guideline_id),
                new.content);
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER sections_ad AFTER DELETE ON guideline_sections BEGIN
        DELETE FROM guidelines_fts WHERE rowid = old.id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER sections_au AFTER UPDATE ON guideline_sections BEGIN
        UPDATE guidelines_fts
        SET content = new.content,
            title = (SELECT title FROM guidelines WHERE id = new.guideline_id)
        WHERE rowid = new.id;
      END;
    ''');
  }

  // Upgrade from version 1 to 2 (if app already installed)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old FTS tables if exist
      await db.execute('DROP TABLE IF EXISTS guidelines_fts');
      // Create new tables
      await db.execute('''
        CREATE TABLE guideline_sections (
          id INTEGER PRIMARY KEY,
          guideline_id INTEGER REFERENCES guidelines(id) ON DELETE CASCADE,
          section_type TEXT NOT NULL,
          title TEXT DEFAULT '',
          content TEXT DEFAULT '',
          sort_order INTEGER DEFAULT 0
        )
      ''');
      // Migrate old columns to sections (if they exist)
      await db.execute('''
        INSERT INTO guideline_sections (guideline_id, section_type, content)
        SELECT id, 'overview', overview FROM guidelines WHERE overview IS NOT NULL AND overview != ''
      ''');
      await db.execute('''
        INSERT INTO guideline_sections (guideline_id, section_type, content)
        SELECT id, 'diagnosis', diagnosis FROM guidelines WHERE diagnosis IS NOT NULL AND diagnosis != ''
      ''');
      await db.execute('''
        INSERT INTO guideline_sections (guideline_id, section_type, content)
        SELECT id, 'management', management FROM guidelines WHERE management IS NOT NULL AND management != ''
      ''');
      await db.execute('''
        INSERT INTO guideline_sections (guideline_id, section_type, content)
        SELECT id, 'complications', complications FROM guidelines WHERE complications IS NOT NULL AND complications != ''
      ''');
      // Remove old columns (safe, as they are no longer in the model)
      await db.execute('ALTER TABLE guidelines RENAME COLUMN overview TO _overview_old');
      await db.execute('ALTER TABLE guidelines RENAME COLUMN diagnosis TO _diagnosis_old');
      await db.execute('ALTER TABLE guidelines RENAME COLUMN management TO _management_old');
      await db.execute('ALTER TABLE guidelines RENAME COLUMN complications TO _complications_old');

      // Create FTS and triggers
      await db.execute('''
        CREATE VIRTUAL TABLE guidelines_fts USING fts5(
          title,
          content,
          content='guideline_sections',
          content_rowid='id'
        )
      ''');
      await db.execute('''
        INSERT INTO guidelines_fts(guidelines_fts) VALUES('rebuild')
      '''); // populate from existing sections
    }
  }

  // =====================
  // SEED DATA (now sections)
  // =====================
  Future<void> _seedInitialData(Database db) async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/guidelines.json');
      final data = jsonDecode(jsonString);

      // categories
      for (final cat in data['categories']) {
        await db.insert('categories', cat,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // guidelines with sections
      if (data['guidelines'] != null) {
        for (final g in data['guidelines']) {
          final id = g['id'];
          await db.insert('guidelines', {
            'id': id,
            'title': g['title'],
            'slug': g['slug'],
            'category_id': g['category_id'],
            'status': g['status'] ?? 'published',
            'updated_at': g['updated_at'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          // sections as array in JSON
          if (g['sections'] != null) {
            for (int i = 0; i < (g['sections'] as List).length; i++) {
              final sec = g['sections'][i];
              await db.insert('guideline_sections', {
                'guideline_id': id,
                'section_type': sec['section_type'] ?? 'overview',
                'title': sec['title'] ?? '',
                'content': sec['content'] ?? '',
                'sort_order': sec['sort_order'] ?? i,
              });
            }
          }
        }
      }
    } catch (_) {}
  }

  // =====================
  // CATEGORIES
  // =====================
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.query('categories', orderBy: 'name');
  }

  // =====================
  // GUIDELINES
  // =====================
  Future<List<Map<String, dynamic>>> getGuidelines({int? categoryId}) async {
    final db = await database;
    return db.query(
      'guidelines',
      where: categoryId != null ? 'category_id = ?' : null,
      whereArgs: categoryId != null ? [categoryId] : null,
      orderBy: 'title',
    );
  }

  Future<Map<String, dynamic>?> getGuidelineBySlug(String slug) async {
    final db = await database;
    final res = await db.query('guidelines',
        where: 'slug = ?', whereArgs: [slug]);
    if (res.isEmpty) return null;
    return res.first;
  }

  // =====================
  // SECTIONS
  // =====================
  Future<List<Map<String, dynamic>>> getSections(int guidelineId) async {
    final db = await database;
    return db.query('guideline_sections',
        where: 'guideline_id = ?',
        orderBy: 'sort_order',
        whereArgs: [guidelineId]);
  }

  // =====================
  // FTS SEARCH
  // =====================
  Future<List<Map<String, dynamic>>> searchGuidelinesFTS(String query) async {
    final db = await database;
    if (query.trim().isEmpty) return [];

    return db.rawQuery('''
      SELECT g.*, c.name as category_name,
             snippet(guidelines_fts, 0, '<b>', '</b>', '...', 10) as snippet
      FROM guidelines_fts f
      JOIN guideline_sections s ON s.id = f.rowid
      JOIN guidelines g ON g.id = s.guideline_id
      LEFT JOIN categories c ON c.id = g.category_id
      WHERE guidelines_fts MATCH ?
      ORDER BY bm25(guidelines_fts)
    ''', [query]);
  }

  // =====================
  // BOOKMARKS (unchanged)
  // =====================
  Future<void> addBookmark(int id) async {
    final db = await database;
    await db.insert('bookmarks', {'guideline_id': id},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeBookmark(int id) async {
    final db = await database;
    await db.delete('bookmarks',
        where: 'guideline_id = ?', whereArgs: [id]);
  }

  Future<bool> isBookmarked(int id) async {
    final db = await database;
    final res = await db.query('bookmarks',
        where: 'guideline_id = ?', whereArgs: [id]);
    return res.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getBookmarkedGuidelines() async {
    final db = await database;
    return db.rawQuery('''
      SELECT g.*, c.name as category_name
      FROM guidelines g
      LEFT JOIN categories c ON c.id = g.category_id
      WHERE g.id IN (SELECT guideline_id FROM bookmarks)
      ORDER BY g.title
    ''');
  }

  // =====================
  // META (unchanged)
  // =====================
  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert('meta', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getMeta(String key) async {
    final db = await database;
    final res = await db.query('meta',
        where: 'key = ?', whereArgs: [key]);
    if (res.isEmpty) return null;
    return res.first['value'] as String?;
  }
}
