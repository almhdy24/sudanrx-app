import 'package:flutter/material.dart';

import '../../services/database_helper.dart';
import '../../services/bookmark_service.dart';

class GuidelinePage extends StatefulWidget {
  final String title;
  final String slug;

  const GuidelinePage({
    super.key,
    required this.title,
    required this.slug,
  });

  @override
  State<GuidelinePage> createState() =>
      _GuidelinePageState();
}

class _GuidelinePageState extends State<GuidelinePage> {
  final DatabaseHelper _db =
      DatabaseHelper();

  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final data =
        await _db.getGuidelineBySlug(
      widget.slug,
    );

    final bookmarked =
        await BookmarkService.isBookmarked(
      data?['id'] ?? 0,
    );

    setState(() {
      _data = data;
      _bookmarked = bookmarked;
      _loading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    if (_data == null) return;

    final id = _data!['id'];

    if (_bookmarked) {
      await BookmarkService.removeBookmark(
          id);
    } else {
      await BookmarkService.addBookmark(id);
    }

    setState(() {
      _bookmarked = !_bookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              _bookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _data == null
              ? const Center(
                  child: Text(
                    'Not found',
                  ),
                )
              : ListView(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  children: [
                    _card('Overview',
                        _data!['overview']),
                    _card('Diagnosis',
                        _data!['diagnosis']),
                    _card('Management',
                        _data!['management']),
                    _card(
                        'Complications',
                        _data![
                            'complications']),
                  ],
                ),
    );
  }

  Widget _card(String title, String? content) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content ?? 'Not available',
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}