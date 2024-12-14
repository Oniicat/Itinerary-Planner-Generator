import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const LatLng _initialCameraPosition =
      LatLng(14.483173939202675, 121.18757019252007);

  static const LatLng _destination1 =
      LatLng(14.48278480841818, 121.18716191070331);
  static const LatLng _Jabee = LatLng(14.492796103262384, 121.18167384328976);
  static const LatLng _Mcdo = LatLng(14.49208236393375, 121.18131129901126);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialCameraPosition,
        zoom: 12, // Set default zoom level
      ),
      markers: {
        Marker(
            markerId: MarkerId("destination1"),
            icon: BitmapDescriptor.defaultMarker,
            position: _destination1),
        Marker(
            markerId: MarkerId("Jollibee"),
            icon: BitmapDescriptor.defaultMarker,
            position: _Jabee),
        Marker(
            markerId: MarkerId("Mcdo"),
            icon: BitmapDescriptor.defaultMarker,
            position: _Mcdo)
      },
    ));
  }
}

// Fetch destination from Firestore
Future<List<Map<String, dynamic>>> fetchAllDestinations() async {
  var snapshot = await FirebaseFirestore.instance
      .collection('Destinations')
      .get(); // Fetch all documents

  if (snapshot.docs.isNotEmpty) {
    List<Map<String, dynamic>> destinations = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double latitude = data['latitude']?.toDouble() ?? 0.0;
      double longitude = data['longitude']?.toDouble() ?? 0.0;
      String name = data['name'] ??
          'Unknown Destination'; // if the name of=r destination is null
      destinations.add({
        'latitude': latitude,
        'longitude': longitude,
        'name': name, // Include the name in the map
      });

      print(
          "Fetched data: latitude = $latitude, longitude = $longitude, name = $name");
    }

    return destinations;
  } else {
    print("No destinations found!");
    throw Exception('No destinations found');
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController; // Use nullable GoogleMapController
  Set<Marker> _markers = {}; // Store markers in a set

  @override
  void initState() {
    super.initState();
    _fetchDestinations(); // Start fetching all destinations
  }

  Future<void> _fetchDestinations() async {
    try {
      var destinationData = await fetchAllDestinations();
      setState(() {
        _markers.clear(); // Clear existing markers

        for (var destination in destinationData) {
          // Add a marker for each destination
          _markers.add(Marker(
            markerId: MarkerId(
                'destination_marker_${destination['latitude']}_${destination['longitude']}'),
            position: LatLng(
              destination['latitude']?.toDouble() ?? 0.0,
              destination['longitude']?.toDouble() ?? 0.0,
            ),
            infoWindow: InfoWindow(title: destination['name']),
          ));
        }

        if (_markers.isNotEmpty) {
          // Set the camera to the first destination's location if markers are available
          mapController?.animateCamera(
            CameraUpdate.newLatLng(_markers.first.position),
          );
        }
      });
    } catch (e) {
      print('Error fetching destinations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Screen')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(14.483173939202675, 121.18757019252007),
          zoom: 12,
        ),
        markers: _markers, // Display all markers
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}
