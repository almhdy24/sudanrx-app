import 'database_helper.dart';

class BookmarkService {
  static final DatabaseHelper _db = DatabaseHelper();

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    return await _db.getBookmarkedGuidelines();
  }

  static Future<void> addBookmark(int guidelineId) async {
    await _db.addBookmark(guidelineId);
  }

  static Future<void> removeBookmark(int guidelineId) async {
    await _db.removeBookmark(guidelineId);
  }

  static Future<bool> isBookmarked(int guidelineId) async {
    return await _db.isBookmarked(guidelineId);
  }
}
