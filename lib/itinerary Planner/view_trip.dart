import 'dart:async';
import 'package:firestore_basics/Directions/directions_model.dart';
import 'package:firestore_basics/Directions/directions_repository.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewTrip extends StatefulWidget {
  final String itineraryName;
  final List<Map<String, dynamic>> selectedDayDestinations;
  final Set<Marker> markers;
  final int selectedDay;
  const ViewTrip({
    Key? key,
    required this.itineraryName,
    required this.selectedDayDestinations,
    required this.markers,
    required this.selectedDay,
  }) : super(key: key);

  @override
  State<ViewTrip> createState() => _ViewTripState();
}

class _ViewTripState extends State<ViewTrip> {
  LatLng? userLocation;
  Set<Polyline> polylines = {};
  GoogleMapController? mapController;
  Map<String, dynamic>? selectedDestination;
  Set<Marker> markers = {};
  late List<Map<String, dynamic>> dailyDestinations;
  bool showRoute = false;
  Directions? _info;
  bool isLoading = false; // for triggering user location fetch

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    dailyDestinations = widget.selectedDayDestinations;
    markers = widget.markers;
    selectedDay = widget.selectedDay;
    _updateMapForSelectedDay();
    print('selected day: $selectedDay');
    _generateRoute();
    _showdistanddur();
    print('markers: $markers');
  }

  Future<void> _getUserLocation() async {
    try {
      // Fetch current location (for demonstration purposes)
      setState(() {
        userLocation = LatLng(
            14.499111632246139, 121.18714131749572); // Example coordinates

        // Add marker for user's location
        // markers.add(
        //   Marker(
        //     markerId: MarkerId("user_location"),
        //     position: userLocation!,
        //     infoWindow: InfoWindow(title: "Your Location"),
        //     icon: BitmapDescriptor.defaultMarkerWithHue(
        //         BitmapDescriptor.hueBlue), // Custom marker color
        //   ),
        // );
      });

      // Move the camera to the user's location (ensure it's not null)
      if (mapController != null && userLocation != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation!, 14), // Adjust zoom level
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user location: $e");
      }
    }
  }

  int selectedDay = 0;
  Widget _buildDestinationDetails() {
    if (selectedDestination == null) {
      return Center(child: Text('Tap on a destination to see details'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedDestination!['name'] ?? '',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            "Address: ${selectedDestination!['address'] ?? ''}",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void printstate() {
    print('these are the destinations: $dailyDestinations');
  }

// Example helper functions (implement according to your format):
  double _parseDistance(String distanceText) {
    // Assuming distanceText is like "5.3 km"
    // Remove non-numeric parts and convert to double.
    return double.tryParse(distanceText.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }

  double _parseDuration(String durationText) {
    // Assuming durationText is like "15 mins"
    return double.tryParse(durationText.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }

//for showing the distance and duration
  Widget _showdistanddur() {
    List<LatLng> positions = markers.map((marker) => marker.position).toList();
    if (positions.length < 2) {
      return SizedBox.shrink();
    } else {
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
                style: const TextStyle(fontSize: 15.0, color: Colors.black),
              )
            : Text(
                'Generating route...',
                style: const TextStyle(fontSize: 15.0, color: Colors.black),
              ),
      );
    }
  }

  //for generating the travel route
  Future<void> _generateRoute() async {
    showRoute = true;
    // Use the markers to get positions
    List<LatLng> positions = markers.map((marker) => marker.position).toList();
    if (positions.length < 2) return; // Not enough points to create a route

    List<LatLng> routePoints = [];
    double totalDistanceValue = 0;
    double totalDurationValue = 0;

    for (int i = 0; i < positions.length - 1; i++) {
      try {
        final directions = await DirectionsRepository().getDirections(
          userLocation: positions[i],
          pointB: positions[i + 1],
        );

        // Parse the distance and duration from the directions object.
        // You need to implement these helpers based on your API response format.
        double distance =
            _parseDistance(directions.totalDistance); // e.g., "5.3 km" -> 5.3
        double duration =
            _parseDuration(directions.totalDuration); // e.g., "15 mins" -> 15

        totalDistanceValue += distance;
        totalDurationValue += duration;

        // Add polyline points from this segment.
        routePoints.addAll(directions.polylinePoints);
      } catch (e) {
        print('Error fetching directions for segment $i: $e');
      }
    }

    // Update the _info object with aggregated route details.
    setState(() {
      _info = Directions(
        totalDistance: '${totalDistanceValue.toStringAsFixed(1)} km',
        totalDuration: '${totalDurationValue.toStringAsFixed(1)} mins',
        polylinePoints: routePoints,
      );

      polylines = {
        Polyline(
          polylineId: PolylineId('itinerary_route'),
          color: Colors.purple,
          width: 5,
          points: routePoints,
        ),
      };
    });

    print("Added ${polylines.length} polyline segments for the route.");
  }

  void _updateMapForSelectedDay() {
    setState(() {
      markers.clear();
      polylines.clear();

      // No need to use selectedDay; directly use the updated dailyDestinations list
      List<Map<String, dynamic>> destinations = dailyDestinations;

      for (var destination in destinations) {
        LatLng position =
            LatLng(destination['latitude'], destination['longitude']);
        markers.add(Marker(
          markerId: MarkerId(
              'marker_${destination['latitude']}_${destination['longitude']}'),
          position: position,
          infoWindow: InfoWindow(title: destination['name']),
        ));
      }

      _generateRoute();
      _showdistanddur();
      fetchAndShowCurrentLocation();
      startLocationStream();
    });
  }

  //permission for accessing gps
  Future<Position> getCurrentPosition() async {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception("Location services are disabled. Please enable them.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition();
  }

// Your one-time fetch function remains the same
  Future<void> fetchAndShowCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId("MyLocation"),
            position: userLocation,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
          ),
        );
        _generateRoute();
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 15),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// New function for live tracking using a stream:
  StreamSubscription<Position>? _positionStreamSubscription;

  void startLocationStream() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // meters
      ),
    ).listen((Position position) {
      LatLng userLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        // Remove the old marker and add a new one:
        markers.removeWhere((marker) => marker.markerId.value == "MyLocation");
        markers.add(
          Marker(
            markerId: MarkerId("MyLocation"),
            position: userLocation,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
          ),
        );
      });
      // Update the route and camera position:
      _generateRoute();
      mapController?.animateCamera(CameraUpdate.newLatLng(userLocation));
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BackButtonRed(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Stack(
            children: [
              Center(
                child: Container(
                  //padding: EdgeInsets.only(top: 50.0),
                  height: MediaQuery.of(context).size.height *
                      0.60, // 50% of screen height
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: userLocation ?? LatLng(0, 0),
                      zoom: 12,
                    ),
                    markers: markers,
                    polylines: showRoute ? polylines : {},
                    // Show polylines conditionally
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),
              ),

              Center(
                child: _showdistanddur(),
              )

              // Display the filtered search results below the search bar
            ],
          ),

          //container of the destination details
          // Container(
          //   height: MediaQuery.of(context).size.height * 0.20,
          //   width: MediaQuery.of(context).size.width * 0.9,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     border: Border.all(color: Colors.grey, width: 1.0),
          //   ),
          //   child: _buildDestinationDetails(),
          // ),
        ],
      ),
    );
  }
}
