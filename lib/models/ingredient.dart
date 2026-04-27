import 'package:isar/isar.dart';

part 'ingredient.g.dart';

@embedded
class Ingredient {
  String id;
  String name;
  String quantity;
  String unit;
  int order;
  String? emoji; // Emoji representation of the ingredient
  double? caloriesPer100g;
  double? proteinPer100g;
  double? carbsPer100g;
  double? fatPer100g;
  String? nutritionalSource; // Source of the nutritional data

  Ingredient({
    this.id = '',
    this.name = '',
    this.quantity = '',
    this.unit = '',
    this.order = 0,
    this.emoji,
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.nutritionalSource,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? quantity,
    String? unit,
    int? order,
    String? emoji,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    String? nutritionalSource,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      order: order ?? this.order,
      emoji: emoji ?? this.emoji,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      nutritionalSource: nutritionalSource ?? this.nutritionalSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'order': order,
      'emoji': emoji,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'nutritionalSource': nutritionalSource,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      order: json['order'],
      emoji: json['emoji'],
      caloriesPer100g: json['caloriesPer100g']?.toDouble(),
      proteinPer100g: json['proteinPer100g']?.toDouble(),
      carbsPer100g: json['carbsPer100g']?.toDouble(),
      fatPer100g: json['fatPer100g']?.toDouble(),
      nutritionalSource: json['nutritionalSource'],
    );
  }
}
