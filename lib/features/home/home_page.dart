import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../guidelines/guideline_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _guidelines = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  int? _selectedCategoryId;

  final DatabaseHelper _db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final categories = await _db.getCategories();
    final guidelines = await _db.getGuidelines();
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
    final filtered = await _db.getGuidelines(categoryId: id);
    setState(() {
      _guidelines = filtered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        if (_categories.isNotEmpty)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryId == cat['id'];
                return GestureDetector(
                  onTap: () => _filterByCategory(isSelected ? null : cat['id']),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat['name'],
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: _guidelines.isEmpty
              ? const Center(child: Text('No guidelines found'))
              : ListView.builder(
                  itemCount: _guidelines.length,
                  itemBuilder: (context, index) {
                    final item = _guidelines[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(item['title']),
                        subtitle: Text(_getCategoryName(item['category_id'])),
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getCategoryName(int? catId) {
    if (catId == null) return '';
    for (final cat in _categories) {
      if (cat['id'] == catId) return cat['name'];
    }
    return '';
  }
}
