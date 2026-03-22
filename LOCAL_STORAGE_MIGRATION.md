# Guide de Migration: Firebase → Stockage Local

## 📋 Résumé des Changements

Votre application a été migrée pour stocker les données **100% localement sur le téléphone** via SQLite, tout en conservant **Firebase pour l'authentification uniquement**.

### Avant (Firestore + Firebase Storage):
```
User → Firebase Auth ✓
     → Firestore DB × (modifié)
     → Firebase Storage × (modifié)
```

### Après (SQLite + Stockage Local):
```
User → Firebase Auth ✓
     → SQLite (local) ✓
     → Fichiers locaux ✓
```

---

## 🎯 Avantages

✅ **Pas de coûts Firebase** (Firestore/Storage)
✅ **Données privées sur l'appareil** (aucun cloud)
✅ **Offline-first par défaut** (fonctionne sans internet)
✅ **Authentification sécurisée** (Firebase Auth)
✅ **Contrôle total des données**

---

## 🔧 Architecture Technique

### Couches de Service

#### 1. **Base de Données (SQLite)**
```dart
LocalDatabaseService          // Singleton pour accès BD
├─ LocalObservationsService   // CRUD observations
├─ LocalSpeciesService        // CRUD espèces
└─ LocalUserService           // CRUD profils utilisateurs
```

#### 2. **Stockage de Fichiers**
```dart
LocalFileStorageService       // Gestion images locales
├─ saveObservationPhoto()     // Photos observations
├─ saveUserAvatar()           // Avatars utilisateurs
└─ deletePhoto()              // Nettoyage
```

#### 3. **Couche Intermédiaire**
```dart
FirestoreService (adapté)     // Compatibilité UI
├─ Utilise les services locaux
├─ Simule les Streams
└─ Interface inchangée pour les Providers
```

#### 4. **Authentification**
```dart
AuthService
├─ Firebase Auth (login/signup/logout)
└─ Profils → SQLite (pas Firestore)
```

---

## 📂 Structure des Données

### Base de Données (p17.db)

#### Table: observations
```sql
CREATE TABLE observations (
  id TEXT PRIMARY KEY,
  userId TEXT,
  speciesName TEXT,
  speciesType TEXT,
  description TEXT,
  notes TEXT,
  observationDate TEXT (ISO8601),
  latitude REAL,
  longitude REAL,
  photoUrl TEXT (chemin local),
  photoStoragePath TEXT,
  createdAt TEXT (ISO8601),
  updatedAt TEXT (ISO8601),
  isPublic INTEGER (0/1)
)
```

#### Table: species
```sql
CREATE TABLE species (
  id TEXT PRIMARY KEY,
  commonName TEXT,
  scientificName TEXT,
  type TEXT,
  description TEXT,
  imageUrl TEXT,
  tags TEXT (JSON),
  isVerified INTEGER (0/1),
  createdAt TEXT (ISO8601)
)
```

#### Table: users
```sql
CREATE TABLE users (
  uid TEXT PRIMARY KEY,
  email TEXT,
  displayName TEXT,
  photoUrl TEXT,
  createdAt TEXT (ISO8601),
  updatedAt TEXT (ISO8601),
  observationCount INTEGER,
  favoriteSpecies TEXT (JSON)
)
```

### Stockage de Fichiers
```
ApplicationDocumentsDirectory/
├─ observations/
│  └─ userId/
│     └─ observationId/
│        └─ [timestamp].jpg
├─ avatars/
│  └─ userId.jpg
```

---

## 🚀 Démarrage de l'Application

### Prérequis
- Flutter 3.11+
- `pubspec.yaml` mis à jour avec `path_provider`

### Installation
```bash
cd /home/charles-gamligo/Work/Jeff/p17

# Installer les dépendances
flutter pub get

# Construire l'app
flutter build apk  # ou: -ios, -web, -windows, -macos, -linux
```

---

## 📄 Fichiers Modifiés/Créés

