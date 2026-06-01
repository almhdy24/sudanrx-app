import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../guidelines/guideline_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _db = DatabaseHelper();

  List<Map<String, dynamic>> _guidelines = [];
  List<Map<String, dynamic>> _categories = [];

  bool _isLoading = true;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final categories = await _db.getCategories();
    final guidelines = await _db.getGuidelines();

    if (!mounted) return;

    setState(() {
      _categories = categories;
      _guidelines = guidelines;
      _isLoading = false;
    });
  }

  Future<void> _filterByCategory(int? id) async {
    setState(() {
      _selectedCategoryId = id;
      _isLoading = true;
    });

    final filtered = await _db.getGuidelines(
      categoryId: id,
    );

    if (!mounted) return;

    setState(() {
      _guidelines = filtered;
      _isLoading = false;
    });
  }

  String _getCategoryName(int? catId) {
    if (catId == null) return '';

    for (final cat in _categories) {
      if (cat['id'] == catId) {
        return cat['name'];
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildHeader(),
                  _buildStats(),
                  _buildCategories(),
                  _buildGuidelines(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1976D2),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SudanRx',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Community Clinical Guidelines',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x11000000),
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(
                Icons.menu_book,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_guidelines.length} Clinical Guidelines Available',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    if (_categories.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 56,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];

            final isSelected =
                _selectedCategoryId == cat['id'];

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: FilterChip(
                selected: isSelected,
                label: Text(cat['name']),
                onSelected: (_) {
                  _filterByCategory(
                    isSelected ? null : cat['id'],
                  );
                },
                selectedColor:
                    const Color(0xFF1976D2),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.black87,
                ),
                checkmarkColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFF1976D2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuidelines() {
    if (_guidelines.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.menu_book_outlined,
                  size: 72,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Guidelines Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        24,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = _guidelines[index];

            return Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.all(14),
                leading: const CircleAvatar(
                  backgroundColor:
                      Color(0xFFE3F2FD),
                  child: Icon(
                    Icons.menu_book,
                    color: Color(0xFF1976D2),
                  ),
                ),
                title: Text(
                  item['title'],
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 6,
                  ),
                  child: Text(
                    _getCategoryName(
                      item['category_id'],
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
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
            );
          },
          childCount: _guidelines.length,
        ),
      ),
    );
  }
}