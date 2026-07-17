const List<Map<String, String>> defaultCategories = [
  {'key': 'burger', 'name': 'بەرگر', 'icon': '🍔'},
  {'key': 'pizza', 'name': 'پیتزا', 'icon': '🍕'},
  {'key': 'shawarma', 'name': 'شاورمە', 'icon': '🌯'},
  {'key': 'chicken', 'name': 'مریشک', 'icon': '🍗'},
  {'key': 'salad', 'name': 'سەلەتە', 'icon': '🥗'},
];

List<Map<String, String>> effectiveCategories(List<Map<String, String>> dbCategories) {
  if (dbCategories.isEmpty) return defaultCategories;
  return dbCategories.where((c) => c['key'] != 'all').toList();
}
