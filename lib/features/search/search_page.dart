import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/database_helper.dart';
import '../../core/widgets/highlight_text.dart';
import '../guidelines/guideline_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  String _query = "";

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _query = value;

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _search(value),
    );
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    final res = await _db.searchGuidelinesFTS(query);

    if (!mounted) return;

    setState(() {
      _results = res;
      _loading = false;
    });
  }

  void _clearSearch() {
    _controller.clear();
    _query = "";

    setState(() {
      _results = [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Column(
        children: [
          _buildSearchBar(),

          if (_loading)
            const LinearProgressIndicator(
              color: Color(0xFF1976D2),
            ),

          Expanded(
            child: _results.isEmpty
                ? _emptyState()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  // =========================
  // SEARCH BAR
  // =========================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          hintText: 'Search clinical guidelines...',
          hintStyle: const TextStyle(color: Colors.white70),

          prefixIcon: const Icon(
            Icons.search,
            color: Colors.white,
          ),

          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                )
              : null,

          filled: true,
          fillColor: Colors.white.withOpacity(0.15),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // =========================
  // RESULTS
  // =========================
  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),

            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(
                Icons.medical_services,
                color: Color(0xFF1976D2),
              ),
            ),

            title: HighlightText(
              text: item['title'] ?? '',
              query: _query,
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: HighlightText(
                text: (item['overview'] ?? '')
                    .toString()
                    .replaceAll('\n', ' '),
                query: _query,
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
    );
  }

  // =========================
  // EMPTY STATE (Medical UX)
  // =========================
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.biotech,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 14),
            Text(
              'Clinical Search Engine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Search diseases, treatments, and medical guidelines using evidence-based data.',
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