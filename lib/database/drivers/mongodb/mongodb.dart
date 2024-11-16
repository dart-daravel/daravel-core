import 'package:collection/collection.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:daravel_core/config/database_connection.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/mongodb/mongodb_record_set.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:daravel_core/database/schema/blueprint.dart';
import 'package:daravel_core/extensions/string.dart';

class MongoDBDriver extends DBDriver {
  late final Db? _db;

  late final DatabaseConnection _configuration;

  /// Initialize the MongoDB driver
  MongoDBDriver(DatabaseConnection connection) {
    _db = Db(connection.dsn != null
        ? '${connection.dsn!.rtrim('/')}/${connection.database}'
        : 'mongodb://localhost:27017');
    _db!.open();
    _configuration = connection;
  }

  @override
  bool get logging => _configuration.queryLog;

  /// Run a select statement
  @override
  Future<RecordSet> select(String collection,
      [Object query = const {}, ORM? orm]) async {
    if (query is NoSqlQuery) {
      final result = await _db!
          .collection(collection)
          .find(_buildQuery(collection, query))
          .toList();
      return MongodbRecordSet(result, orm);
    } else {
      throw ArgumentError('Query must be of type NoSqlQuery');
    }
  }

  /// Run a delete query
  /// Throws [ArgumentError] if length of [bindings] is not equal number of
  /// placeholders in query.
  @override
  Future<int> delete(String query, [List bindings = const []]) =>
      throw UnimplementedError();

  /// Run an insert query.
  /// Throws [ArgumentError] if length of [bindings] is not equal number of
  /// placeholders in query.
  @override
  bool insert(String query, [List bindings = const []]) =>
      throw UnimplementedError();

  @override
  Future<int> insertGetId(String query, [List bindings = const []]) =>
      throw UnimplementedError();

  /// Run an SQL statement.
  @override
  bool statement(String query, [List bindings = const []]) =>
      throw UnimplementedError();

  /// Run an unprepared query.
  @override
  bool unprepared(String query) => throw UnimplementedError();

  /// Run an update query.
  @override
  Future<int> update(String query, [List bindings = const []]) async =>
      throw UnimplementedError();

  @override
  String executeBlueprint(Blueprint blueprint) => throw UnimplementedError();

  @override
  Blueprint initBlueprint(String name, bool modify) =>
      throw UnimplementedError();

  @override
  String drop(String table) => throw UnimplementedError();

  @override
  String dropIfExists(String table) => throw UnimplementedError();

  @override
  String renameTable(String from, String to) => throw UnimplementedError();

  @override
  QueryBuilder queryBuilder([String? table, ORM? orm]) =>
      throw UnimplementedError();

