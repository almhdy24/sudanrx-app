import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../repositories/guideline_repository.dart';

class GuidelinePage extends StatefulWidget {
  final String title;
  final String slug;
  const GuidelinePage({Key? key, required this.title, required this.slug}) : super(key: key);

  @override
  State<GuidelinePage> createState() => _GuidelinePageState();
}

class _GuidelinePageState extends State<GuidelinePage> {
  final _repo = GuidelineRepository();
  Map<String, dynamic>? _guideline;
  List<Map<String, dynamic>> _sections = [];
  bool _loading = true;
  bool _bookmarked = false;
  int? _guidelineId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final g = await _repo.getGuidelineBySlug(widget.slug);
    if (g != null) {
      final id = g['id'] as int;
      final sections = await _repo.getSections(id);
      final isBm = await _repo.isBookmarked(id);
      if (!mounted) return;
      setState(() {
        _guideline = g;
        _sections = sections;
        _bookmarked = isBm;
        _guidelineId = id;
        _loading = false;
      });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_guidelineId == null) return;
    final id = _guidelineId!;
    setState(() => _bookmarked = !_bookmarked);
    if (_bookmarked) {
      await _repo.addBookmark(id);
    } else {
      await _repo.removeBookmark(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(), body: Center(child: CircularProgressIndicator()));
    if (_guideline == null) return Scaffold(appBar: AppBar(), body: Center(child: Text('Guideline not found')));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _toggleBookmark,
            icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            final sec = _sections[index];
            final title = sec['title'] as String?;
            final content = sec['content'] as String? ?? '';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    MarkdownBody(data: content),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
