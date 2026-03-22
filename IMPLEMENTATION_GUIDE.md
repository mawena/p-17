# Wildlife Census - Application de Recensement de la Faune/Flore

Une application mobile Flutter pour enregistrer, visualiser et partager vos observations de faune et flore locale.

## ✨ Fonctionnalités

### Core Features
- 🔐 **Authentification Firebase** - Inscription et connexion sécurisée
- 📷 **Prise de photos** - Capture via caméra ou sélection depuis la galerie
- 📍 **Géolocalisation** - Localisation GPS précise des observations
- 📝 **Formulaire détaillé** - Enregistrement des espèces avec description et notes
- 📊 **Visualisation** - Liste et détails des observations
- 🗺️ **Carte interactive** - Affichage des observations sur une carte Google Maps
- 👤 **Profil utilisateur** - Statistiques et gestion du compte
- 🔍 **Recherche & Filtrage** - Rechercher par espèce, date ou type
- 💾 **Stockage local** - SQLite pour la persistance hors ligne
- ☁️ **Synchronisation** - Sync. automatique avec Firebase Firestore

## 📦 Dépendances Principales

```yaml
firebase_core: ^27.1.0        # Firebase
firebase_auth: ^5.1.4         # Authentification
cloud_firestore: ^5.1.1       # Base de données
firebase_storage: ^12.1.3     # Stockage des photos
camera: ^0.11.0+1             # Caméra
image_picker: ^1.1.2          # Sélection d'images
geolocator: ^11.1.0           # Géolocalisation
google_maps_flutter: ^2.10.0  # Cartes
sqflite: ^2.3.3               # Base de données locale
provider: ^6.1.2              # Gestion d'état
go_router: ^14.2.3            # Navigation
```

## 🚀 Installation

### Prérequis
- Flutter 3.13+ et Dart 3.1+
- Android Studio / Xcode (pour les dépendances natives)
- Compte Firebase

### 1. Cloner le projet
```bash
git clone <repository>
cd p17
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Configurer Firebase

#### Via FlutterFire CLI (Recommandé)
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

#### Ou manuellement

**Android:**
1. Télécharger `google-services.json` depuis Firebase Console
2. Placer dans `android/app/`

**iOS:**
1. Télécharger `GoogleService-Info.plist` depuis Firebase Console
2. Placer dans `ios/Runner/` et ajouter à Xcode

### 4. Configuration Android

Éditer `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        targetSdkVersion 34
        minSdkVersion 21
    }
}
```

Éditer `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

Ajouter dans `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <activity android:name="com.google.android.gms.maps.MapsInitializationActivity" />
    
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY" />
</application>
```

### 5. Configuration iOS

Dans `ios/Podfile`, décommenter:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

Éditer `ios/Runner/Info.plist`:

```xml
<dict>
    <key>NSCameraUsageDescription</key>
    <string>L'app a besoin d'accéder à votre caméra pour prendre des photos des espèces</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>L'app a besoin de votre localisation pour enregistrer le GPS des observations</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>L'app a besoin de votre localisation pour enregistrer le GPS des observations</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>L'app a besoin d'accéder à votre galerie pour sélectionner des photos</string>
    
    <key>NSPhotoLibraryAddOnlyUsageDescription</key>
    <string>L'app a besoin de sauvegarder les photos dans votre galerie</string>
    
    <key>com.google.ios.maps.MapsDisplayBundle</key>
    <array></array>
    
    <key>io.flutter.embedded_views_preview</key>
    <true/>
</dict>
```

Obtenir une clé Google Maps:
1. Aller à [Google Cloud Console](https://console.cloud.google.com)
2. Créer un nouveau projet
3. Activer l'API Google Maps
4. Créer une clé API iOS
5. Ajouter à `Info.plist` comme ci-dessus

## 🏃 Lancer l'application

```bash
flutter run
```

Pour un appareil spécifique:
```bash
flutter run -d <device_id>
```

## 📁 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée
├── config/                   # Configuration
│   ├── router.dart          # Routage Go Router
│   └── theme.dart           # Thème Material
├── models/                   # Modèles de données
│   ├── observation.dart      # Observation
│   ├── species.dart         # Espèce
│   └── user.dart            # Utilisateur
├── providers/                # Gestion d'état
│   ├── auth_provider.dart   # Authentification
│   ├── observation_provider.dart
│   └── species_provider.dart
├── screens/                  # Écrans
│   ├── auth/                # Authentification
│   ├── observations/        # Observations
│   ├── home_screen.dart
│   ├── map_screen.dart
│   └── profile_screen.dart
├── services/                 # Services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   ├── geolocation_service.dart
│   └── database_service.dart
├── widgets/                  # Widgets réutilisables
│   └── common_widgets.dart
└── utils/                    # Utilitaires
    ├── constants.dart
    └── helpers.dart
```

## 🛠️ Architecture

- **State Management**: Provider + ChangeNotifier
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Local DB**: SQLite
- **UI**: Material Design 3

## 🔑 Fonctionnalités Détaillées

### Authentification
- Inscription/Connexion avec email
- Réinitialisation de mot de passe
- Profil utilisateur

### Observations
- Créer une nouvelle observation
- Télécharger photo (caméra/galerie)
- Géolocalisation automatique
- Lister et filtrer observations
- Voir détails avec carte
- Supprimer observation

### Base de Données Locale
- Cache des observations
- Synchronisation offline-first
- Persistance des espèces

## 🔒 Sécurité

- Authentification Firebase
- Stockage sécurisé des photos
- Règles Firestore (à configurer)
- Permissions OS strictes

## 📝 Notes Importantes

1. **Configurer Firebase** avant de lancer l'app
2. **Obtenir une clé Google Maps** pour la fonctionnalité carte
3. **Obtenir les permissions** (caméra, GPS) depuis l'utilisateur
4. **Tester sur un vrai appareil** pour GPS et caméra
5. **Gérer le coût Firebase** - monitorer utilisation

## 🚧 Fonctionnalités Futures

- [ ] Intégration complète Google Maps
- [ ] Partage communautaire
- [ ] Base de données d'espèces avancée
- [ ] Statistiques et graphiques
- [ ] Export des données
- [ ] Mode hors ligne complet
- [ ] Notifications push
- [ ] Backup automatique

## 🤝 Contribution

Les contributions sont bienvenues! Veuillez:
1. Forker le projet
2. Créer une branche feature
3. Committer vos changements
4. Pousser et crér une pull request

## 📄 License

Ce projet est sous licence MIT.

## 📞 Support

Pour toute question ou problème, créez un issue sur le repositorye.

---

**Note**: Remplacer les valeurs Firebase par vos propres clés dans `firebase_options.dart`
