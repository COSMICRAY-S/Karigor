import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/karigor_repository.dart';
import '../../models/provider_model.dart';
import '../../widgets/provider_card.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<ProviderModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await ApiService.getProviders(category: query.trim());
      if (results.isNotEmpty) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback search in KarigorRepository
    final repoResults = KarigorRepository().getFilteredProviders(category: query.trim());
    setState(() {
      _results = repoResults;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clayBg,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.ink),
          cursorColor: AppColors.terracotta,
          decoration: const InputDecoration(
            hintText: 'পেশা লিখে খুঁজুন (যেমন: প্লাম্বার)...',
            hintStyle: TextStyle(color: AppColors.inkSoft),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.terracotta),
            onPressed: () => _search(_searchController.text),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
          : !_hasSearched
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: AppColors.inkSoft),
                      SizedBox(height: 12),
                      Text('পেশা বা ক্যাটাগরি লিখে কারিগর খুঁজুন',
                          style: TextStyle(color: AppColors.inkSoft, fontSize: 14)),
                    ],
                  ),
                )
              : _results.isEmpty
                  ? const Center(
                      child: Text('কোনো কারিগর পাওয়া যায়নি',
                          style: TextStyle(color: AppColors.inkSoft)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _results.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProviderCard(
                          provider: _results[i],
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/provider-detail',
                            arguments: _results[i].id,
                          ),
                        ),
                      ),
                    ),
    );
  }
}
