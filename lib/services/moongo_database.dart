import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MoonGoDB {
  static final MoonGoDB _instance = MoonGoDB._();
  factory MoonGoDB() => _instance;

  MoonGoDB._();

  final String _dbName = kDataBaseName;
  final String _tableName = kHomePostTableName;
  final String _nfTableName = kNewFeedTableName;

  Database _db;

  init() async {
    final migrationsScripts = [
      "CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, name TEXT, created_at TEXT, updated_at INTEGER, reaction_count INTEGER, profile_image TEXT, cover_image TEXT, is_reacted INTEGER, type INTEGER, gender TEXT, bios TEXT)",
      "CREATE TABLE $_nfTableName(id INTEGER PRIMARY KEY, user_id INTEGER, body TEXT, media TEXT, status INTEGER, created_at TEXT, updated_at TEXT, reaction_count INTEGER, user_name TEXT, profile_image TEXT, is_reacted INTEGER, bios TEXT)"
    ];

    String _path = await getDatabasesPath();
    if (isDev) print(join(_path, _dbName));
    _db = await openDatabase(
      join(_path, _dbName),
      version: migrationsScripts.length,
      onCreate: (db, version) async {
        if (isDev) print("Creating Database for $version");
        for (int i = 1; i <= version; ++i) {
          await db.execute(migrationsScripts[i - 1]);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (isDev) print("Upgrading Database from $oldVersion to $newVersion");
        for (int i = oldVersion + 1; i <= newVersion; ++i) {
          await db.execute(migrationsScripts[i - 1]);
        }
      },
      onOpen: (db) async {
        if (isDev)
          print("Current Database version is ${await db.getVersion()}");
      },
    );
  }

  void insertPost(Post post) {
    _db
        .insert(_tableName, post.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) {
      if (isDev) print('Inserted Id: $value');
    });
  }

  insertPosts(List<Post> posts) {
    _db.transaction((txn) {
      posts.forEach((element) {
        txn
            .insert(_tableName, element.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace)
            .then((value) {
          if (isDev) print('Inserted Id: $value');
        });
      });
      return Future.value(true);
    });
  }

  ///Local
  Future<List<Post>> retrievePosts(
      int limit, int page, int type, String gender) async {
    final int offset = limit * (page - 1);
    if (gender == 'All') {
      final List<Map> posts = await _db.query(_tableName,
          distinct: true,
          columns: null,
          where: 'type = ?',
          whereArgs: [type],
          orderBy: 'updated_at DESC',
          limit: limit,
          offset: offset);
      if (isDev) print('Retrieve Posts: ${posts.length}');
      return List.generate(posts.length, (index) {
        return Post.fromMap(posts[index]);
      });
    } else {
      final List<Map> posts = await _db.query(_tableName,
          distinct: true,
          columns: null,
          where: 'type = ? AND gender = ?',
          whereArgs: [type, gender],
          orderBy: 'updated_at DESC',
          limit: limit,
          offset: offset);
      if (isDev) print('Retrieve Posts: ${posts.length}');
      return List.generate(posts.length, (index) {
        return Post.fromMap(posts[index]);
      });
    }
  }

  deletePost(int id) async {
    await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
  ///---- Start NFPOST -----
  void insertNfPost(NFPost nfPost) {
    _db
        .insert(_nfTableName, nfPost.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => print('Inserted Id: $value'));
  }

  insertNfPosts(List<NFPost> nfPosts) {
    _db.transaction((txn) {
      nfPosts.forEach((element) async {
        txn
            .insert(_nfTableName, element.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace)
            .then((value) {
          if (isDev) print('Inserted Id: $value');
        });
      });
      return Future.value(true);
    });
  }

  updateNfPost(NFPost nfPost) {
    _db.transaction((txn) {
      txn.update(
        _nfTableName,
        nfPost.toMap(),
        where: "id = ?",
        whereArgs: [nfPost.id],
      ).then((value) => print("Updated Id: $value"));
      return Future.value(true);
    });
  }

  ///Local
  Future<List<NFPost>> retrieveNfPosts(int limit, int page) async {
    final int offset = limit * (page - 1);
    final List<Map> nfPosts = await _db.query(_nfTableName,
        distinct: true,
        columns: null,
        orderBy: 'id DESC',
        limit: limit,
        offset: offset);
    if (isDev)
      print(
          'Retrieve Posts: ${nfPosts.length} ${nfPosts.first['id']} ${nfPosts.last['id']}');
    return List.generate(nfPosts.length, (index) {
      return NFPost.fromMap(nfPosts[index]);
    });
  }

  deleteNFPost(int id) async {
    await _db.delete(_nfTableName, where: 'id = ?', whereArgs: [id]);
  }

  dispose() async {
    await _db.close();
  }
}
