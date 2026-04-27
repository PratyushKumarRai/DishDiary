// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealPlanCollection on Isar {
  IsarCollection<MealPlan> get mealPlans => this.collection();
}

const MealPlanSchema = CollectionSchema(
  name: r'MealPlan',
  id: 6858060180785015955,
  properties: {
    r'avgDailyCalories': PropertySchema(
      id: 0,
      name: r'avgDailyCalories',
      type: IsarType.double,
    ),
    r'avgDailyCarbs': PropertySchema(
      id: 1,
      name: r'avgDailyCarbs',
      type: IsarType.double,
    ),
    r'avgDailyFat': PropertySchema(
      id: 2,
      name: r'avgDailyFat',
      type: IsarType.double,
    ),
    r'avgDailyProtein': PropertySchema(
      id: 3,
      name: r'avgDailyProtein',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dayPlans': PropertySchema(
      id: 5,
      name: r'dayPlans',
      type: IsarType.objectList,
      target: r'DayPlan',
    ),
    r'dietaryPreferences': PropertySchema(
      id: 6,
      name: r'dietaryPreferences',
      type: IsarType.stringList,
    ),
    r'endDate': PropertySchema(
      id: 7,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'excludedIngredients': PropertySchema(
      id: 8,
      name: r'excludedIngredients',
      type: IsarType.stringList,
    ),
    r'favoriteCuisines': PropertySchema(
      id: 9,
      name: r'favoriteCuisines',
      type: IsarType.stringList,
    ),
    r'healthGoals': PropertySchema(
      id: 10,
      name: r'healthGoals',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 11,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'name': PropertySchema(
      id: 12,
      name: r'name',
      type: IsarType.string,
    ),
    r'planId': PropertySchema(
      id: 13,
      name: r'planId',
      type: IsarType.string,
    ),
    r'servings': PropertySchema(
      id: 14,
      name: r'servings',
      type: IsarType.long,
    ),
    r'shoppingList': PropertySchema(
      id: 15,
      name: r'shoppingList',
      type: IsarType.objectList,
      target: r'ShoppingListItem',
    ),
    r'startDate': PropertySchema(
      id: 16,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'targetCaloriesPerDay': PropertySchema(
      id: 17,
      name: r'targetCaloriesPerDay',
      type: IsarType.long,
    ),
    r'totalCalories': PropertySchema(
      id: 18,
      name: r'totalCalories',
      type: IsarType.double,
    ),
    r'totalCarbs': PropertySchema(
      id: 19,
      name: r'totalCarbs',
      type: IsarType.double,
    ),
    r'totalFat': PropertySchema(
      id: 20,
      name: r'totalFat',
      type: IsarType.double,
    ),
    r'totalProtein': PropertySchema(
      id: 21,
      name: r'totalProtein',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 22,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(
      id: 23,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _mealPlanEstimateSize,
  serialize: _mealPlanSerialize,
  deserialize: _mealPlanDeserialize,
  deserializeProp: _mealPlanDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'startDate': IndexSchema(
      id: 7723980484494730382,
      name: r'startDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'DayPlan': DayPlanSchema,
    r'ScheduledMeal': ScheduledMealSchema,
    r'ShoppingListItem': ShoppingListItemSchema
  },
  getId: _mealPlanGetId,
  getLinks: _mealPlanGetLinks,
  attach: _mealPlanAttach,
  version: '3.1.0+1',
);

int _mealPlanEstimateSize(
  MealPlan object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dayPlans.length * 3;
  {
    final offsets = allOffsets[DayPlan]!;
    for (var i = 0; i < object.dayPlans.length; i++) {
      final value = object.dayPlans[i];
      bytesCount += DayPlanSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.dietaryPreferences.length * 3;
  {
    for (var i = 0; i < object.dietaryPreferences.length; i++) {
      final value = object.dietaryPreferences[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.excludedIngredients.length * 3;
  {
    for (var i = 0; i < object.excludedIngredients.length; i++) {
      final value = object.excludedIngredients[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.favoriteCuisines.length * 3;
  {
    for (var i = 0; i < object.favoriteCuisines.length; i++) {
      final value = object.favoriteCuisines[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.healthGoals;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.planId.length * 3;
  bytesCount += 3 + object.shoppingList.length * 3;
  {
    final offsets = allOffsets[ShoppingListItem]!;
    for (var i = 0; i < object.shoppingList.length; i++) {
      final value = object.shoppingList[i];
      bytesCount +=
          ShoppingListItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _mealPlanSerialize(
  MealPlan object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.avgDailyCalories);
  writer.writeDouble(offsets[1], object.avgDailyCarbs);
  writer.writeDouble(offsets[2], object.avgDailyFat);
  writer.writeDouble(offsets[3], object.avgDailyProtein);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeObjectList<DayPlan>(
    offsets[5],
    allOffsets,
    DayPlanSchema.serialize,
    object.dayPlans,
  );
  writer.writeStringList(offsets[6], object.dietaryPreferences);
  writer.writeDateTime(offsets[7], object.endDate);
  writer.writeStringList(offsets[8], object.excludedIngredients);
  writer.writeStringList(offsets[9], object.favoriteCuisines);
  writer.writeString(offsets[10], object.healthGoals);
  writer.writeBool(offsets[11], object.isSynced);
  writer.writeString(offsets[12], object.name);
  writer.writeString(offsets[13], object.planId);
  writer.writeLong(offsets[14], object.servings);
  writer.writeObjectList<ShoppingListItem>(
    offsets[15],
    allOffsets,
    ShoppingListItemSchema.serialize,
    object.shoppingList,
  );
  writer.writeDateTime(offsets[16], object.startDate);
  writer.writeLong(offsets[17], object.targetCaloriesPerDay);
  writer.writeDouble(offsets[18], object.totalCalories);
  writer.writeDouble(offsets[19], object.totalCarbs);
  writer.writeDouble(offsets[20], object.totalFat);
  writer.writeDouble(offsets[21], object.totalProtein);
  writer.writeDateTime(offsets[22], object.updatedAt);
  writer.writeString(offsets[23], object.userId);
}

MealPlan _mealPlanDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealPlan(
    createdAt: reader.readDateTime(offsets[4]),
    dayPlans: reader.readObjectList<DayPlan>(
          offsets[5],
          DayPlanSchema.deserialize,
          allOffsets,
          DayPlan(),
        ) ??
        [],
    dietaryPreferences: reader.readStringList(offsets[6]) ?? const [],
    endDate: reader.readDateTime(offsets[7]),
    excludedIngredients: reader.readStringList(offsets[8]) ?? const [],
    favoriteCuisines: reader.readStringList(offsets[9]) ?? const [],
    healthGoals: reader.readStringOrNull(offsets[10]),
    id: id,
    isSynced: reader.readBoolOrNull(offsets[11]) ?? false,
    name: reader.readString(offsets[12]),
    planId: reader.readString(offsets[13]),
    servings: reader.readLong(offsets[14]),
    shoppingList: reader.readObjectList<ShoppingListItem>(
          offsets[15],
          ShoppingListItemSchema.deserialize,
          allOffsets,
          ShoppingListItem(),
        ) ??
        const [],
    startDate: reader.readDateTime(offsets[16]),
    targetCaloriesPerDay: reader.readLongOrNull(offsets[17]),
    updatedAt: reader.readDateTime(offsets[22]),
    userId: reader.readString(offsets[23]),
  );
  return object;
}

P _mealPlanDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readObjectList<DayPlan>(
            offset,
            DayPlanSchema.deserialize,
            allOffsets,
            DayPlan(),
          ) ??
          []) as P;
    case 6:
      return (reader.readStringList(offset) ?? const []) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringList(offset) ?? const []) as P;
    case 9:
      return (reader.readStringList(offset) ?? const []) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readObjectList<ShoppingListItem>(
            offset,
            ShoppingListItemSchema.deserialize,
            allOffsets,
            ShoppingListItem(),
          ) ??
          const []) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readDouble(offset)) as P;
    case 21:
      return (reader.readDouble(offset)) as P;
    case 22:
      return (reader.readDateTime(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mealPlanGetId(MealPlan object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealPlanGetLinks(MealPlan object) {
  return [];
}

void _mealPlanAttach(IsarCollection<dynamic> col, Id id, MealPlan object) {
  object.id = id;
}

extension MealPlanQueryWhereSort on QueryBuilder<MealPlan, MealPlan, QWhere> {
  QueryBuilder<MealPlan, MealPlan, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhere> anyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startDate'),
      );
    });
  }
}

extension MealPlanQueryWhere on QueryBuilder<MealPlan, MealPlan, QWhereClause> {
  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> userIdNotEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> startDateEqualTo(
      DateTime startDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startDate',
        value: [startDate],
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> startDateNotEqualTo(
      DateTime startDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> startDateGreaterThan(
    DateTime startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [startDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> startDateLessThan(
    DateTime startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [],
        upper: [startDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> startDateBetween(
    DateTime lowerStartDate,
    DateTime upperStartDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [lowerStartDate],
        includeLower: includeLower,
        upper: [upperStartDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MealPlanQueryFilter
    on QueryBuilder<MealPlan, MealPlan, QFilterCondition> {
  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyCaloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgDailyCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyCaloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgDailyCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyCaloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgDailyCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyCaloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgDailyCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> avgDailyCarbsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgDailyCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyCarbsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgDailyCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> avgDailyCarbsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgDailyCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> avgDailyCarbsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgDailyCarbs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> avgDailyFatEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgDailyFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyFatGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgDailyFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> avgDailyFatLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgDailyFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> avgDailyFatBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgDailyFat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyProteinEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgDailyProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyProteinGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgDailyProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyProteinLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgDailyProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      avgDailyProteinBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgDailyProtein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dayPlansLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dayPlans',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dayPlansIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dayPlans',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dayPlansIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dayPlans',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dayPlansLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dayPlans',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dayPlansLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dayPlans',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dayPlansLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dayPlans',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietaryPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dietaryPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dietaryPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dietaryPreferences',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dietaryPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dietaryPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dietaryPreferences',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dietaryPreferences',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietaryPreferences',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dietaryPreferences',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietaryPreferences',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietaryPreferences',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietaryPreferences',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietaryPreferences',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietaryPreferences',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dietaryPreferencesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietaryPreferences',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> endDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> endDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> endDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> endDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'excludedIngredients',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'excludedIngredients',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'excludedIngredients',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'excludedIngredients',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'excludedIngredients',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'excludedIngredients',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'excludedIngredients',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'excludedIngredients',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'excludedIngredients',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'excludedIngredients',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludedIngredients',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludedIngredients',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludedIngredients',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludedIngredients',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludedIngredients',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      excludedIngredientsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'excludedIngredients',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteCuisines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'favoriteCuisines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'favoriteCuisines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'favoriteCuisines',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'favoriteCuisines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'favoriteCuisines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'favoriteCuisines',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'favoriteCuisines',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'favoriteCuisines',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'favoriteCuisines',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteCuisines',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteCuisines',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteCuisines',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteCuisines',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteCuisines',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      favoriteCuisinesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'favoriteCuisines',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'healthGoals',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      healthGoalsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'healthGoals',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthGoals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      healthGoalsGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthGoals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthGoals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthGoals',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'healthGoals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'healthGoals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'healthGoals',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'healthGoals',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> healthGoalsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthGoals',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      healthGoalsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'healthGoals',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> isSyncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'planId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> planIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> servingsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servings',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> servingsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'servings',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> servingsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'servings',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> servingsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'servings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      shoppingListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shoppingList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      shoppingListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shoppingList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      shoppingListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shoppingList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      shoppingListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shoppingList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      shoppingListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shoppingList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      shoppingListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'shoppingList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> startDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      targetCaloriesPerDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetCaloriesPerDay',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      targetCaloriesPerDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetCaloriesPerDay',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      targetCaloriesPerDayEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetCaloriesPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      targetCaloriesPerDayGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetCaloriesPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      targetCaloriesPerDayLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetCaloriesPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      targetCaloriesPerDayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetCaloriesPerDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalCaloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      totalCaloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalCaloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalCaloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalCarbsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalCarbsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalCarbsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalCarbsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCarbs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalFatEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalFatGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalFatLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalFatBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalProteinEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      totalProteinGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalProteinLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> totalProteinBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalProtein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension MealPlanQueryObject
    on QueryBuilder<MealPlan, MealPlan, QFilterCondition> {
  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dayPlansElement(
      FilterQuery<DayPlan> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'dayPlans');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> shoppingListElement(
      FilterQuery<ShoppingListItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'shoppingList');
    });
  }
}

extension MealPlanQueryLinks
    on QueryBuilder<MealPlan, MealPlan, QFilterCondition> {}

extension MealPlanQuerySortBy on QueryBuilder<MealPlan, MealPlan, QSortBy> {
  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCarbs', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCarbs', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyFat', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyFat', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByAvgDailyProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByHealthGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthGoals', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByHealthGoalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthGoals', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByServings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servings', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByServingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servings', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTargetCaloriesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCaloriesPerDay', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      sortByTargetCaloriesPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCaloriesPerDay', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbs', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbs', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByTotalProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MealPlanQuerySortThenBy
    on QueryBuilder<MealPlan, MealPlan, QSortThenBy> {
  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCarbs', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCarbs', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyFat', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyFat', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByAvgDailyProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByHealthGoals() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthGoals', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByHealthGoalsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthGoals', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByServings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servings', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByServingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servings', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTargetCaloriesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCaloriesPerDay', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      thenByTargetCaloriesPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCaloriesPerDay', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbs', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalCarbsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbs', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFat', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByTotalProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProtein', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension MealPlanQueryWhereDistinct
    on QueryBuilder<MealPlan, MealPlan, QDistinct> {
  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByAvgDailyCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgDailyCalories');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByAvgDailyCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgDailyCarbs');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByAvgDailyFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgDailyFat');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByAvgDailyProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgDailyProtein');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByDietaryPreferences() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dietaryPreferences');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByExcludedIngredients() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'excludedIngredients');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByFavoriteCuisines() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'favoriteCuisines');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByHealthGoals(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthGoals', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByPlanId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByServings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'servings');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByTargetCaloriesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetCaloriesPerDay');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByTotalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCalories');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByTotalCarbs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCarbs');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByTotalFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFat');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByTotalProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalProtein');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension MealPlanQueryProperty
    on QueryBuilder<MealPlan, MealPlan, QQueryProperty> {
  QueryBuilder<MealPlan, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> avgDailyCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgDailyCalories');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> avgDailyCarbsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgDailyCarbs');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> avgDailyFatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgDailyFat');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> avgDailyProteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgDailyProtein');
    });
  }

  QueryBuilder<MealPlan, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MealPlan, List<DayPlan>, QQueryOperations> dayPlansProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dayPlans');
    });
  }

  QueryBuilder<MealPlan, List<String>, QQueryOperations>
      dietaryPreferencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dietaryPreferences');
    });
  }

  QueryBuilder<MealPlan, DateTime, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<MealPlan, List<String>, QQueryOperations>
      excludedIngredientsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'excludedIngredients');
    });
  }

  QueryBuilder<MealPlan, List<String>, QQueryOperations>
      favoriteCuisinesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'favoriteCuisines');
    });
  }

  QueryBuilder<MealPlan, String?, QQueryOperations> healthGoalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthGoals');
    });
  }

  QueryBuilder<MealPlan, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<MealPlan, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MealPlan, String, QQueryOperations> planIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planId');
    });
  }

  QueryBuilder<MealPlan, int, QQueryOperations> servingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servings');
    });
  }

  QueryBuilder<MealPlan, List<ShoppingListItem>, QQueryOperations>
      shoppingListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shoppingList');
    });
  }

  QueryBuilder<MealPlan, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<MealPlan, int?, QQueryOperations>
      targetCaloriesPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetCaloriesPerDay');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> totalCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCalories');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> totalCarbsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCarbs');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> totalFatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFat');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> totalProteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalProtein');
    });
  }

  QueryBuilder<MealPlan, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MealPlan, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const DayPlanSchema = Schema(
  name: r'DayPlan',
  id: 1945080856968411492,
  properties: {
    r'allMeals': PropertySchema(
      id: 0,
      name: r'allMeals',
      type: IsarType.objectList,
      target: r'ScheduledMeal',
    ),
    r'breakfast': PropertySchema(
      id: 1,
      name: r'breakfast',
      type: IsarType.object,
      target: r'ScheduledMeal',
    ),
    r'dayName': PropertySchema(
      id: 2,
      name: r'dayName',
      type: IsarType.string,
    ),
    r'dinner': PropertySchema(
      id: 3,
      name: r'dinner',
      type: IsarType.object,
      target: r'ScheduledMeal',
    ),
    r'lunch': PropertySchema(
      id: 4,
      name: r'lunch',
      type: IsarType.object,
      target: r'ScheduledMeal',
    ),
    r'snacks': PropertySchema(
      id: 5,
      name: r'snacks',
      type: IsarType.objectList,
      target: r'ScheduledMeal',
    ),
    r'totalCalories': PropertySchema(
      id: 6,
      name: r'totalCalories',
      type: IsarType.double,
    ),
    r'totalCarbs': PropertySchema(
      id: 7,
      name: r'totalCarbs',
      type: IsarType.double,
    ),
    r'totalFat': PropertySchema(
      id: 8,
      name: r'totalFat',
      type: IsarType.double,
    ),
    r'totalProtein': PropertySchema(
      id: 9,
      name: r'totalProtein',
      type: IsarType.double,
    )
  },
  estimateSize: _dayPlanEstimateSize,
  serialize: _dayPlanSerialize,
  deserialize: _dayPlanDeserialize,
  deserializeProp: _dayPlanDeserializeProp,
);

