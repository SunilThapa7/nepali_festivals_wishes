import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/data/repositories/festival_repository.dart';
import 'package:nepali_festival_wishes/models/festival.dart';

// Provider for the festival repository
final festivalRepositoryProvider = Provider<FestivalRepository>((ref) {
  return FestivalRepository();
});

// Provider for all festivals
final festivalProvider = FutureProvider<List<Festival>>((ref) async {
  final repository = ref.watch(festivalRepositoryProvider);
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));
  return repository.getAllFestivals();
});

// Provider for upcoming festivals
final upcomingFestivalsProvider = FutureProvider<List<Festival>>((ref) async {
  final repository = ref.watch(festivalRepositoryProvider);
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));
  return repository.getUpcomingFestivals();
});

// Provider for filtered festivals by category
final festivalsByCategoryProvider =
    FutureProvider.family<List<Festival>, FestivalCategory>(
        (ref, category) async {
  final repository = ref.watch(festivalRepositoryProvider);
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  return repository.getFestivalsByCategory(category);
});

// Provider for a single festival by ID
final festivalByIdProvider =
    FutureProvider.family<Festival?, String>((ref, id) async {
  final repository = ref.watch(festivalRepositoryProvider);
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  return repository.getFestivalById(id);
});

// Provider for search results
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Festival>>((ref) async {
  final repository = ref.watch(festivalRepositoryProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return repository.getAllFestivals();
  }

  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  return repository.searchFestivals(query);
});

// Provider for selected category filter (using a string instead of enum for easier navigation)
final selectedCategoryStringProvider = StateProvider<String?>((ref) => null);

// Provider for selected category (as enum)
final selectedCategoryProvider = StateProvider<FestivalCategory?>((ref) {
  final categoryString = ref.watch(selectedCategoryStringProvider);
  if (categoryString == null) return null;

  switch (categoryString.toLowerCase()) {
    case 'religious':
      return FestivalCategory.religious;
    case 'national':
      return FestivalCategory.national;
    case 'cultural':
      return FestivalCategory.cultural;
    case 'seasonal':
      return FestivalCategory.seasonal;
    default:
      return null;
  }
});

// Provider for festivals filtered by the selected category
final filteredFestivalsProvider = FutureProvider<List<Festival>>((ref) async {
  final repository = ref.watch(festivalRepositoryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  if (selectedCategory == null) {
    return repository.getAllFestivals();
  }

  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  return repository.getFestivalsByCategory(selectedCategory);
});
