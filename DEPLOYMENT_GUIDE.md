# Guide de Déploiement et Tests

## 🧪 Tests Locaux

### Prérequis
```bash
# Vérifier les installations
flutter --version
flutter doctor

# Si des avertissements, les résoudre
flutter doctor -v
```

### Lancer l'app en développement

```bash
# Mode débogage
flutter run

# Mode release (plus rapide)
flutter run --release

# Sur un appareil spécifique
flutter run -d <device_id>

# Avec la VM
flutter run -d emulator-5554
```

### Tests des fonctionnalités

#### ✅ Authentification
- [ ] Inscription avec email/mot de passe
- [ ] Connexion correcte
- [ ] Redirection après connexion
- [ ] Logout
- [ ] Vérification du stockage local du profil

#### ✅ Observations
- [ ] Créer une observation
- [ ] Télécharger une photo (caméra)
- [ ] Télécharger une photo (galerie)
- [ ] Géolocalisation automatique
- [ ] Lister les observations
- [ ] Voir le détail d'une observation
- [ ] Supprimer une observation
- [ ] Rechercher une observation
- [ ] Filtrer par date/type

#### ✅ Permissions
- [ ] Demander la permission caméra
- [ ] Demander la permission GPS
- [ ] Demander la permission galerie

#### ✅ Stockage
- [ ] Sauvegarder localement sans réseau
- [ ] Synchronisation après reconnexion
- [ ] Cache des espèces

## 📱 Déploiement Android

### Build APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build AAB (Google Play)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Configuration avant publication

1. **AndroidManifest.xml** - Vérifier les permissions
2. **build.gradle** - Mettre à jour version et codes
3. **Key Store** - Générer une clé de signature

```bash
keytool -genkey -v -keystore ~/p17-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias p17-key
```

4. **Signer automatiquement**

Créer `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=p17-key
storeFile=<path-to-keystore>
```

Éditer `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Publication Google Play

1. Créer un compte Google Play Developer ($25)
2. Créer l'application dans Google Play Console
3. Remplir les informations de l'app
4. Uploader le AAB
5. Remplir les détails de publication
6. Soumettre pour révision

## 🍎 Déploiement iOS

### Build IPA
```bash
flutter build ipa --release
```

### Configuration avant publication

1. **Mise à jour version**
   - Éditer `pubspec.yaml`: `version: 1.0.0+1`
   - `1.0.0` = version visiblent
   - `+1` = build number (incrémenter à chaque mise à jour)

2. **Certificats & Provisioning**
   - Créer une certtificat de développement dans Apple Developer
   - Créer un App ID unique
   - Créer un profil de provisioning

3. **Xcode Configuration**
   - Ouvrir `ios/Runner.xcworkspace`
   - Configurer bundle ID
   - Configurer le team ID
   - Configurer la version

```bash
open ios/Runner.xcworkspace
```

### Publication App Store

1. Créer un compte Apple Developer ($99/an)
2. Créer l'application dans App Store Connect
3. Remplir les informations
4. Uploader l'IPA via Xcode ou Transporter
5. Remplir les détails de publication
6. Soumettre pour révision

## 🌐 Configuration Firebase en Production

### Sécurité Firestore
```bash
# Déployer les règles
firebase deploy --only firestore:rules
```

Via Firebase Console:
1. Aller à Firestore > Règles
2. Copier les règles de `firestore.rules`
3. Publier

### Sécurité Storage
```bash
# Déployer les règles
firebase deploy --only storage
```

Via Firebase Console:
1. Aller à Storage > Règles
2. Copier les règles de `storage.rules`
3. Publier

### Indexation Firestore
Firebase crée automatiquement les index. Vérifier que:
- Les recherches par multiple champs fonctionnent
- Les tri complexes fonctionnent

## 📊 Monitoring

### Firebase Console
- Analytics
- Crash Reporting
- Performance Monitoring
- Authentication

```bash
# Activer dans main.dart
await Firebase.initializeApp();
```

### Logs
```bash
# Voir les logs Firebase
firebase functions:log

# Logs de l'appareil
flutter logs

# Logs Android
adb logcat

# Logs iOS
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'
```

## 🔒 Sécurité Supplémentaire

### Variables d'environnement
```bash
# Créer un fichier .env
GOOGLE_MAPS_API_KEY=xxx
FIREBASE_PROJECT_ID=xxx
```

### Secrets Firebase
```bash
# Récupérer les secrets
firebase secrets:create GOOGLE_MAPS_API_KEY
firebase deploy --only functions
```

## 📈 Optimisation

### Taille de l'APK
```bash
# Vérifier la taille
flutter build apk --split-per-abi

# Analyser le contenu
flutter build appbundle --release
```

### Performance
- Activer le mode release pour les tests
- Utiliser DevTools pour profiler
- Vérifier les images optimisées

```bash
flutter pub run build_runner build
flutter pub run devtools
```

## 🚨 Debugging en Production

### Error Tracking
```dart
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Une erreur est survenue',
);
```

### Logs personnalisés
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'observation_created',
  parameters: {
    'species': 'robin',
    'has_photo': true,
  },
);
```

## 📋 Checklist pré-lancement

- [ ] Configuration Firebase complète
- [ ] Tests sur Android et iOS
- [ ] Permissions configurées
- [ ] Icône et splash screen
- [ ] Contenu de confidentialité
- [ ] Certificats valides
- [ ] Version incrémentée
- [ ] Tests de charge
- [ ] Performance optimisée
- [ ] Crashlytics intégré
- [ ] Analytics activé
- [ ] Sauvegarder les clés
- [ ] Documentation à jour
- [ ] Tests utilisateur
- [ ] Prêt à la publication

## 🆘 Problèmes Courants

### Firebase non trouvé
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
```

### Permissions refusées
- Vérifier AndroidManifest.xml
- Vérifier Info.plist
- Tester sur vraie device

### Carte vide
- Vérifier Google Maps API
- Vérifier les clés
- Vérifier internetActivity

### Photos ne chargent pas
- Firebase Storage rules
- Authentification utilisateur
- Permissions

## 📞 Support

- [Flutter Documentation](https://flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)

---

**Important**: Garder les clés privées sécurisées et ne jamais les committer!
