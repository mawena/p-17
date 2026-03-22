import 'package:go_router/go_router.dart';
import 'package:p17/screens/auth/login_screen.dart';
import 'package:p17/screens/auth/signup_screen.dart';
import 'package:p17/screens/home_screen.dart';
import 'package:p17/screens/observations/observations_list_screen.dart';
import 'package:p17/screens/observations/new_observation_screen.dart';
import 'package:p17/screens/observations/observation_detail_screen.dart';
import 'package:p17/screens/observations/observation_edit_screen.dart';
import 'package:p17/screens/map_screen.dart';
import 'package:p17/screens/profile_screen.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String observationsRoute = '/observations';
  static const String newObservationRoute = '/observations/new';
  static const String observationDetailRoute = '/observations/:id';
  static const String observationEditRoute = '/observations/:id/edit';
  static const String mapRoute = '/map';
  static const String profileRoute = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: homeRoute,
    redirect: (context, state) {
      // Vous pouvez ajouter une logique de redirection basée sur l'authentification ici
      return null;
    },
    routes: [
      GoRoute(
        path: loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signupRoute,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: homeRoute, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: observationsRoute,
        builder: (context, state) => const ObservationsListScreen(),
      ),
      GoRoute(
        path: newObservationRoute,
        builder: (context, state) => const NewObservationScreen(),
      ),
      GoRoute(
        path: observationDetailRoute,
        builder: (context, state) {
          final observationId = state.pathParameters['id']!;
          return ObservationDetailScreen(observationId: observationId);
        },
      ),
      GoRoute(
        path: observationEditRoute,
        builder: (context, state) {
          final observationId = state.pathParameters['id']!;
          return ObservationEditScreen(observationId: observationId);
        },
      ),
      GoRoute(path: mapRoute, builder: (context, state) => const MapScreen()),
      GoRoute(
        path: profileRoute,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
