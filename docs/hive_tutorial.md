# Hive in Flutter — Tutorial & Implementation Guide

This doc explains what Hive is, why (and when) to use it, its trade-offs, and
a full walkthrough of adding it to this project (`blog_diego`) to cache blog
data locally alongside the existing Supabase remote data source.

---

## 1. What is Hive?

[Hive](https://pub.dev/packages/hive) is a lightweight, **NoSQL key-value
database** written in pure Dart. It stores data in binary "boxes" on disk and
requires no native dependencies (no SQLite, no platform channels), which is
why it's popular in Flutter apps for local persistence, caching, and offline
support.

Two common flavors:

- `hive` + `hive_flutter` — the classic package.
- `hive_ce` (Community Edition) — a maintained fork, recommended today since
  the original `hive`/`hive_generator` packages are no longer actively
  maintained by their original author. If starting fresh, prefer `hive_ce` +
  `hive_ce_generator`.

## 2. Why use Hive (in this project)?

This app already talks to Supabase for blogs (`lib/feature/blog/data`) and
auth (`lib/feature/auth/data`). Hive fits in as the **local
cache/offline layer**, sitting behind the repository, following the same
Data Source pattern already used here (`AuthRemoteDataSource` /
`AuthLocalDataSource`-style split).

Good reasons to reach for Hive specifically:

- **Offline-first UX**: show the last-fetched list of blogs immediately while
  a fresh Supabase call happens in the background.
- **Caching the current user**: avoid re-fetching `currentUser()` from
  Supabase on every app start (this project already keeps an in-memory
  `AppUserCubit`; Hive would make that survive app restarts).
- **No native setup**: unlike `sqflite` or `drift`, there's no SQL, no
  platform-specific build step — just Dart.
- **Speed**: reads/writes are fast because Hive keeps data in memory and
  flushes to disk, avoiding SQL parsing/query planning overhead entirely.
- **Simple mental model**: a `Box` behaves like a persistent `Map<key, value>`.

## 3. Advantages

| Advantage | Detail |
|---|---|
| **Pure Dart, no native code** | Works on all Flutter platforms (iOS, Android, web, desktop) without platform channels. |
| **Fast** | Frequently benchmarked faster than SQLite-based solutions for simple key-value access patterns. |
| **Simple API** | `box.put(key, value)`, `box.get(key)` — no SQL, no schema migrations to hand-write. |
| **Type-safe objects** | With code generation (`@HiveType`/`@HiveField`), you store real Dart objects, not just JSON maps. |
| **Encryption support** | Built-in AES-256 encrypted boxes for sensitive data. |
| **No async needed for reads** | Once a box is open, `.get()` is synchronous — great for widget `build()` methods. |
| **Small footprint** | No heavyweight native DB engine bundled into the app. |

## 4. Disadvantages / Limitations

| Disadvantage | Detail |
|---|---|
| **No real querying** | No SQL `WHERE`/`JOIN`/aggregate support. Filtering means loading a box and iterating in Dart. Bad fit for complex relational data. |
| **No built-in migrations** | Changing a `HiveType`'s fields (adding/removing/reordering) can silently corrupt or misread existing stored data if not done carefully (you must only add fields at the end, never reuse/reorder `typeId`/field indices). |
| **Maintenance risk** | The original `hive` package is effectively unmaintained — mitigated by using the `hive_ce` community fork instead. |
| **All-in-memory per box** | A box's data lives in memory while open, so it's not ideal for very large datasets (thousands+ of large records). |
| **Manual adapter registration** | Every custom type needs a generated `TypeAdapter` registered before use — one more thing to remember when adding models. |
| **No multi-isolate write safety out of the box** | Concurrent writes from multiple isolates need care (e.g. via `hive_ce` + proper box management). |
| **Not relational** | If your data has many foreign-key-like relationships, a proper SQL DB (`drift`, `sqflite`) or ORM will serve you better long-term. |

### When to prefer something else

- Complex relational queries, joins, transactions → **Drift** (SQLite-based, type-safe, has migrations).
- You want to keep using SQL directly → **sqflite**.
- You just need a handful of primitive key/value settings (not objects) → **shared_preferences** is simpler.
- You need multi-user, multi-device sync → your backend (Supabase already provides this here) — Hive is a *cache*, not a source of truth.

## 5. Installation

Add dependencies (using the maintained `hive_ce` fork):

```yaml
# pubspec.yaml
dependencies:
  hive_ce: ^2.10.0
  hive_ce_flutter: ^2.2.0

dev_dependencies:
  hive_ce_generator: ^1.7.0
  build_runner: ^2.4.13
```

Then:

```bash
flutter pub get
```

> If you'd rather use the original packages, swap in `hive: ^2.2.3`,
> `hive_flutter: ^1.1.0`, `hive_generator: ^2.0.1` — the API shown below is
> the same either way, only the import/package names differ.

## 6. Initializing Hive

Initialize once, in `main.dart`, before `runApp`:

```dart
// lib/main.dart
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // sets up a per-platform storage directory

  Hive.registerAdapter(BlogEntityAdapter()); // generated adapter, see below

  await Hive.openBox<BlogHiveModel>('blogs');

  // ...existing init (Supabase, get_it, dotenv, etc.)
  runApp(const MyApp());
}
```

In a `get_it`-based project like this one, register the opened box(es) as
lazy singletons in your service locator (e.g. `lib/core/common/...` init
function), so data sources can retrieve them via `serviceLocator<Box<...>>()`.

## 7. Defining a Hive model

Following this project's `feature/blog/data` layer, add a Hive-annotated
model next to the existing remote model:

```dart
// lib/feature/blog/data/models/blog_hive_model.dart
import 'package:hive_ce/hive.dart';

part 'blog_hive_model.g.dart';

@HiveType(typeId: 0)
class BlogHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String posterId;

  @HiveField(4)
  final DateTime updatedAt;

  BlogHiveModel({
    required this.id,
    required this.title,
    required this.content,
    required this.posterId,
    required this.updatedAt,
  });
}
```

Generate the adapter:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This produces `blog_hive_model.g.dart` containing `BlogHiveModelAdapter`,
which you register with `Hive.registerAdapter(BlogHiveModelAdapter())`.

> **Migration rule of thumb**: once shipped, never change `typeId` or
> reorder/reuse existing `@HiveField` indices. To add a field, append a new
> index at the end and make it nullable (so old cached records still decode).

## 8. A local data source (mirroring the existing pattern)

```dart
// lib/feature/blog/data/datasources/blog_local_data_source.dart
abstract interface class BlogLocalDataSource {
  List<BlogHiveModel> getCachedBlogs();
  Future<void> cacheBlogs(List<BlogHiveModel> blogs);
  Future<void> clearCache();
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Box<BlogHiveModel> box;
  BlogLocalDataSourceImpl(this.box);

  @override
  List<BlogHiveModel> getCachedBlogs() => box.values.toList();

  @override
  Future<void> cacheBlogs(List<BlogHiveModel> blogs) async {
    await box.clear();
    await box.putAll({for (final b in blogs) b.id: b});
  }

  @override
  Future<void> clearCache() => box.clear();
}
```

## 9. Wiring into the repository (cache-then-network)

```dart
// lib/feature/blog/data/repositories/blog_repository_impl.dart
class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource remoteDataSource;
  final BlogLocalDataSource localDataSource;

  BlogRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, List<BlogEntity>>> getAllBlogs() async {
    try {
      final remoteBlogs = await remoteDataSource.getAllBlogs();
      await localDataSource.cacheBlogs(
        remoteBlogs.map((b) => b.toHiveModel()).toList(),
      );
      return right(remoteBlogs.map((b) => b.toEntity()).toList());
    } catch (_) {
      // Fallback to cache when offline / request fails
      final cached = localDataSource.getCachedBlogs();
      if (cached.isNotEmpty) {
        return right(cached.map((b) => b.toEntity()).toList());
      }
      return left(Failure('Failed to fetch blogs and no cache available'));
    }
  }
}
```

This gives the `BlogBloc` an offline fallback for free — the presentation
layer doesn't need to know Hive exists at all.

## 10. Reading/writing directly (quick reference)

```dart
final box = Hive.box<BlogHiveModel>('blogs');

// Write
await box.put(blog.id, blog);

// Read (synchronous!)
final blog = box.get('some-id');
final all = box.values.toList();

// Delete
await box.delete('some-id');

// Watch changes reactively
box.watch(key: 'some-id').listen((event) { ... });
```

## 11. Testing

Hive boxes can be opened in-memory for tests (no real file I/O):

```dart
setUp(() async {
  await Hive.initFlutter(); // or Hive.init(tempDir) in pure Dart tests
  Hive.registerAdapter(BlogHiveModelAdapter());
});

test('caches blogs', () async {
  final box = await Hive.openBox<BlogHiveModel>('test_blogs');
  final dataSource = BlogLocalDataSourceImpl(box);
  await dataSource.cacheBlogs([sampleBlog]);
  expect(dataSource.getCachedBlogs(), [sampleBlog]);
});
```

## 12. Summary

- Hive = fast, embedded, NoSQL key-value store for Dart/Flutter — no native
  dependencies.
- Best used as a **cache/offline layer behind a repository**, not as your
  single source of truth when you already have a backend like Supabase.
- Great for: caching lists, current-user/session persistence, offline
  fallback.
- Avoid for: relational data, complex queries, very large datasets — reach
  for Drift/sqflite instead.
- Prefer the `hive_ce` fork over the original `hive` package today, since
  it's the actively maintained one.