  Map<String, Object> _buildQuery(String collection, NoSqlQuery query) {
    final SelectorBuilder andWhereBuilder = where;
    final SelectorBuilder orWhereBuilder = where;
    final List<Map<String, Object?>> groupedWhereBuilder = [];
    int groupDepth = 0;
    Map<String, Object?>? lastGroupedWhereBuilder;
    Map<String, Object?>? lastGroupedOrWhereBuilder;

    if (query.whereClauses != null) {
      for (final clause in query.whereClauses!) {
        if (clause.isOpenBracket) {
          ++groupDepth;
          if (clause.concatenator == 'AND') {
            lastGroupedWhereBuilder = {
              'concatenator': clause.concatenator,
              'builder': where,
              'depth': groupDepth,
              'concatenator_trail':
                  '${lastGroupedWhereBuilder?['concatenator_trail'] ?? ''}${lastGroupedWhereBuilder?['concatenator_trail'] != null ? ',' : ''}${lastGroupedWhereBuilder?['concatenator']}',
            };
            groupedWhereBuilder.add(lastGroupedWhereBuilder);
          } else if (clause.concatenator == 'OR') {
            lastGroupedOrWhereBuilder = {
              'concatenator': clause.concatenator,
              'builder': where,
              'depth': groupDepth,
              'concatenator_trail':
                  '${lastGroupedOrWhereBuilder?['concatenator_trail'] ?? ''}${lastGroupedOrWhereBuilder?['concatenator_trail'] != null ? ',' : ''}${lastGroupedOrWhereBuilder?['concatenator']}',
            };
            groupedWhereBuilder.add(lastGroupedOrWhereBuilder);
          }
          continue;
        } else if (clause.isCloseBracket) {
          --groupDepth;
          lastGroupedWhereBuilder = null;
          lastGroupedOrWhereBuilder = null;
          for (int x = groupedWhereBuilder.length - 1; x > -1; x--) {
            if (groupedWhereBuilder[x]['depth'] == groupDepth) {
              if (groupedWhereBuilder[x]['concatenator'] == 'AND' &&
                  lastGroupedWhereBuilder == null) {
                lastGroupedWhereBuilder = groupedWhereBuilder[x];
                continue;
              } else if (groupedWhereBuilder[x]['concatenator'] == 'OR' &&
                  lastGroupedOrWhereBuilder == null) {
                lastGroupedOrWhereBuilder = groupedWhereBuilder[x];
                continue;
              }
            }
          }
          continue;
        } else if (clause.concatenator == 'AND') {
          if (lastGroupedWhereBuilder != null) {
            _buildClauseByOperator(
                clause.column!,
                clause.value,
                clause.operator!,
                lastGroupedWhereBuilder['builder'] as SelectorBuilder);
          } else {
            _buildClauseByOperator(clause.column!, clause.value,
                clause.operator!, andWhereBuilder);
          }
        } else if (clause.concatenator == 'OR') {
          if (lastGroupedOrWhereBuilder != null) {
            _buildClauseByOperator(
                clause.column!,
                clause.value,
                clause.operator!,
                lastGroupedOrWhereBuilder['builder'] as SelectorBuilder);
          } else {
            _buildClauseByOperator(
                clause.column!, clause.value, clause.operator!, orWhereBuilder);
          }
        }
      }
    }

    final Map<String, Object> preparedQuery = {};

    if ((query.selectFields ?? []).isNotEmpty) {
      final builder = SelectorBuilder()..fields(query.selectFields!);
      preparedQuery.addAll(builder.map as Map<String, Object>);
    }

    if (andWhereBuilder.map.isNotEmpty) {
      preparedQuery['\$and'] = andWhereBuilder.map;
    }
    if (orWhereBuilder.map.isNotEmpty) {
      preparedQuery['\$or'] = orWhereBuilder.map;
    }

    Map<String, Object> targetMap = {};

    for (final query in groupedWhereBuilder) {
      targetMap = _getNestedTargetMap(
          preparedQuery, query['concatenator_trail'] as String);
      targetMap[_sqlToBsonConcatenator(query['concatenator'] as String)] =
          (query['builder'] as SelectorBuilder).map;
    }

    return preparedQuery;
  }

  Map<String, Object> _getNestedTargetMap(
      Map<String, Object> preparedQuery, String concatenatorTrail,
      [bool createArray = true]) {
    Map<String, Object> targetMap = preparedQuery;
    final List<String> concatenatorTrailParts = concatenatorTrail.split(',');
    concatenatorTrailParts.forEachIndexed((index, part) {
      if (index == concatenatorTrail.length - 1) {
        return;
      }
      if (targetMap[_sqlToBsonConcatenator(part)] == null) {
        preparedQuery[_sqlToBsonConcatenator(part)] = createArray ? [] : {};
        targetMap =
            preparedQuery[_sqlToBsonConcatenator(part)] as Map<String, Object>;
      } else {
        targetMap =
            targetMap[_sqlToBsonConcatenator(part)] as Map<String, Object>;
      }
    });
    return targetMap;
  }

  String _sqlToBsonConcatenator(String concatenator) {
    switch (concatenator) {
      case 'AND':
        return '\$and';
      case 'OR':
        return '\$or';
      case 'NOT':
        return '\$not';
      case 'NOR':
        return '\$nor';
      default:
        return '\$and';
    }
  }

  SelectorBuilder _buildClauseByOperator(
      String field, String value, String operator, SelectorBuilder builder) {
    switch (operator) {
      case '>':
        return builder.gt(field, value);
      default:
        return builder.eq(field, value);
    }
  }
}