int _dayPlanEstimateSize(
  DayPlan object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.allMeals.length * 3;
  {
    final offsets = allOffsets[ScheduledMeal]!;
    for (var i = 0; i < object.allMeals.length; i++) {
      final value = object.allMeals[i];
      bytesCount +=
          ScheduledMealSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.breakfast;
    if (value != null) {
      bytesCount += 3 +
          ScheduledMealSchema.estimateSize(
              value, allOffsets[ScheduledMeal]!, allOffsets);
    }
  }
  bytesCount += 3 + object.dayName.length * 3;
  {
    final value = object.dinner;
    if (value != null) {
      bytesCount += 3 +
          ScheduledMealSchema.estimateSize(
              value, allOffsets[ScheduledMeal]!, allOffsets);
    }
  }
  {
    final value = object.lunch;
    if (value != null) {
      bytesCount += 3 +
          ScheduledMealSchema.estimateSize(
              value, allOffsets[ScheduledMeal]!, allOffsets);
    }
  }
  bytesCount += 3 + object.snacks.length * 3;
  {
    final offsets = allOffsets[ScheduledMeal]!;
    for (var i = 0; i < object.snacks.length; i++) {
      final value = object.snacks[i];
      bytesCount +=
          ScheduledMealSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _dayPlanSerialize(
  DayPlan object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<ScheduledMeal>(
    offsets[0],
    allOffsets,
    ScheduledMealSchema.serialize,
    object.allMeals,
  );
  writer.writeObject<ScheduledMeal>(
    offsets[1],
    allOffsets,
    ScheduledMealSchema.serialize,
    object.breakfast,
  );
  writer.writeString(offsets[2], object.dayName);
  writer.writeObject<ScheduledMeal>(
    offsets[3],
    allOffsets,
    ScheduledMealSchema.serialize,
    object.dinner,
  );
  writer.writeObject<ScheduledMeal>(
    offsets[4],
    allOffsets,
    ScheduledMealSchema.serialize,
    object.lunch,
  );
  writer.writeObjectList<ScheduledMeal>(
    offsets[5],
    allOffsets,
    ScheduledMealSchema.serialize,
    object.snacks,
  );
  writer.writeDouble(offsets[6], object.totalCalories);
  writer.writeDouble(offsets[7], object.totalCarbs);
  writer.writeDouble(offsets[8], object.totalFat);
  writer.writeDouble(offsets[9], object.totalProtein);
}

DayPlan _dayPlanDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DayPlan();
  object.breakfast = reader.readObjectOrNull<ScheduledMeal>(
    offsets[1],
    ScheduledMealSchema.deserialize,
    allOffsets,
  );
  object.dayName = reader.readString(offsets[2]);
  object.dinner = reader.readObjectOrNull<ScheduledMeal>(
    offsets[3],
    ScheduledMealSchema.deserialize,
    allOffsets,
  );
  object.lunch = reader.readObjectOrNull<ScheduledMeal>(
    offsets[4],
    ScheduledMealSchema.deserialize,
    allOffsets,
  );
  object.snacks = reader.readObjectList<ScheduledMeal>(
        offsets[5],
        ScheduledMealSchema.deserialize,
        allOffsets,
        ScheduledMeal(),
      ) ??
      [];
  return object;
}

P _dayPlanDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<ScheduledMeal>(
            offset,
            ScheduledMealSchema.deserialize,
            allOffsets,
            ScheduledMeal(),
          ) ??
          []) as P;
    case 1:
      return (reader.readObjectOrNull<ScheduledMeal>(
        offset,
        ScheduledMealSchema.deserialize,
        allOffsets,
      )) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readObjectOrNull<ScheduledMeal>(
        offset,
        ScheduledMealSchema.deserialize,
        allOffsets,
      )) as P;
    case 4:
      return (reader.readObjectOrNull<ScheduledMeal>(
        offset,
        ScheduledMealSchema.deserialize,
        allOffsets,
      )) as P;
    case 5:
      return (reader.readObjectList<ScheduledMeal>(
            offset,
            ScheduledMealSchema.deserialize,
            allOffsets,
            ScheduledMeal(),
          ) ??
          []) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension DayPlanQueryFilter
    on QueryBuilder<DayPlan, DayPlan, QFilterCondition> {
  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> allMealsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allMeals',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> allMealsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allMeals',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> allMealsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allMeals',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> allMealsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allMeals',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition>
      allMealsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allMeals',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> allMealsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allMeals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> breakfastIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'breakfast',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> breakfastIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'breakfast',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayName',
        value: '',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dayName',
        value: '',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dinnerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dinner',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dinnerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dinner',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> lunchIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lunch',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> lunchIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lunch',
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> snacksLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snacks',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> snacksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snacks',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> snacksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snacks',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> snacksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snacks',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> snacksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snacks',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> snacksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'snacks',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalCaloriesEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition>
      totalCaloriesGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalCaloriesLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalCaloriesBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalCarbsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalCarbsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalCarbsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalCarbsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCarbs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalFatEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalFatGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalFatLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalFatBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalProteinEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalProteinGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalProteinLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> totalProteinBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalProtein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension DayPlanQueryObject
    on QueryBuilder<DayPlan, DayPlan, QFilterCondition> {
  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> allMealsElement(
      FilterQuery<ScheduledMeal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'allMeals');
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> breakfast(
      FilterQuery<ScheduledMeal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'breakfast');
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> dinner(
      FilterQuery<ScheduledMeal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'dinner');
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> lunch(
      FilterQuery<ScheduledMeal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'lunch');
    });
  }

  QueryBuilder<DayPlan, DayPlan, QAfterFilterCondition> snacksElement(
      FilterQuery<ScheduledMeal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'snacks');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ScheduledMealSchema = Schema(
  name: r'ScheduledMeal',
  id: -5480257454325436488,
  properties: {
    r'dishEmoji': PropertySchema(
      id: 0,
      name: r'dishEmoji',
      type: IsarType.string,
    ),
    r'ingredientNames': PropertySchema(
      id: 1,
      name: r'ingredientNames',
      type: IsarType.stringList,
    ),
    r'mealId': PropertySchema(
      id: 2,
      name: r'mealId',
      type: IsarType.string,
    ),
    r'mealType': PropertySchema(
      id: 3,
      name: r'mealType',
      type: IsarType.byte,
      enumMap: _ScheduledMealmealTypeEnumValueMap,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'recipeSource': PropertySchema(
      id: 5,
      name: r'recipeSource',
      type: IsarType.string,
    ),
    r'servings': PropertySchema(
      id: 6,
      name: r'servings',
      type: IsarType.long,
    ),
    r'totalCalories': PropertySchema(
      id: 7,
      name: r'totalCalories',
      type: IsarType.double,
    ),
    r'totalCarbs': PropertySchema(
      id: 8,
      name: r'totalCarbs',
      type: IsarType.double,
    ),
    r'totalFat': PropertySchema(
      id: 9,
      name: r'totalFat',
      type: IsarType.double,
    ),
    r'totalProtein': PropertySchema(
      id: 10,
      name: r'totalProtein',
      type: IsarType.double,
    ),
    r'steps': PropertySchema(
      id: 11,
      name: r'steps',
      type: IsarType.objectList,
      target: r'RecipeStep',
    ),
    r'totalFiber': PropertySchema(
      id: 12,
      name: r'totalFiber',
      type: IsarType.double,
    ),
    r'totalSodium': PropertySchema(
      id: 13,
      name: r'totalSodium',
      type: IsarType.double,
    ),
    r'totalSugar': PropertySchema(
      id: 14,
      name: r'totalSugar',
      type: IsarType.double,
    )
  },
  estimateSize: _scheduledMealEstimateSize,
  serialize: _scheduledMealSerialize,
  deserialize: _scheduledMealDeserialize,
  deserializeProp: _scheduledMealDeserializeProp,
);

int _scheduledMealEstimateSize(
  ScheduledMeal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.dishEmoji;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.ingredientNames;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.mealId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.recipeSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.steps.length * 3;
  {
    final offsets = allOffsets[RecipeStep]!;
    for (var i = 0; i < object.steps.length; i++) {
      final value = object.steps[i];
      bytesCount += RecipeStepSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _scheduledMealSerialize(
  ScheduledMeal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.dishEmoji);
  writer.writeStringList(offsets[1], object.ingredientNames);
  writer.writeString(offsets[2], object.mealId);
  writer.writeByte(offsets[3], object.mealType.index);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.recipeSource);
  writer.writeLong(offsets[6], object.servings);
  writer.writeDouble(offsets[7], object.totalCalories);
  writer.writeDouble(offsets[8], object.totalCarbs);
  writer.writeDouble(offsets[9], object.totalFat);
  writer.writeDouble(offsets[10], object.totalProtein);
  writer.writeObjectList<RecipeStep>(
    offsets[11],
    allOffsets,
    RecipeStepSchema.serialize,
    object.steps,
  );
  writer.writeDouble(offsets[12], object.totalFiber);
  writer.writeDouble(offsets[13], object.totalSodium);
  writer.writeDouble(offsets[14], object.totalSugar);
}

ScheduledMeal _scheduledMealDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScheduledMeal(
    dishEmoji: reader.readStringOrNull(offsets[0]),
    ingredientNames: reader.readStringList(offsets[1]),
    mealId: reader.readStringOrNull(offsets[2]) ?? '',
    mealType:
        _ScheduledMealmealTypeValueEnumMap[reader.readByteOrNull(offsets[3])] ??
            MealType.snack,
    name: reader.readStringOrNull(offsets[4]) ?? '',
    recipeSource: reader.readStringOrNull(offsets[5]),
    servings: reader.readLongOrNull(offsets[6]) ?? 1,
    totalCalories: reader.readDoubleOrNull(offsets[7]),
    totalCarbs: reader.readDoubleOrNull(offsets[8]),
    totalFat: reader.readDoubleOrNull(offsets[9]),
    totalProtein: reader.readDoubleOrNull(offsets[10]),
    steps: reader.readObjectList<RecipeStep>(
          offsets[11],
          RecipeStepSchema.deserialize,
          allOffsets,
          RecipeStep(),
        ) ??
        [],
    totalFiber: reader.readDoubleOrNull(offsets[12]),
    totalSodium: reader.readDoubleOrNull(offsets[13]),
    totalSugar: reader.readDoubleOrNull(offsets[14]),
  );
  return object;
}

P _scheduledMealDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 3:
      return (_ScheduledMealmealTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MealType.snack) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readObjectList<RecipeStep>(
            offset,
            RecipeStepSchema.deserialize,
            allOffsets,
            RecipeStep(),
          ) ??
          []) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ScheduledMealmealTypeEnumValueMap = {
  'breakfast': 0,
  'lunch': 1,
  'dinner': 2,
  'snack': 3,
};
const _ScheduledMealmealTypeValueEnumMap = {
  0: MealType.breakfast,
  1: MealType.lunch,
  2: MealType.dinner,
  3: MealType.snack,
};

