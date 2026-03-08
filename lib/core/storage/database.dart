import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get displayName => text()();
  IntColumn get colorValue => integer()();
  TextColumn get iconName => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get originalText => text()();
  TextColumn get rewrittenText => text()();
  IntColumn get categoryId =>
      integer().references(Categories, #id)();
  RealColumn get confidence => real().withDefault(const Constant(0.0))();
  TextColumn get source => text().withDefault(const Constant('text'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get audioDurationSeconds => integer().nullable()();
  BoolColumn get isDraft =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('NoteTagRow')
class NoteTags extends Table {
  TextColumn get noteId =>
      text().references(Notes, #id)();
  IntColumn get tagId =>
      integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

@DataClassName('NoteChunkRow')
class NoteChunks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get chunkIndex => integer()();
  TextColumn get chunkText => text()();
  BlobColumn get embedding => blob()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {noteId, chunkIndex}
      ];
}

@DriftDatabase(tables: [Categories, Notes, Tags, NoteTags, NoteChunks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'ainotes'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultCategories();
        },
      );

  Future<void> _seedDefaultCategories() async {
    await batch((b) {
      b.insertAll(categories, [
        CategoriesCompanion.insert(
          name: 'shopping',
          displayName: 'Shopping',
          colorValue: 0xFF22C55E,
          iconName: 'shopping_cart',
          isDefault: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'todos',
          displayName: 'Todos',
          colorValue: 0xFF3B82F6,
          iconName: 'check_circle',
          isDefault: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'ideas',
          displayName: 'Ideas',
          colorValue: 0xFFA855F7,
          iconName: 'lightbulb',
          isDefault: const Value(true),
        ),
        CategoriesCompanion.insert(
          name: 'general',
          displayName: 'General',
          colorValue: 0xFF6B7280,
          iconName: 'note',
          isDefault: const Value(true),
        ),
      ]);
    });
  }
}
