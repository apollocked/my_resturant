class AppConstants {
  AppConstants._();

  static const int defaultTableCount = 10;
  static const int maxTableCount = 20;
  static const int menuGridCrossAxisCount = 2;
  static const double menuGridAspectRatio = 0.72;
  static const int tableGridCrossAxisCount = 4;
  static const double tableGridAspectRatio = 1.0;
  static const double imageCardSize = 48.0;
  static const double emptyIconSize = 44.0;
  static const double heroHeight = 140.0;
  static const String defaultImageBase = 'https://picsum.photos/seed/';
  static const String defaultImageParams = '/400/300';
  static const String dbFileName = 'restaurant.db';

  // SaaS limits (free tier)
  static const int maxRecipesPerRestaurant = 50;
  static const int maxCategoriesPerRestaurant = 15;
  static const int maxOrdersPerRestaurant = 10000;
  static const int maxImageSizeBytes = 2 * 1024 * 1024; // 2MB
}
