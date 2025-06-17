class AppConstants {
  // App Info
  static const String appName = 'Nepali Festival Wishes';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.example.nepali_festival_wishes';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultAnimationDuration = 300.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;

  // API and Data
  static const String dummyImageUrl = 'https://source.unsplash.com/random';
  static const String nepalFlagAnimation = 'assets/animations/nepal_flag.json';
  static const String festivalAnimation = 'assets/animations/festival.json';

  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoFestivals = 'No festivals found';
  static const String errorNoFavorites = 'No favorites found';
  static const String errorImageSave = 'Failed to save image';

  // Success Messages
  static const String successWishCopied = 'Wish copied to clipboard';
  static const String successFavoriteAdded = 'Added to favorites';
  static const String successFavoriteRemoved = 'Removed from favorites';
  static const String successImageSaved = 'Image saved to gallery';

  // Animation Durations
  static const int animationDurationFast = 200;
  static const int animationDurationNormal = 300;
  static const int animationDurationSlow = 500;
}
