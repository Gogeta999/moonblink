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

  Database _db;

  init() async {
    String _path = await getDatabasesPath();
    print(join(_path, _dbName));
    _db = await openDatabase(
      join(_path, _dbName),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, name TEXT, created_at TEXT, updated_at INTEGER, reaction_count INTEGER, profile_image TEXT, cover_image TEXT, is_reacted INTEGER, type INTEGER, gender TEXT, bios TEXT)",
        );
      },
      version: 1,
    );
    print('Db status: ${_db.isOpen}');
  }

  void insertPost(Post post) async {
    int id = await _db.insert(_tableName, post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('Inserted Id: $id');
  }

  insertPosts(List<Post> posts) {
    posts.forEach((element) async {
      _db.insert(_tableName, element.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
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
      print('Retrieve Posts: ${posts.length}');
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
      print('Retrieve Posts: ${posts.length}');
      return List.generate(posts.length, (index) {
        return Post.fromMap(posts[index]);
      });
    }
  }

  deletePost(int id) async {
    await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  dispose() async {
    await _db.close();
  }
}
