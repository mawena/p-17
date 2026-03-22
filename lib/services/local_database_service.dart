import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  static Database? _database;

  LocalDatabaseService._internal();

  factory LocalDatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'p17.db');

    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Table des observations
    await db.execute('''
      CREATE TABLE observations (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        speciesName TEXT NOT NULL,
        speciesType TEXT NOT NULL,
        description TEXT NOT NULL,
        notes TEXT NOT NULL,
        observationDate TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        photoUrl TEXT,
        photoStoragePath TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isPublic INTEGER DEFAULT 0
      )
    ''');

    // Table des espèces
    await db.execute('''
      CREATE TABLE species (
        id TEXT PRIMARY KEY,
        commonName TEXT NOT NULL,
        scientificName TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT,
        tags TEXT,
        isVerified INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        displayName TEXT NOT NULL,
        photoUrl TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        observationCount INTEGER DEFAULT 0,
        favoriteSpecies TEXT
      )
    ''');

    // Index pour requêtes rapides
    await db.execute(
      'CREATE INDEX observations_userId ON observations(userId)',
    );
    await db.execute(
      'CREATE INDEX observations_speciesName ON observations(speciesName)',
    );
    await db.execute(
      'CREATE INDEX observations_isPublic ON observations(isPublic)',
    );
    await db.execute('CREATE INDEX species_commonName ON species(commonName)');
    await db.execute('CREATE INDEX species_type ON species(type)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
