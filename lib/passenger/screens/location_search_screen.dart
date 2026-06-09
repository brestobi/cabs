import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/place_provider.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  final bool isPickup;
  const LocationSearchScreen({super.key, required this.isPickup});

  @override
  ConsumerState<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String value) async {
    if (value.length > 2) {
      final results = await ref.read(placeServiceProvider).getAutocomplete(value);
      setState(() {
        _suggestions = results;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickup ? 'Set Pickup Location' : 'Set Dropoff Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(suggestion['description']),
                  onTap: () async {
                    final details = await ref.read(placeServiceProvider).getPlaceDetails(suggestion['placeId']);
                    if (details != null && mounted) {
                      context.pop({
                        'address': suggestion['description'],
                        'lat': details['geometry']['location']['lat'],
                        'lng': details['geometry']['location']['lng'],
                      });
                    }
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
