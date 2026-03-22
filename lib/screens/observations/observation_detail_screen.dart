import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:p17/models/observation.dart';
import 'package:p17/providers/observation_provider.dart';
import 'package:p17/utils/helpers.dart';
import 'package:p17/widgets/common_widgets.dart';

class ObservationDetailScreen extends StatefulWidget {
  final String observationId;

  const ObservationDetailScreen({Key? key, required this.observationId})
    : super(key: key);

  @override
  State<ObservationDetailScreen> createState() =>
      _ObservationDetailScreenState();
}

class _ObservationDetailScreenState extends State<ObservationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'observation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/observations/${widget.observationId}/edit');
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              _showDeleteDialog();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Consumer<ObservationProvider>(
        builder: (context, obsProvider, _) {
          Observation? observation;
          try {
            observation = obsProvider.observations.firstWhere(
              (obs) => obs.id == widget.observationId,
            );
          } catch (e) {
            observation = null;
          }

          if (observation == null) {
            return const EmptyStateWidget(
              title: 'Observation introuvable',
              message: '',
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (observation.photoStoragePath.isNotEmpty)
                  _buildImage(observation.photoStoragePath)
                else if (observation.photoUrl != null)
                  Image.network(
                    observation.photoUrl!,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        observation.speciesName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Chip(label: Text(_getTypeLabel(observation.speciesType))),
                      const SizedBox(height: 16),
                      _DetailSection(
                        title: 'Description',
                        content: observation.description,
                      ),
                      const SizedBox(height: 16),
                      if (observation.notes.isNotEmpty)
                        _DetailSection(
                          title: 'Notes',
                          content: observation.notes,
                        ),
                      const SizedBox(height: 16),
                      _DetailSection(
                        title: 'Date',
                        content: DateTimeHelper.formatDateTime(
                          observation.observationDate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailSection(
                        title: 'Localisation',
                        content: LocationHelper.formatCoordinatesShort(
                          observation.latitude,
                          observation.longitude,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Implémenter la carte
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Voir sur la carte'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(String photoPath) {
    // Vérifier si c'est une URL réseau (commence par http:// ou https://)
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return Image.network(
        photoPath,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    } else {
      // C'est un chemin local
      return Image.file(
        File(photoPath),
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer l\'observation'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette observation? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final obsProvider = context.read<ObservationProvider>();
                await obsProvider.deleteObservation(widget.observationId);
                if (context.mounted) {
                  context.pop();
                  context.go('/observations');
                  SnackBarHelper.showSnackBar(
                    context,
                    message: 'Observation supprimée',
                    type: SnackBarType.success,
                  );
                }
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getTypeLabel(String type) {
    const labels = {
      'bird': 'Oiseau',
      'plant': 'Plante',
      'insect': 'Insecte',
      'mammal': 'Mammifère',
      'reptile': 'Reptile',
      'amphibian': 'Amphibien',
      'fish': 'Poisson',
      'other': 'Autre',
    };
    return labels[type] ?? type;
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;

  const _DetailSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }
}
