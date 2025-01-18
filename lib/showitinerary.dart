import 'package:firestore_basics/directions_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firestore_basics/directions_model.dart';
import 'package:firestore_basics/cart.dart';

class Mapwithitems extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems; // Accept destinations here

  // Constructor to receive destinations
  Mapwithitems({required this.cartItems});
  @override
  _MapwithitemsState createState() => _MapwithitemsState();
}

class _MapwithitemsState extends State<Mapwithitems> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng? userLocation;
  Directions? _info; // Route information
  Set<Polyline> polylines = {};
  bool showRoute = false;
  Map<String, dynamic>? _selectedDestination;

  @override
  void initState() {
    super.initState();
    _initializemap();
    _getUserLocation();
    _generateRoute([]);
    //_onGenerateRouteClicked();
  }

//kunyare lang to
  Future<void> _getUserLocation() async {
    try {
      // Fetch current location (for demonstration purposes)
      setState(() {
        userLocation = LatLng(
            14.499111632246139, 121.18714131749572); // Example coordinates

        // Add marker for user's location
        markers.add(
          Marker(
            markerId: MarkerId("user_location"),
            position: userLocation!,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue), // Custom marker color
          ),
        );
      });

      // Move the camera to the user's location (ensure it's not null)
      if (mapController != null && userLocation != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation!, 14), // Adjust zoom level
        );
      }
    } catch (e) {
      print("Error fetching user location: $e");
    }
  }

  Future<void> _initializeScreen() async {
    await _initializemap();
  }

  Future<void> _initializemap() async {
    try {
      // Directly use the destinations passed into the MapScreen
      setState(() {
        markers.clear(); // Clear any pre-existing markers
        showRoute = true;
        List<LatLng> destinationPositions = [];
        for (var destination in widget.cartItems) {
          final position =
              LatLng(destination['latitude'], destination['longitude']);
          destinationPositions.add(position);

          final markerId =
              'destination_marker_${destination['latitude']}_${destination['longitude']}';

          markers.add(Marker(
            markerId: MarkerId(markerId),
            position: position,
            onTap: () {
              setState(() {
                _selectedDestination =
                    destination; // Update the selected destination
              });
            },
          ));
        }
        polylines.clear();
      });
    } catch (e) {
      print('Error initializing screen: $e');
    }
  }

//for generating the travel route
  Future<void> _generateRoute(List<LatLng> positions) async {
    showRoute = true;
    List<LatLng> positions = markers.map((marker) => marker.position).toList();
    List<LatLng> routePoints = [];

    for (int i = 0; i < positions.length - 1; i++) {
      final directions = await DirectionsRepository().getDirections(
        userLocation: positions[i],
        pointB: positions[i + 1],
      );

      if (directions != null) {
        // Update route points
        routePoints.addAll(directions.polylinePoints
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList());

        // Update the _info variable to hold total distance and duration
        setState(() {
          _info = directions;
        });
      }
    }

    // Update the polyline with the new route
    setState(() {
      polylines = {
        Polyline(
          polylineId: PolylineId('itinerary_route'),
          color: Colors.purple,
          width: 5,
          points: routePoints,
        ),
      };
    });
  }

//for showing the distance and duration
  Widget _showdistanddur() {
    List<LatLng> positions = markers.map((marker) => marker.position).toList();
    if (positions.length < 2) {
      return SizedBox.shrink();
    } else
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 12.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black, width: 2.0),
        ),
        child: _info != null
            ? Text(
                'Duration: ${_info?.totalDuration}, Distance: ${_info?.totalDistance}',
                style: const TextStyle(fontSize: 18.0, color: Colors.black),
              )
            : Text(
                'Generating route...',
                style: const TextStyle(fontSize: 18.0, color: Colors.black),
              ),
      );
  }

//

//destination info when a marker is clicked
  Widget _buildDestinationDetails() {
    if (_selectedDestination == null) {
      return Center(child: Text('Tap on a destination to see details'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedDestination!['name'] ?? '',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            "Address: ${_selectedDestination!['address'] ?? ''}",
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 5),
          Text(
            "Description: ${_selectedDestination!['description'] ?? ''}",
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 5),
          Text(
            "Contact: ${_selectedDestination!['contact'] ?? ''}",
            style: TextStyle(fontSize: 13),
          ),
          // ElevatedButton(onPressed:() {
          //   removeMarker(position);
          // }, child: Text('Remove Destination')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Positioned(top: 20, left: 65, child: _showdistanddur()),
          SizedBox(height: 10),
          Stack(
            children: [
              Center(
                child: Container(
                  //padding: EdgeInsets.only(top: 50.0),
                  height: MediaQuery.of(context).size.height *
                      0.5, // 50% of screen height
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: userLocation ?? LatLng(0, 0),
                      zoom: 12,
                    ),
                    markers: markers,
                    polylines: showRoute
                        ? polylines
                        : {}, // Show polylines conditionally
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1.0),
            ),
            child: _buildDestinationDetails(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_circle_left,
                  size: 50,
                  color: Color(0xFFA52424),
                ),
                onPressed: () {
                  Navigator.pop(context); // Simple back navigation
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  Icons.arrow_circle_right,
                  size: 50,
                  color: Color(0xFFA52424),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
