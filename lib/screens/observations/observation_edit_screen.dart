import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:p17/providers/observation_provider.dart';
import 'package:p17/models/observation.dart';
import 'package:p17/utils/helpers.dart';
import 'package:p17/widgets/common_widgets.dart';
import 'dart:io';

class ObservationEditScreen extends StatefulWidget {
  final String observationId;

  const ObservationEditScreen({Key? key, required this.observationId})
    : super(key: key);

  @override
  State<ObservationEditScreen> createState() => _ObservationEditScreenState();
}

class _ObservationEditScreenState extends State<ObservationEditScreen> {
  final _speciesNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Observation _observation;
  String _selectedSpeciesType = 'bird';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObservation();
  }

  Future<void> _loadObservation() async {
    final obsProvider = context.read<ObservationProvider>();
    try {
      final obs = obsProvider.observations.firstWhere(
        (obs) => obs.id == widget.observationId,
      );
      setState(() {
        _observation = obs;
        _speciesNameController.text = obs.speciesName;
        _descriptionController.text = obs.description;
        _notesController.text = obs.notes;
        _selectedSpeciesType = obs.speciesType;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        SnackBarHelper.showSnackBar(
          context,
          message: 'Observation introuvable',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final obsProvider = context.read<ObservationProvider>();

      final updatedObservation = _observation.copyWith(
        speciesName: _speciesNameController.text.trim(),
        speciesType: _selectedSpeciesType,
        description: _descriptionController.text.trim(),
        notes: _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await obsProvider.updateObservation(updatedObservation);

      if (!mounted) return;

      if (success) {
        SnackBarHelper.showSnackBar(
          context,
          message: 'Observation mise à jour',
          type: SnackBarType.success,
        );
        context.go('/observations/${widget.observationId}');
      } else {
        SnackBarHelper.showSnackBar(
          context,
          message: obsProvider.errorMessage ?? 'Erreur lors de la mise à jour',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showSnackBar(
          context,
          message: 'Erreur: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _speciesNameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Modifier l\'observation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.go('/observations/${widget.observationId}'),
          ),
        ),
        body: const LoadingWidget(message: 'Chargement...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'observation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/observations/${widget.observationId}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo display
              if (_observation.photoUrl != null ||
                  _observation.photoStoragePath.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(
                          _observation.photoStoragePath.isNotEmpty
                              ? _observation.photoStoragePath
                              : _observation.photoUrl ?? '',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Photo (non modifiable)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_not_supported, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Pas de photo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Espèce
              TextFormField(
                controller: _speciesNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'espèce',
                  prefixIcon: Icon(Icons.nature),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer le nom de l\'espèce';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type d'espèce
              DropdownButtonFormField<String>(
                value: _selectedSpeciesType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'espèce',
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'bird', child: Text('Oiseau')),
                  DropdownMenuItem(value: 'plant', child: Text('Plante')),
                  DropdownMenuItem(value: 'insect', child: Text('Insecte')),
                  DropdownMenuItem(value: 'mammal', child: Text('Mammifère')),
                  DropdownMenuItem(value: 'reptile', child: Text('Reptile')),
                  DropdownMenuItem(
                    value: 'amphibian',
                    child: Text('Amphibien'),
                  ),
                  DropdownMenuItem(value: 'fish', child: Text('Poisson')),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSpeciesType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date
              ListTile(
                title: const Text('Date de l\'observation'),
                subtitle: Text(
                  DateTimeHelper.formatDateTime(_observation.observationDate),
                ),
                leading: const Icon(Icons.calendar_today),
              ),
              const SizedBox(height: 8),

              // Localisation
              ListTile(
                title: const Text('Localisation'),
                subtitle: Text(
                  LocationHelper.formatCoordinatesShort(
                    _observation.latitude,
                    _observation.longitude,
                  ),
                ),
                leading: const Icon(Icons.location_on),
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String photoPath) {
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return Image.network(
        photoPath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    } else {
      return Image.file(
        File(photoPath),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
        },
      );
    }
  }
}
