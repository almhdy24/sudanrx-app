import 'package:flutter/material.dart';

import '../../services/bookmark_service.dart';
import '../guidelines/guideline_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookmarks =
        await BookmarkService.getBookmarks();

    if (!mounted) return;

    setState(() {
      _bookmarks = bookmarks;
      _isLoading = false;
    });
  }

  Future<void> _remove(int id) async {
    await BookmarkService.removeBookmark(id);

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _bookmarks.isEmpty
              ? _emptyState()
              : Column(
                  children: [
                    _header(),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.all(12),
                          itemCount:
                              _bookmarks.length,
                          itemBuilder:
                              (context, index) {
                            final item =
                                _bookmarks[index];

                            return Dismissible(
                              key: Key(
                                item['id']
                                    .toString(),
                              ),
                              direction:
                                  DismissDirection
                                      .endToStart,
                              background: Container(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 12,
                                ),
                                padding:
                                    const EdgeInsets
                                        .only(
                                  right: 20,
                                ),
                                alignment: Alignment
                                    .centerRight,
                                decoration:
                                    BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) =>
                                  _remove(
                                item['id'],
                              ),
                              child: Card(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 12,
                                ),
                                elevation: 2,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets
                                          .all(
                                    14,
                                  ),
                                  leading:
                                      const CircleAvatar(
                                    backgroundColor:
                                        Color(
                                      0xFFE3F2FD,
                                    ),
                                    child: Icon(
                                      Icons
                                          .bookmark,
                                      color: Color(
                                        0xFF1976D2,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item['title'],
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    item['category_name'] ??
                                        '',
                                  ),
                                  trailing:
                                      const Icon(
                                    Icons
                                        .arrow_forward_ios,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            GuidelinePage(
                                          title:
                                              item['title'],
                                          slug:
                                              item['slug'],
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
                    ),
                  ],
                ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
      ),
      child: Text(
        'Saved Guidelines (${_bookmarks.length})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey,
            ),
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
              style: TextStyle(
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}