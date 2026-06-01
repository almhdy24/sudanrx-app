import 'package:sqflite/sqflite.dart';  // <-- added for ConflictAlgorithm
import '../services/database_helper.dart';
import '../services/supabase_service.dart';

class GuidelineRepository {
  final DatabaseHelper _local = DatabaseHelper();
  final SupabaseService _remote = SupabaseService();

  // =====================
  // SYNC FROM SERVER (uses SyncService, but here a simple pull)
  // =====================
  Future<void> syncFromServer() async {
    // We rely on SyncService now; this method can be a manual trigger
    final categories = await _remote.getCategories();
    final db = await _local.database;

    for (final c in categories) {
      await db.insert('categories', c,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // guidelines are synced by SyncService; here we skip to avoid duplication
  }

  // =====================
  // LOCAL FIRST (OFFLINE)
  // =====================
  Future<List<Map<String, dynamic>>> getCategories() {
    return _local.getCategories();
  }

  Future<List<Map<String, dynamic>>> getGuidelines({int? categoryId}) {
    return _local.getGuidelines(categoryId: categoryId);
  }

  Future<Map<String, dynamic>?> getGuidelineBySlug(String slug) {
    return _local.getGuidelineBySlug(slug);
  }

  Future<List<Map<String, dynamic>>> getSections(int guidelineId) {
    return _local.getSections(guidelineId);
  }

  Future<List<Map<String, dynamic>>> search(String query) {
    return _local.searchGuidelinesFTS(query);
  }

  // =====================
  // BOOKMARKS
  // =====================
  Future<void> addBookmark(int id) => _local.addBookmark(id);
  Future<void> removeBookmark(int id) => _local.removeBookmark(id);
  Future<bool> isBookmarked(int id) => _local.isBookmarked(id);
  Future<List<Map<String, dynamic>>> getBookmarks() {
    return _local.getBookmarkedGuidelines();
  }
}
