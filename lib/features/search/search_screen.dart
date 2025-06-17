import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/core/utils/app_colors.dart';
import 'package:nepali_festival_wishes/main.dart';
import 'package:nepali_festival_wishes/models/festival.dart';
import 'package:nepali_festival_wishes/providers/festival_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search festivals...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  }
                },
              )
            : const Text('Search Festivals'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Results for "$query"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: searchResults.when(
              data: (festivals) {
                if (festivals.isEmpty) {
                  return _buildEmptyResults();
                }
                return _buildSearchResults(festivals);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No festivals found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ref.read(searchQueryProvider).isEmpty
                ? 'Search for festivals by name or description'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Festival> festivals) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: festivals.length,
      itemBuilder: (context, index) {
        final festival = festivals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => AppNavigation.navigateToFestivalDetails(festival.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Festival image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      festival.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Festival info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(festival.category),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getCategoryName(festival.category),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              festival.date.isAfter(DateTime.now())
                                  ? Icons.event_available
                                  : Icons.event,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          festival.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          festival.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(FestivalCategory category) {
    switch (category) {
      case FestivalCategory.religious:
        return AppColors.religious;
      case FestivalCategory.national:
        return AppColors.national;
      case FestivalCategory.cultural:
        return AppColors.cultural;
      case FestivalCategory.seasonal:
        return AppColors.seasonal;
      default:
        return AppColors.primary;
    }
  }

  String _getCategoryName(FestivalCategory category) {
    switch (category) {
      case FestivalCategory.religious:
        return 'Religious';
      case FestivalCategory.national:
        return 'National';
      case FestivalCategory.cultural:
        return 'Cultural';
      case FestivalCategory.seasonal:
        return 'Seasonal';
      default:
        return 'Other';
    }
  }
}
