import '../../../features/notes/domain/category.dart';
import '../../../core/theme/category_palette.dart';
import '../../../core/theme/icon_registry.dart';
import '../database.dart';

class CategoriesDao {
  final AppDatabase _db;

  CategoriesDao(this._db);

  Future<List<Category>> getAll() async {
    final rows = await _db.select(_db.categories).get();
    return rows.map(_toCategory).toList();
  }

  Stream<List<Category>> watchAll() {
    return _db.select(_db.categories).watch().map(
          (rows) => rows.map(_toCategory).toList(),
        );
  }

  Future<Category?> getById(int id) async {
    final row = await (_db.select(_db.categories)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toCategory(row) : null;
  }

  Future<Category?> getByName(String name) async {
    final row = await (_db.select(_db.categories)
          ..where((t) => t.name.equals(name.toLowerCase())))
        .getSingleOrNull();
    return row != null ? _toCategory(row) : null;
  }

  Future<Category> getOrCreateCategory(String name) async {
    final normalized =
        name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final existing = await getByName(normalized);
    if (existing != null) return existing;

    final displayName =
        name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');
    final color = CategoryPalette.colorForName(normalized);

    final id = await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: normalized,
            displayName: displayName,
            colorValue: color.toARGB32(),
            iconName: 'note',
          ),
        );

    return Category(
      id: id,
      name: normalized,
      displayName: displayName,
      color: color,
      icon: IconRegistry.fromName('note'),
      isDefault: false,
    );
  }

  Category _toCategory(CategoryRow row) {
    return Category.fromDb(
      id: row.id,
      name: row.name,
      displayName: row.displayName,
      colorValue: row.colorValue,
      iconName: row.iconName,
      isDefault: row.isDefault,
    );
  }
}
