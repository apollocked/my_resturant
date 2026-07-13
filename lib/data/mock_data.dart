import 'package:my_resturant/models/recipe.dart';

final List<Recipe> mockRecipes = [
  Recipe(id: '1', name: 'بەرگری چیزبۆرگەر', imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop', price: 8500, description: 'بەرگری تایبەت و دەبڵ پەنیر'),
  Recipe(id: '2', name: 'پیتزا مۆتزاریلا', imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop', price: 12000, description: 'پیتزای مۆتزاریلا و تەرخان'),
  Recipe(id: '3', name: 'شاورمە دەبڵ', imageUrl: 'https://images.unsplash.com/photo-1561651823-34feb02250e4?w=400&h=300&fit=crop', price: 7000, description: 'شاورمەی دەبڵ بە تەرخان و سەلەتە'),
  Recipe(id: '4', name: 'کەبابی کۆیندە', imageUrl: 'https://images.unsplash.com/photo-1555072956-7758b0b29547?w=400&h=300&fit=crop', price: 15000, description: 'کەبابی کۆیندە بە برژاو'),
  Recipe(id: '5', name: 'بەرگری کلاسیک', imageUrl: 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=400&h=300&fit=crop', price: 6500, description: 'بەرگری کلاسیک بە پەنیر و کەچەپ'),
  Recipe(id: '6', name: 'زەنگیانەی مریشک', imageUrl: 'https://images.unsplash.com/photo-1606755962773-d3245690a862?w=400&h=300&fit=crop', price: 5500, description: 'زەنگیانەی مریشکی بە تایبەت'),
  Recipe(id: '7', name: 'فەرجی مریشک', imageUrl: 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400&h=300&fit=crop', price: 9500, description: 'فەرجی مریشکی خوایی بە سۆس'),
  Recipe(id: '8', name: 'دۆنەر کێباب', imageUrl: 'https://images.unsplash.com/photo-1621996346564-e3dbc5ed1a60?w=400&h=300&fit=crop', price: 8000, description: 'دۆنەر کێباب بە نانی تایبەت'),
  Recipe(id: '9', name: 'سەلەتە کێزەر', imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop', price: 4500, description: 'سەلەتەی کێزەری تازە'),
  Recipe(id: '10', name: 'فەرجی سوشی', imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop', price: 11000, description: 'فەرجی سوشی بە تایبەت'),
  Recipe(id: '11', name: 'پاستا ئەلفرێدۆ', imageUrl: 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=400&h=300&fit=crop', price: 10000, description: 'پاستا ئەلفرێدۆ بە مریشک'),
  Recipe(id: '12', name: 'لەحمی عەجین', imageUrl: 'https://images.unsplash.com/photo-1615361200141-f45040f367be?w=400&h=300&fit=crop', price: 5000, description: 'لەحمی عەجینی تایبەت'),
];

final List<Map<String, String>> categories = [
  {'name': 'هەموو', 'icon': '🍽'},
  {'name': 'بەرگر', 'icon': '🍔'},
  {'name': 'پیتزا', 'icon': '🍕'},
  {'name': 'شاورمە', 'icon': '🌯'},
  {'name': 'مریشک', 'icon': '🍗'},
  {'name': 'سەلەتە', 'icon': '🥗'},
  {'name': 'خواردنەوە', 'icon': '🥤'},
];
