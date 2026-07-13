import 'package:my_resturant/models/recipe.dart';

List<Recipe> mockRecipes = [
  Recipe(id: '1', name: 'بەرگری چیزبۆرگەر', imageUrl: 'https://picsum.photos/seed/cheeseburger/400/300', price: 8500, category: 'burger', description: 'بەرگری تایبەت و دەبڵ پەنیر'),
  Recipe(id: '2', name: 'پیتزا مۆتزاریلا', imageUrl: 'https://picsum.photos/seed/pizza/400/300', price: 12000, category: 'pizza', description: 'پیتزای مۆتزاریلا و تەرخان'),
  Recipe(id: '3', name: 'شاورمە دەبڵ', imageUrl: 'https://picsum.photos/seed/shawarma/400/300', price: 7000, category: 'shawarma', description: 'شاورمەی دەبڵ بە تەرخان و سەلەتە'),
  Recipe(id: '4', name: 'کەبابی کۆیندە', imageUrl: 'https://picsum.photos/seed/kebab/400/300', price: 15000, category: 'shawarma', description: 'کەبابی کۆیندە بە برژاو'),
  Recipe(id: '5', name: 'بەرگری کلاسیک', imageUrl: 'https://picsum.photos/seed/burger/400/300', price: 6500, category: 'burger', description: 'بەرگری کلاسیک بە پەنیر و کەچەپ'),
  Recipe(id: '6', name: 'زەنگیانەی مریشک', imageUrl: 'https://picsum.photos/seed/chicken-sandwich/400/300', price: 5500, category: 'chicken', description: 'زەنگیانەی مریشکی بە تایبەت'),
  Recipe(id: '7', name: 'فەرجی مریشک', imageUrl: 'https://picsum.photos/seed/fried-chicken/400/300', price: 9500, category: 'chicken', description: 'فەرجی مریشکی خوایی بە سۆس'),
  Recipe(id: '8', name: 'دۆنەر کێباب', imageUrl: 'https://picsum.photos/seed/doner/400/300', price: 8000, category: 'shawarma', description: 'دۆنەر کێباب بە نانی تایبەت'),
  Recipe(id: '9', name: 'سەلەتە کێزەر', imageUrl: 'https://picsum.photos/seed/salad/400/300', price: 4500, category: 'salad', description: 'سەلەتەی کێزەری تازە'),
  Recipe(id: '10', name: 'فەرجی سوشی', imageUrl: 'https://picsum.photos/seed/sushi/400/300', price: 11000, category: 'salad', description: 'فەرجی سوشی بە تایبەت'),
  Recipe(id: '11', name: 'پاستا ئەلفرێدۆ', imageUrl: 'https://picsum.photos/seed/pasta/400/300', price: 10000, category: 'pizza', description: 'پاستا ئەلفرێدۆ بە مریشک'),
  Recipe(id: '12', name: 'لەحمی عەجین', imageUrl: 'https://picsum.photos/seed/lahmacun/400/300', price: 5000, category: 'pizza', description: 'لەحمی عەجینی تایبەت'),
];

List<Map<String, String>> categories = [
  {'key': 'all', 'name': 'هەموو', 'icon': '🍽'},
  {'key': 'burger', 'name': 'بەرگر', 'icon': '🍔'},
  {'key': 'pizza', 'name': 'پیتزا', 'icon': '🍕'},
  {'key': 'shawarma', 'name': 'شاورمە', 'icon': '🌯'},
  {'key': 'chicken', 'name': 'مریشک', 'icon': '🍗'},
  {'key': 'salad', 'name': 'سەلەتە', 'icon': '🥗'},
];
