import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:p17/models/observation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wildlife_census.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    // Table des observations locales
    await db.execute('''
      CREATE TABLE observations (
        id TEXT PRIMARY KEY,
        userId TEXT,
        speciesName TEXT,
        speciesType TEXT,
        description TEXT,
        notes TEXT,
        observationDate TEXT,
        latitude REAL,
        longitude REAL,
        photoPath TEXT,
        photoUrl TEXT,
        photoStoragePath TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        isPublic INTEGER,
        syncStatus TEXT,
        isSynced INTEGER
      )
    ''');

    // Table des espèces en cache
    await db.execute('''
      CREATE TABLE species (
        id TEXT PRIMARY KEY,
        commonName TEXT,
        scientificName TEXT,
        type TEXT,
        description TEXT,
        imageUrl TEXT,
        tags TEXT,
        isVerified INTEGER,
        createdAt TEXT
      )
    ''');

    // Créer des index pour les recherches fréquentes
    await db.execute('CREATE INDEX idx_obs_userId ON observations(userId)');
    await db.execute(
      'CREATE INDEX idx_obs_speciesName ON observations(speciesName)',
    );
    await db.execute(
      'CREATE INDEX idx_obs_date ON observations(observationDate)',
    );
  }

  // ==================== Observations ====================
  Future<void> insertObservation(Observation observation) async {
    final db = await database;
    await db.insert('observations', {
      'id': observation.id,
      'userId': observation.userId,
      'speciesName': observation.speciesName,
      'speciesType': observation.speciesType,
      'description': observation.description,
      'notes': observation.notes,
      'observationDate': observation.observationDate.toIso8601String(),
      'latitude': observation.latitude,
      'longitude': observation.longitude,
      'photoUrl': observation.photoUrl,
      'photoStoragePath': observation.photoStoragePath,
      'createdAt': observation.createdAt.toIso8601String(),
      'updatedAt': observation.updatedAt.toIso8601String(),
      'isPublic': observation.isPublic ? 1 : 0,
      'syncStatus': 'pending',
      'isSynced': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateObservation(Observation observation) async {
    final db = await database;
    await db.update(
      'observations',
      {
        'speciesName': observation.speciesName,
        'speciesType': observation.speciesType,
        'description': observation.description,
        'notes': observation.notes,
        'observationDate': observation.observationDate.toIso8601String(),
        'latitude': observation.latitude,
        'longitude': observation.longitude,
        'photoUrl': observation.photoUrl,
        'photoStoragePath': observation.photoStoragePath,
        'updatedAt': observation.updatedAt.toIso8601String(),
        'isPublic': observation.isPublic ? 1 : 0,
        'syncStatus': 'modified',
      },
      where: 'id = ?',
      whereArgs: [observation.id],
    );
  }

  Future<void> deleteObservation(String observationId) async {
    final db = await database;
    await db.delete(
      'observations',
      where: 'id = ?',
      whereArgs: [observationId],
    );
  }

  Future<List<Observation>> getObservations(String userId) async {
    final db = await database;
    final maps = await db.query(
      'observations',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'observationDate DESC',
    );

    return maps.map((map) => _mapToObservation(map)).toList();
  }

  Future<List<Observation>> getUnsyncedObservations() async {
    final db = await database;
    final maps = await db.query(
      'observations',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return maps.map((map) => _mapToObservation(map)).toList();
  }

  // ==================== Species ====================
  Future<void> insertSpecies(Map<String, dynamic> species) async {
    final db = await database;
    await db.insert(
      'species',
      species,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> searchSpecies(String query) async {
    final db = await database;
    return await db.query(
      'species',
      where: 'commonName LIKE ? OR scientificName LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // ==================== Utilities ====================
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('observations');
    await db.delete('species');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Observation _mapToObservation(Map<String, dynamic> map) {
    return Observation(
      id: map['id'],
      userId: map['userId'],
      speciesName: map['speciesName'],
      speciesType: map['speciesType'],
      description: map['description'],
      notes: map['notes'],
      observationDate: DateTime.parse(map['observationDate']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      photoUrl: map['photoUrl'],
      photoStoragePath: map['photoStoragePath'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isPublic: map['isPublic'] == 1,
    );
  }
}
