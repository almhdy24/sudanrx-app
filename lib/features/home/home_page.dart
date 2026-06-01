import 'package:flutter/material.dart';
import '../../repositories/guideline_repository.dart';
import '../../services/sync_service.dart';
import '../guidelines/guideline_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = GuidelineRepository();
  final SyncService _sync = SyncService();

  List<Map<String, dynamic>> _guidelines = [];
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  bool _syncing = false;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final categories = await _repo.getCategories();
    final guidelines = await _repo.getGuidelines(categoryId: _selectedCategoryId);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _guidelines = guidelines;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _sync.syncAll();
    await _loadData();
  }

  Future<void> _manualSync() async {
    setState(() => _syncing = true);
    await _sync.syncAll();
    await _loadData();
    if (mounted) setState(() => _syncing = false);
  }

  void _filter(int? id) {
    setState(() => _selectedCategoryId = id);
    _loadData(); // will reload with filter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton(
        onPressed: _manualSync,
        backgroundColor: Colors.blue,
        child: _syncing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.sync),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFF1976D2),
                      child: const Text(
                        "SudanRx Clinical Guidelines",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _categories.map((c) {
                          final selected = c['id'] == _selectedCategoryId;
                          return Padding(
                            padding: const EdgeInsets.all(6),
                            child: ChoiceChip(
                              label: Text(c['name']),
                              selected: selected,
                              onSelected: (_) => _filter(selected ? null : c['id']),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = _guidelines[i];
                        return ListTile(
                          title: Text(item['title']),
                          subtitle: Text(item['status'] ?? ''),
                          trailing: const Icon(Icons.chevron_right),
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
                        );
                      },
                      childCount: _guidelines.length,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