### ✨ Nouveaux Services
- `lib/services/local_database_service.dart` - Base SQLite
- `lib/services/local_observations_service.dart` - Observations
- `lib/services/local_species_service.dart` - Espèces
- `lib/services/local_user_service.dart` - Utilisateurs
- `lib/services/local_file_storage_service.dart` - Stockage photos

### 🔄 Services Adaptés
- `lib/services/auth_service.dart` - Firebase Auth + profils locaux
- `lib/services/firestore_service.dart` - Wrapper autour services locaux
- `lib/services/storage_service.dart` - Stockage local au lieu Firebase
- `lib/providers/observation_provider.dart` - Simplifié (utilise FirestoreService)
- `lib/screens/observations/new_observation_screen.dart` - Attendre async paths

### 📦 Dépendances Ajoutées
- `path_provider: ^2.1.1` - Accès répertoires app

---

## 🔐 Sécurité & Performance

### ✓ Sécurité
- **Données locales**: Chiffrées par le SE mobile
- **Auth Firebase**: Tokens JWT sécurisés
- **Pas d'exposition cloud**: 0 risque de fuite serveur

### ✓ Performance
- **Index SQLite**: userID, speciesName, type
- **Requêtes locales**: Sub-milliseconde
- **Offline-first**: Pas de latence réseau

---

## 🛠️ Dépannage

### Erreur: "DatabaseService not found"
**Cause**: Ancien code utilisant DatabaseService
**Solution**: Utiliser FirestoreService (qui utilise les services locaux)

### Erreur: "Timestamp is not defined"
**Cause**: Imports Firestore non nécessaires
**Solution**: Vérifier les imports, garder cloud_firestore pour Auth

### Images n'apparaissent pas
**Cause**: Chemin relatif vs absolu
**Solution**: `LocalFileStorageService` retourne chemins **absolus**

---

## 📚 Cas d'Usage Courants

### Ajouter une observation
```dart
// ObservationProvider gère tout
await observationProvider.addObservation(observation);
// → Sauvegarde en SQLite
// → Notifie les listeners
// → Stocke la photo localement
```

### Rechercher une espèce
```dart
// SpeciesProvider utilise FirestoreService → LocalSpeciesService
await speciesProvider.searchSpecies('eagle');
// → Recherche locale en millisecondes
```

### Ajouter aux favoris
```dart
// AuthService utilise LocalUserService
await userService.addFavoriteSpecies(userId, speciesId);
// → Met à jour table users
```

### Charger profil utilisateur
```dart
// Après login Firebase
final appUser = await authService.getCurrentUser();
// → Lit de SQLite (local)
```

---

## 🔄 Migration depuis Firestore (FYI)

Si vous aviez des données dans Firestore avant cette migration:

1. **Exporter données Firestore** (JSON)
2. **Parser et transformer** au format SQLite
3. **Insérer via services locaux**

Exemple (pseudo-code):
```dart
// Import migration helper (à créer si nécessaire)
final observations = await firestoreBackupJson.parse();
for (var obs in observations) {
  await localObservationsService.addObservation(
    Observation.fromMap(obs)
  );
}
```

---

## 📊 Monitoring & Logs

### Logs d'Application
- **AuthService**: `print()` connexion/erreurs
- **LocalFileStorageService**: `print()` upload/suppression photos
- **StorageService**: `print()` chemins

**À faire en production**: Remplacer par logging framework

---

## ✅ Checklist de Déploiement

- [ ] Test authentification Firebase
- [ ] Test créer observation (photo)
- [ ] Test rechercher espèces
- [ ] Test ajouter favoris
- [ ] Test supprimer observation
- [ ] Vérifier stockage local (`/data/data/com.example.p17/app_flutter/`)
- [ ] Test offline (désactiver WiFi)
- [ ] Vérifier taille BD (doit rester <100MB)
- [ ] Nettoyer photos non utilisées

---

## 📞 Support

Pour la documentation complète des services:
- `lib/services/local_*_service.dart` - Commentaires inline
- `lib/models/` - Modèles de données
- `lib/providers/` - Logique métier UI

---

**Dernière mise à jour**: 22 Mars 2026
