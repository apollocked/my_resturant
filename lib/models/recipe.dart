class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String category;

  const Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.price = 8000,
    this.description = 'بەرگری تایبەت و دەبڵ پەنیر',
    this.category = '',
  });

  factory Recipe.fromMealApi(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'name': name, 'imageUrl': imageUrl,
      'price': price, 'description': description, 'category': category,
    };
  }
}
