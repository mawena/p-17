import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:p17/providers/auth_provider.dart';
import 'package:p17/providers/observation_provider.dart';
import 'package:p17/services/storage_service.dart';
import 'package:p17/services/geolocation_service.dart';
import 'package:p17/models/observation.dart';
import 'package:p17/utils/helpers.dart';
import 'package:p17/widgets/common_widgets.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class NewObservationScreen extends StatefulWidget {
  const NewObservationScreen({Key? key}) : super(key: key);

  @override
  State<NewObservationScreen> createState() => _NewObservationScreenState();
}

class _NewObservationScreenState extends State<NewObservationScreen> {
  final _speciesNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _selectedPhoto;
  DateTime _observationDate = DateTime.now();
  double? _latitude;
  double? _longitude;
  String _selectedSpeciesType = 'bird';

  final _storageService = StorageService();
  final _geolocationService = GeolocationService();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final position = await _geolocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        message: 'Erreur lors de la récupération de la localisation',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await _storageService.takePhoto();
      if (photo != null) {
        setState(() {
          _selectedPhoto = photo;
        });
      }
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        message: 'Erreur lors de la capture de la photo',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await _storageService.pickPhotoFromGallery();
      if (photo != null) {
        setState(() {
          _selectedPhoto = photo;
        });
      }
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        message: 'Erreur lors de la sélection de la photo',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      SnackBarHelper.showSnackBar(
        context,
        message: 'Localisation requise',
        type: SnackBarType.error,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      SnackBarHelper.showSnackBar(
        context,
        message: 'Vous devez être connecté',
        type: SnackBarType.error,
      );
      return;
    }

    try {
      final obsProvider = context.read<ObservationProvider>();
      final now = DateTime.now();
      final observationId = const Uuid().v4();

      String? photoUrl;
      String photoStoragePath = '';

      if (_selectedPhoto != null) {
        photoUrl = await _storageService.uploadObservationPhoto(
          photoFile: _selectedPhoto!,
          userId: authProvider.currentUser!.uid,
          observationId: observationId,
        );
        photoStoragePath = _storageService.getObservationPhotoPath(
          userId: authProvider.currentUser!.uid,
          observationId: observationId,
        );
      }

      final observation = Observation(
        id: observationId,
        userId: authProvider.currentUser!.uid,
        speciesName: _speciesNameController.text.trim(),
        speciesType: _selectedSpeciesType,
        description: _descriptionController.text.trim(),
        notes: _notesController.text.trim(),
        observationDate: _observationDate,
        latitude: _latitude!,
        longitude: _longitude!,
        photoUrl: photoUrl,
        photoStoragePath: photoStoragePath,
        createdAt: now,
        updatedAt: now,
        isPublic: false,
      );

      final success = await obsProvider.addObservation(observation);

      if (!mounted) return;

      if (success) {
        SnackBarHelper.showSnackBar(
          context,
          message: 'Observation enregistrée',
          type: SnackBarType.success,
        );
        Navigator.of(context).pop();
      } else {
        SnackBarHelper.showSnackBar(
          context,
          message:
              obsProvider.errorMessage ?? 'Erreur lors de l\'enregistrement',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        message: 'Erreur: $e',
        type: SnackBarType.error,
      );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle observation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedPhoto != null
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedPhoto!,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton.small(
                              onPressed: () =>
                                  setState(() => _selectedPhoto = null),
                              backgroundColor: Colors.red,
                              child: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 48),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _takePhoto,
                                  icon: const Icon(Icons.camera),
                                  label: const Text('Caméra'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _pickPhoto,
                                  icon: const Icon(Icons.image),
                                  label: const Text('Galerie'),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                initialValue: _selectedSpeciesType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'espèce',
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    [
                          'bird',
                          'plant',
                          'insect',
                          'mammal',
                          'reptile',
                          'amphibian',
                          'fish',
                          'other',
                        ]
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(_getTypeLabel(type)),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSpeciesType = value);
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
                  labelText: 'Notes additionnelles',
                  prefixIcon: Icon(Icons.note),
                  hintText: '(Optionnel)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Date
              ListTile(
                title: const Text('Date de l\'observation'),
                subtitle: Text(DateTimeHelper.formatDateTime(_observationDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _observationDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _observationDate = date);
                  }
                },
              ),
              const SizedBox(height: 8),

              // Localisation
              ListTile(
                title: const Text('Localisation'),
                subtitle: _latitude != null && _longitude != null
                    ? Text(
                        LocationHelper.formatCoordinatesShort(
                          _latitude!,
                          _longitude!,
                        ),
                      )
                    : const Text('Localisation en cours...'),
                trailing: const Icon(Icons.location_on),
                onTap: _getLocation,
              ),
              const SizedBox(height: 24),

              // Boutons
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Enregistrer l\'observation'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
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
