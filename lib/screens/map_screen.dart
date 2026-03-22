import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:p17/providers/observation_provider.dart';
import 'package:p17/providers/auth_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      final obsProvider = context.read<ObservationProvider>();
      await obsProvider.loadUserObservations(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des observations'),
      ),
      body: Center(
        child: Consumer<ObservationProvider>(
          builder: (context, obsProvider, _) {
            if (obsProvider.isLoading) {
              return const CircularProgressIndicator();
            }

            if (obsProvider.observations.isEmpty) {
              return const Text('Aucune observation');
            }

            return ListView(
              children: [
                Container(
                  height: 400,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Intégration Google Maps à venir'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observations: ${obsProvider.observations.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      for (var obs in obsProvider.observations.take(5))
                        ListTile(
                          title: Text(obs.speciesName),
                          subtitle: Text(
                              '${obs.latitude.toStringAsFixed(3)}, ${obs.longitude.toStringAsFixed(3)}'),
                          trailing: const Icon(Icons.location_on),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
