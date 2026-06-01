import 'package:flutter/material.dart';
import '../../repositories/guideline_repository.dart';
import '../guidelines/guideline_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _repo = GuidelineRepository();

  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _repo.getBookmarks();
    if (!mounted) return;
    setState(() {
      _bookmarks = data;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _load();
    if (!mounted) return;
    setState(() => _refreshing = false);
  }

  Future<void> _remove(int id) async {
    await _repo.removeBookmark(id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from bookmarks'),
        backgroundColor: Color(0xFF1976D2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: Text('Bookmarks (${_bookmarks.length})'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, index) {
                      final item = _bookmarks[index];
                      return Dismissible(
                        key: Key(item['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _remove(item['id']),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE3F2FD),
                              child: Icon(
                                Icons.bookmark,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            title: Text(
                              item['title'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item['category_name'] ?? '',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GuidelinePage(
                                    title: item['title'],
                                    slug: item['slug'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Saved Guidelines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bookmark clinical guidelines to access them offline anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
