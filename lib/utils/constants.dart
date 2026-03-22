// Constantes de l'application

class AppConstants {
  // Titres et descriptions
  static const String appName = 'Wildlife Census';
  static const String appDescription =
      'Enregistrez et visualisez vos observations de faune et flore';

  // Types d'espèces
  static const List<String> speciesTypes = [
    'bird',
    'plant',
    'insect',
    'mammal',
    'reptile',
    'amphibian',
    'fish',
    'other',
  ];

  static const Map<String, String> speciesTypeLabels = {
    'bird': 'Oiseau',
    'plant': 'Plante',
    'insect': 'Insecte',
    'mammal': 'Mammifère',
    'reptile': 'Reptile',
    'amphibian': 'Amphibien',
    'fish': 'Poisson',
    'other': 'Autre',
  };

  // Validations
  static const int minPasswordLength = 6;
  static const int maxNotesLength = 1000;
  static const int maxDescriptionLength = 500;

  // Limites de l'API
  static const int maxPhotoSize = 5242880; // 5 MB
  static const int maxObservationsInList = 50;
  static const int locationRefreshInterval = 10000; // 10 secondes

  // Précision de la géolocalisation (en mètres)
  static const int locationAccuracy = 10;
}

// Couleurs personnalisées
class AppColors {
  static const int _primaryColor = 0xFF4CAF50;
  static const int _accentColor = 0xFF2196F3;
  static const int _errorColor = 0xFFE53935;
  static const int _successColor = 0xFF66BB6A;
  static const int _warningColor = 0xFFFFB74D;

  static const List<int> colors = [
    _primaryColor,
    _accentColor,
    _errorColor,
    _successColor,
    _warningColor,
  ];
}

// Textes de l'application
class AppStrings {
  // Authentification
  static const String signUp = 'Inscription';
  static const String logIn = 'Connexion';
  static const String logOut = 'Déconnexion';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String displayName = 'Nom d\'affichage';
  static const String forgotPassword = 'Mot de passe oublié?';
  static const String createAccount = 'Créer un compte';
  static const String alreadyHaveAccount = 'Vous avez déjà un compte?';

  // Navigation
  static const String home = 'Accueil';
  static const String observations = 'Observations';
  static const String newObservation = 'Nouvelle observation';
  static const String map = 'Carte';
  static const String profile = 'Profil';
  static const String settings = 'Paramètres';

  // Observations
  static const String speciesName = 'Nom de l\'espèce';
  static const String speciesType = 'Type d\'espèce';
  static const String description = 'Déscription';
  static const String notes = 'Notes';
  static const String observationDate = 'Date de l\'observation';
  static const String location = 'Localisation';
  static const String photo = 'Photo';
  static const String takePhoto = 'Prendre une photo';
  static const String pickPhoto = 'Sélectionner de la galerie';

  // Boutons
  static const String save = 'Enregistrer';
  static const String cancel = 'Annuler';
  static const String delete = 'Supprimer';
  static const String edit = 'Modifier';
  static const String submit = 'Soumettre';
  static const String search = 'Rechercher';
  static const String filter = 'Filtrer';

  // Messages
  static const String loadingData = 'Chargement des données...';
  static const String noData = 'Aucune donnée';
  static const String error = 'Erreur';
  static const String success = 'Succès';
  static const String warning = 'Avertissement';
}
