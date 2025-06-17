import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepali_festival_wishes/core/utils/app_colors.dart';
import 'package:nepali_festival_wishes/core/utils/app_constants.dart';
import 'package:nepali_festival_wishes/core/utils/date_formatter.dart';
import 'package:nepali_festival_wishes/models/festival.dart';
import 'package:nepali_festival_wishes/providers/festival_provider.dart';
import 'package:nepali_festival_wishes/providers/favorites_provider.dart';
import 'package:share_plus/share_plus.dart';

class FestivalDetailsScreen extends ConsumerStatefulWidget {
  final String festivalId;

  const FestivalDetailsScreen({
    Key? key,
    required this.festivalId,
  }) : super(key: key);

  @override
  ConsumerState<FestivalDetailsScreen> createState() =>
      _FestivalDetailsScreenState();
}

class _FestivalDetailsScreenState extends ConsumerState<FestivalDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCardIndex = 0;
  final PageController _cardPageController = PageController();
  bool _isShowingFullImage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final festivalAsync = ref.watch(festivalByIdProvider(widget.festivalId));

    return Scaffold(
      body: festivalAsync.when(
        data: (festival) {
          if (festival == null) {
            return const Center(
              child: Text('Festival not found'),
            );
          }
          return _buildFestivalDetailsContent(festival);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildFestivalDetailsContent(Festival festival) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final isFutureFestival = festival.date.isAfter(DateTime.now());

    return Stack(
      children: [
        // Festival Image
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          child: Image.asset(
            festival.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),

        // Content Scrollable Area
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.35,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Festival info on image
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(festival.category),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getCategoryName(festival.category),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Festival name
                          Text(
                            festival.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Date info
                          Row(
                            children: [
                              Icon(
                                isFutureFestival
                                    ? Icons.event_available
                                    : Icons.event,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatFullDate(festival.date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              if (isFutureFestival) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    DateFormatter.getTimeRemaining(
                                        festival.date),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Festival Content
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Description Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            festival.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Wishes Tab Bar
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Nepali Wishes'),
                        Tab(text: 'English Wishes'),
                      ],
                    ),
                    // Wishes Tab Views
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Nepali Wishes
                          _buildWishesList(
                            festival.nepaliWishes,
                            festival.name,
                            true,
                          ),
                          // English Wishes
                          _buildWishesList(
                            festival.englishWishes,
                            festival.name,
                            false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Greeting Cards Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Greeting Cards',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: PageView.builder(
                              controller: _cardPageController,
                              itemCount: festival.cardImageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentCardIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isShowingFullImage = true;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        festival.cardImageUrls[index],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Card Indicators and Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Card Indicators
                              Row(
                                children: List.generate(
                                  festival.cardImageUrls.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index == _currentCardIndex
                                          ? AppColors.primary
                                          : Colors.grey[300],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Share Button
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  Share.share(
                                    'Check out this beautiful ${festival.name} greeting card!',
                                  );
                                },
                              ),
                              // Save Button
                              IconButton(
                                icon: const Icon(Icons.save_alt),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        AppConstants.successImageSaved,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Full Screen Image View
        if (_isShowingFullImage)
          GestureDetector(
            onTap: () {
              setState(() {
                _isShowingFullImage = false;
              });
            },
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      festival.cardImageUrls[_currentCardIndex],
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: statusBarHeight + 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isShowingFullImage = false;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWishesList(
      List<String> wishes, String festivalName, bool isNepali) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final wish = wishes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wish,
                  style: TextStyle(
                    fontSize: isNepali ? 18 : 16,
                    fontWeight: isNepali ? FontWeight.w500 : FontWeight.normal,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Favorite Button
                    Consumer(
                      builder: (context, ref, _) {
                        final isFavorite =
                            ref.watch(favoriteWishProvider(wish));
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.primary : Colors.grey,
                          ),
                          onPressed: () {
                            ref
                                .read(favoriteWishProvider(wish).notifier)
                                .toggleFavorite(festivalName, widget.festivalId,
                                    wish, isNepali);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? AppConstants.successFavoriteRemoved
                                      : AppConstants.successFavoriteAdded,
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          tooltip: 'Add to favorites',
                        );
                      },
                    ),
                    // Copy Button
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: wish));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppConstants.successWishCopied),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      tooltip: 'Copy to clipboard',
                    ),
                    // Share Button
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        Share.share(wish);
                      },
                      tooltip: 'Share wish',
                    ),
                  ],
                ),
              ],
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
