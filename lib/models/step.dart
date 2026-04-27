import 'package:isar/isar.dart';

part 'step.g.dart';

enum StepType {
  prep,
  cooking,
}

@embedded
class RecipeStep {
  String id;
  String description;
  int? timerMinutes;
  int order;
  String? emoji; // Emoji for this step

  @Enumerated(EnumType.name)
  StepType stepType;

  RecipeStep({
    this.id = '',
    this.description = '',
    this.timerMinutes,
    this.order = 0,
    this.emoji,
    this.stepType = StepType.prep,
  });

  RecipeStep copyWith({
    String? id,
    String? description,
    int? timerMinutes,
    int? order,
    String? emoji,
    StepType? stepType,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      description: description ?? this.description,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      order: order ?? this.order,
      emoji: emoji ?? this.emoji,
      stepType: stepType ?? this.stepType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'timerMinutes': timerMinutes,
      'order': order,
      'emoji': emoji,
      'stepType': stepType.name,
    };
  }

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'],
      description: json['description'],
      timerMinutes: json['timerMinutes'],
      order: json['order'],
      emoji: json['emoji'],
      stepType: StepType.values.firstWhere(
        (e) => e.name == (json['stepType'] ?? 'cooking'),
        orElse: () => StepType.cooking,
      ),
    );
  }
}
