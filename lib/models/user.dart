import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String email;

  final String name;
  final String? passwordHash;
  final String? serverpodUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  
  // API Keys for AI features
  final String? mistralApiKey;
  final String? tavilyApiKey;

  User({
    this.id = Isar.autoIncrement,
    required this.email,
    required this.name,
    this.passwordHash,
    this.serverpodUserId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.mistralApiKey,
    this.tavilyApiKey,
  });

  User copyWith({
    Id? id,
    String? email,
    String? name,
    String? passwordHash,
    String? serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? mistralApiKey,
    String? tavilyApiKey,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      passwordHash: passwordHash ?? this.passwordHash,
      serverpodUserId: serverpodUserId ?? this.serverpodUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      mistralApiKey: mistralApiKey ?? this.mistralApiKey,
      tavilyApiKey: tavilyApiKey ?? this.tavilyApiKey,
    );
  }
}
