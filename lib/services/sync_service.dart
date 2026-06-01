import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class SyncService {
  final _supabase = Supabase.instance.client;
  final _db = DatabaseHelper();

  bool _isSyncing = false;

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await Future.wait([
        syncCategories(),
        syncGuidelines(),
      ]);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncCategories() async {
    final data = await _supabase.from('categories').select();
    final db = await _db.database;
    final batch = db.batch();

    for (final item in data) {
      batch.insert(
        'categories',
        {'id': item['id'], 'name': item['name']},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> syncGuidelines() async {
    final db = await _db.database;
    final lastSync = await _getLastSync();

    // Fetch guidelines with sections (nested select)
    final data = await _supabase
        .from('guidelines')
        .select('*, sections:guideline_sections(*)')
        .gt('updated_at', lastSync);

    final batch = db.batch();

    for (final g in data) {
      // Insert/update guideline
      batch.insert(
        'guidelines',
        {
          'id': g['id'],
          'title': g['title'],
          'slug': g['slug'],
          'category_id': g['category_id'],
          'status': g['status'],
          'updated_at': g['updated_at'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete old sections (will be replaced)
      batch.delete('guideline_sections',
          where: 'guideline_id = ?', whereArgs: [g['id']]);

      // Insert all sections
      final sections = (g['sections'] as List?) ?? [];
      for (int i = 0; i < sections.length; i++) {
        final sec = sections[i];
        batch.insert(
          'guideline_sections',
          {
            'id': sec['id'],
            'guideline_id': sec['guideline_id'] ?? g['id'],
            'section_type': sec['section_type'],
            'title': sec['title'] ?? '',
            'content': sec['content'] ?? '',
            'sort_order': sec['sort_order'] ?? i,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);

    await _setLastSync(DateTime.now().toIso8601String());
  }

  Future<String> _getLastSync() async {
    final db = await _db.database;
    final res = await db.query('meta', where: 'key = ?', whereArgs: ['last_sync']);
    if (res.isEmpty) return '1970-01-01';
    return res.first['value'] as String;
  }

  Future<void> _setLastSync(String value) async {
    final db = await _db.database;
    await db.insert(
      'meta',
      {'key': 'last_sync', 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
