// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarked.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookmarkedCollection on Isar {
  IsarCollection<Bookmarked> get bookmarkeds => this.collection();
}

const BookmarkedSchema = CollectionSchema(
  name: r'Bookmarked',
  id: -7157465591905490875,
  properties: {
    r'pluginId': PropertySchema(
      id: 0,
      name: r'pluginId',
      type: IsarType.string,
    ),
    r'routeId': PropertySchema(
      id: 1,
      name: r'routeId',
      type: IsarType.string,
    ),
    r'stopId': PropertySchema(
      id: 2,
      name: r'stopId',
      type: IsarType.string,
    )
  },
  estimateSize: _bookmarkedEstimateSize,
  serialize: _bookmarkedSerialize,
  deserialize: _bookmarkedDeserialize,
  deserializeProp: _bookmarkedDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {
    r'bookmarks': LinkSchema(
      id: 7158601245994154636,
      name: r'bookmarks',
      target: r'Bookmark',
      single: false,
      linkName: r'bookmarkeds',
    )
  },
  embeddedSchemas: {},
  getId: _bookmarkedGetId,
  getLinks: _bookmarkedGetLinks,
  attach: _bookmarkedAttach,
  version: '3.1.8',
);

int _bookmarkedEstimateSize(
  Bookmarked object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.pluginId.length * 3;
  bytesCount += 3 + object.routeId.length * 3;
  bytesCount += 3 + object.stopId.length * 3;
  return bytesCount;
}

void _bookmarkedSerialize(
  Bookmarked object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.pluginId);
  writer.writeString(offsets[1], object.routeId);
  writer.writeString(offsets[2], object.stopId);
}

Bookmarked _bookmarkedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Bookmarked(
    pluginId: reader.readString(offsets[0]),
    routeId: reader.readString(offsets[1]),
    stopId: reader.readString(offsets[2]),
  );
  return object;
}

P _bookmarkedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bookmarkedGetId(Bookmarked object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _bookmarkedGetLinks(Bookmarked object) {
  return [object.bookmarks];
}

void _bookmarkedAttach(IsarCollection<dynamic> col, Id id, Bookmarked object) {
  object.bookmarks
      .attach(col, col.isar.collection<Bookmark>(), r'bookmarks', id);
}

extension BookmarkedQueryWhereSort
    on QueryBuilder<Bookmarked, Bookmarked, QWhere> {
  QueryBuilder<Bookmarked, Bookmarked, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookmarkedQueryWhere
    on QueryBuilder<Bookmarked, Bookmarked, QWhereClause> {
  QueryBuilder<Bookmarked, Bookmarked, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BookmarkedQueryFilter
    on QueryBuilder<Bookmarked, Bookmarked, QFilterCondition> {
  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> pluginIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pluginId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      pluginIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pluginId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> pluginIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pluginId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> pluginIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pluginId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      pluginIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pluginId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> pluginIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pluginId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> pluginIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pluginId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> pluginIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pluginId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      pluginIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pluginId',
        value: '',
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      pluginIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pluginId',
        value: '',
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      routeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'routeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> routeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeId',
        value: '',
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      routeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'routeId',
        value: '',
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stopId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stopId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stopId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stopId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stopId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stopId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stopId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stopId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> stopIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stopId',
        value: '',
      ));
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      stopIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stopId',
        value: '',
      ));
    });
  }
}

extension BookmarkedQueryObject
    on QueryBuilder<Bookmarked, Bookmarked, QFilterCondition> {}

extension BookmarkedQueryLinks
    on QueryBuilder<Bookmarked, Bookmarked, QFilterCondition> {
  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition> bookmarks(
      FilterQuery<Bookmark> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'bookmarks');
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      bookmarksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'bookmarks', length, true, length, true);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      bookmarksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'bookmarks', 0, true, 0, true);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      bookmarksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'bookmarks', 0, false, 999999, true);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      bookmarksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'bookmarks', 0, true, length, include);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      bookmarksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'bookmarks', length, include, 999999, true);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterFilterCondition>
      bookmarksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'bookmarks', lower, includeLower, upper, includeUpper);
    });
  }
}

extension BookmarkedQuerySortBy
    on QueryBuilder<Bookmarked, Bookmarked, QSortBy> {
  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> sortByPluginId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluginId', Sort.asc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> sortByPluginIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluginId', Sort.desc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> sortByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> sortByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> sortByStopId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopId', Sort.asc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> sortByStopIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopId', Sort.desc);
    });
  }
}

extension BookmarkedQuerySortThenBy
    on QueryBuilder<Bookmarked, Bookmarked, QSortThenBy> {
  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByPluginId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluginId', Sort.asc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByPluginIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pluginId', Sort.desc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByStopId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopId', Sort.asc);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QAfterSortBy> thenByStopIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stopId', Sort.desc);
    });
  }
}

extension BookmarkedQueryWhereDistinct
    on QueryBuilder<Bookmarked, Bookmarked, QDistinct> {
  QueryBuilder<Bookmarked, Bookmarked, QDistinct> distinctByPluginId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pluginId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QDistinct> distinctByRouteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Bookmarked, Bookmarked, QDistinct> distinctByStopId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stopId', caseSensitive: caseSensitive);
    });
  }
}

extension BookmarkedQueryProperty
    on QueryBuilder<Bookmarked, Bookmarked, QQueryProperty> {
  QueryBuilder<Bookmarked, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<Bookmarked, String, QQueryOperations> pluginIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pluginId');
    });
  }

  QueryBuilder<Bookmarked, String, QQueryOperations> routeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeId');
    });
  }

  QueryBuilder<Bookmarked, String, QQueryOperations> stopIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stopId');
    });
  }
}
