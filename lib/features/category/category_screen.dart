import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/core/utils/app_colors.dart';
import 'package:nepali_festival_wishes/core/utils/date_formatter.dart';
import 'package:nepali_festival_wishes/main.dart';
import 'package:nepali_festival_wishes/models/festival.dart';
import 'package:nepali_festival_wishes/providers/festival_provider.dart';

class CategoryScreen extends ConsumerWidget {
  final String category;

  const CategoryScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Update the selected category string in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedCategoryStringProvider.notifier).state = category;
    });

    // Get the festival category enum
    final festivalCategory = _getCategoryEnum(category);

    // Watch the filtered festivals by category
    final filteredFestivals =
        ref.watch(festivalsByCategoryProvider(festivalCategory));

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Festivals'),
      ),
      drawer: const AppDrawer(),
      body: filteredFestivals.when(
        data: (festivals) {
          if (festivals.isEmpty) {
            return _buildEmptyState();
          }
          return _buildFestivalList(context, festivals);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No $category festivals found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalList(BuildContext context, List<Festival> festivals) {
    // Sort festivals: upcoming first, then past
    final upcomingFestivals = festivals
        .where((festival) => festival.date.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final pastFestivals = festivals
        .where((festival) => !festival.date.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final allSortedFestivals = [...upcomingFestivals, ...pastFestivals];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allSortedFestivals.length,
      itemBuilder: (context, index) {
        final festival = allSortedFestivals[index];
        return _buildFestivalCard(context, festival);
      },
    );
  }

  Widget _buildFestivalCard(BuildContext context, Festival festival) {
    final isFuture = festival.date.isAfter(DateTime.now());
    final categoryColor = AppColors.getCategoryColor(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => AppNavigation.navigateToFestivalDetails(festival.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Festival image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                festival.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            // Festival details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          festival.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isFuture ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isFuture
                              ? DateFormatter.getTimeRemaining(festival.date)
                              : 'Past event',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormatter.formatFullDate(festival.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    festival.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            AppNavigation.navigateToFestivalDetails(
                                festival.id),
                        style: TextButton.styleFrom(
                          foregroundColor: categoryColor,
                        ),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FestivalCategory _getCategoryEnum(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'religious':
        return FestivalCategory.religious;
      case 'national':
        return FestivalCategory.national;
      case 'cultural':
        return FestivalCategory.cultural;
      case 'seasonal':
        return FestivalCategory.seasonal;
      default:
        return FestivalCategory.religious; // Default to religious as fallback
    }
  }
}
