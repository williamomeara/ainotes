import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/daos/categories_dao.dart';
import '../domain/category.dart';

final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  return CategoriesDao(ref.watch(databaseProvider));
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesDaoProvider).watchAll();
});

final categoriesMapProvider = Provider<Map<int, Category>>((ref) {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  return {for (final c in categories) c.id: c};
});
