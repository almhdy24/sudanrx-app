import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // =====================
  // CATEGORIES
  // =====================
  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await _client.from('categories').select();
    return List<Map<String, dynamic>>.from(data);
  }

  // =====================
  // GUIDELINES
  // =====================
  Future<List<Map<String, dynamic>>> getGuidelines() async {
    final data = await _client
        .from('guidelines')
        .select();

    return List<Map<String, dynamic>>.from(data);
  }

  // =====================
  // SEARCH (REMOTE OPTIONAL)
  // =====================
  Future<List<Map<String, dynamic>>> searchGuidelines(String query) async {
    final data = await _client
        .from('guidelines')
        .select()
        .ilike('title', '%$query%'); // safer than textSearch

    return List<Map<String, dynamic>>.from(data);
  }
}