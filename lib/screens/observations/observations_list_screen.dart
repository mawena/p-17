import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:p17/providers/auth_provider.dart';
import 'package:p17/providers/observation_provider.dart';
import 'package:p17/widgets/common_widgets.dart';

class ObservationsListScreen extends StatefulWidget {
  const ObservationsListScreen({Key? key}) : super(key: key);

  @override
  State<ObservationsListScreen> createState() => _ObservationsListScreenState();
}

class _ObservationsListScreenState extends State<ObservationsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reporter le chargement après le frame pour éviter setState() pendant le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadObservations();
    });
  }

  Future<void> _loadObservations() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      final obsProvider = context.read<ObservationProvider>();
      await obsProvider.loadUserObservations(authProvider.currentUser!.uid);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Observations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une espèce...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                // Implémenter la recherche
              },
            ),
          ),
          Expanded(
            child: Consumer<ObservationProvider>(
              builder: (context, obsProvider, _) {
                if (obsProvider.isLoading) {
                  return const LoadingWidget(
                    message: 'Chargement des observations...',
                  );
                }

                if (obsProvider.errorMessage != null) {
                  return ErrorMessageWidget(
                    message: obsProvider.errorMessage!,
                    onRetry: _loadObservations,
                  );
                }

                if (obsProvider.observations.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Aucune observation',
                    message:
                        'Vous n\'avez pas encore d\'observations. Commencez à enregistrer vos observations!',
                    icon: Icons.camera_alt,
                    onAction: () => context.go('/observations/new'),
                    actionLabel: 'Nouvelle observation',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: obsProvider.observations.length,
                  itemBuilder: (context, index) {
                    final observation = obsProvider.observations[index];
                    return ObservationCard(
                      id: observation.id,
                      speciesName: observation.speciesName,
                      photoUrl: observation.photoUrl ?? '',
                      observationDate: observation.observationDate,
                      latitude: observation.latitude,
                      longitude: observation.longitude,
                      onTap: () =>
                          context.go('/observations/${observation.id}'),
                      onDelete: () {
                        obsProvider.deleteObservation(observation.id);
                        SnackBarHelper.showSnackBar(
                          context,
                          message: 'Observation supprimée',
                          type: SnackBarType.success,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
