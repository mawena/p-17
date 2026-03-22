import 'package:intl/intl.dart';

class DateTimeHelper {
  // Formater une date pour l'affichage
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formater une date et heure
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Formater une heure
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Obtenir la différence de temps lisible
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 1) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 1) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 1) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  // Vérifier si deux dates sont le même jour
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class LocationHelper {
  // Formater les coordonnées GPS
  static String formatCoordinates(double latitude, double longitude) {
    return '$latitude, $longitude';
  }

  // Arrondir les coordonnées pour l'affichage
  static String formatCoordinatesShort(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  // Convertir les mètres en kilomètres
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(2)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }
}

class ValidationHelper {
  // Valider un email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Valider un mot de passe
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Valider un nom d'affichage
  static bool isValidDisplayName(String displayName) {
    return displayName.isNotEmpty && displayName.length >= 3;
  }

  // Valider un nom d'espèce
  static bool isValidSpeciesName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }
}