extension ScheduledMealQueryFilter
    on QueryBuilder<ScheduledMeal, ScheduledMeal, QFilterCondition> {
  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dishEmoji',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dishEmoji',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dishEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dishEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dishEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dishEmoji',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dishEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dishEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dishEmoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dishEmoji',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dishEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      dishEmojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dishEmoji',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ingredientNames',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ingredientNames',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ingredientNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ingredientNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ingredientNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ingredientNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ingredientNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ingredientNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ingredientNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientNames',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ingredientNames',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      ingredientNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealTypeEqualTo(MealType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealTypeGreaterThan(
    MealType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealTypeLessThan(
    MealType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealType',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      mealTypeBetween(
    MealType lower,
    MealType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recipeSource',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recipeSource',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipeSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipeSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipeSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipeSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipeSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipeSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipeSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipeSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipeSource',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      recipeSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipeSource',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      servingsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'servings',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      servingsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'servings',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      servingsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'servings',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      servingsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'servings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCaloriesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalCalories',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCaloriesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalCalories',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCaloriesEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCaloriesGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCaloriesLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCalories',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCaloriesBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCarbsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalCarbs',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCarbsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalCarbs',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCarbsEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCarbsGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCarbsLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCarbs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalCarbsBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCarbs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalFatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalFat',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalFatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalFat',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalFatEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalFatGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalFatLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalFatBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalProteinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'totalProtein',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalProteinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'totalProtein',
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalProteinEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalProteinGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalProteinLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalProtein',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScheduledMeal, ScheduledMeal, QAfterFilterCondition>
      totalProteinBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalProtein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ScheduledMealQueryObject
    on QueryBuilder<ScheduledMeal, ScheduledMeal, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ShoppingListItemSchema = Schema(
  name: r'ShoppingListItem',
  id: -3816175988203906805,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'emoji': PropertySchema(
      id: 1,
      name: r'emoji',
      type: IsarType.string,
    ),
    r'isChecked': PropertySchema(
      id: 2,
      name: r'isChecked',
      type: IsarType.bool,
    ),
    r'mealNames': PropertySchema(
      id: 3,
      name: r'mealNames',
      type: IsarType.stringList,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 5,
      name: r'quantity',
      type: IsarType.double,
    ),
    r'unit': PropertySchema(
      id: 6,
      name: r'unit',
      type: IsarType.string,
    )
  },
  estimateSize: _shoppingListItemEstimateSize,
  serialize: _shoppingListItemSerialize,
  deserialize: _shoppingListItemDeserialize,
  deserializeProp: _shoppingListItemDeserializeProp,
);

int _shoppingListItemEstimateSize(
  ShoppingListItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.category;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.emoji;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.mealNames;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.unit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _shoppingListItemSerialize(
  ShoppingListItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeString(offsets[1], object.emoji);
  writer.writeBool(offsets[2], object.isChecked);
  writer.writeStringList(offsets[3], object.mealNames);
  writer.writeString(offsets[4], object.name);
  writer.writeDouble(offsets[5], object.quantity);
  writer.writeString(offsets[6], object.unit);
}

ShoppingListItem _shoppingListItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ShoppingListItem(
    category: reader.readStringOrNull(offsets[0]),
    emoji: reader.readStringOrNull(offsets[1]),
    isChecked: reader.readBoolOrNull(offsets[2]) ?? false,
    mealNames: reader.readStringList(offsets[3]),
    name: reader.readStringOrNull(offsets[4]) ?? '',
    quantity: reader.readDoubleOrNull(offsets[5]) ?? 0,
    unit: reader.readStringOrNull(offsets[6]),
  );
  return object;
}

P _shoppingListItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 5:
      return (reader.readDoubleOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ShoppingListItemQueryFilter
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QFilterCondition> {
  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emoji',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emoji',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emoji',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emoji',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emoji',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emoji',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      emojiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emoji',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      isCheckedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isChecked',
        value: value,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mealNames',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mealNames',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealNames',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealNames',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      mealNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mealNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      quantityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      quantityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      quantityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      quantityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<ShoppingListItem, ShoppingListItem, QAfterFilterCondition>
      unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }
}

extension ShoppingListItemQueryObject
    on QueryBuilder<ShoppingListItem, ShoppingListItem, QFilterCondition> {}
