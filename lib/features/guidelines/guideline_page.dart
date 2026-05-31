import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../services/bookmark_service.dart';

class GuidelinePage extends StatefulWidget {
  final String title;
  final String slug;
  const GuidelinePage({super.key, required this.title, required this.slug});

  @override
  State<GuidelinePage> createState() => _GuidelinePageState();
}

class _GuidelinePageState extends State<GuidelinePage> {
  final DatabaseHelper _db = DatabaseHelper();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _db.getGuidelineBySlug(widget.slug);
    if (data != null) {
      final bookmarked = await BookmarkService.isBookmarked(data['id']);
      setState(() {
        _data = data;
        _isBookmarked = bookmarked;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (_data == null) return;
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(_data!['id']);
    } else {
      await BookmarkService.addBookmark(_data!['id']);
    }
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isBookmarked ? 'Bookmarked' : 'Removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _data != null ? _toggleBookmark : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Guideline not found'))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _infoCard('Overview', _data!['overview']),
                    _infoCard('Diagnosis', _data!['diagnosis']),
                    _infoCard('Management', _data!['management']),
                    _infoCard('Complications', _data!['complications']),
                  ],
                ),
    );
  }

  Widget _infoCard(String title, String? content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content ?? 'Not available'),
        ],
      ),
    );
  }
}
