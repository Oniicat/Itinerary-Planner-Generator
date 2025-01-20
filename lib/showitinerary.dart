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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializemap();
    _getUserLocation();
    _generateRoute([]);
    //_onGenerateRouteClicked();
  }

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

  void _onGenerateRouteClicked() {
    List<LatLng> positions = markers.map((marker) => marker.position).toList();

    // Ensure the user's location is included as the starting point
    if (userLocation != null) {
      positions.insert(0, userLocation!);
    }

    _generateRoute(positions);

    // Set the route visibility to true
    setState(() {
      showRoute = true;
    });
  }

  Future<void> fetchAndShowCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Update markers and move camera
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
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 15),
      );
    } catch (e) {
      // Show error as a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

//kunyare lang to
  Future<void> _getUserLocation() async {
    //Position position = await getCurrentPosition();
    try {
      // Fetch current location (for demonstration purposes)
      setState(() {
        //Position position = await getCurrentPosition();
        userLocation = //LatLng(position.latitude, position.longitude);
            LatLng(
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
              ElevatedButton(
                onPressed: () async {
                  await fetchAndShowCurrentLocation();
                  _onGenerateRouteClicked();
                },
                child: Icon(Icons.my_location, size: 30, color: Colors.red),
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

class GetUserLocation extends StatefulWidget {
  @override
  State<GetUserLocation> createState() => _GetUserLocationState();
}

class _GetUserLocationState extends State<GetUserLocation> {
  LatLng initialLocation = LatLng(14.499157, 121.187020);
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map Example"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
            initialCameraPosition:
                CameraPosition(target: initialLocation, zoom: 13),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await fetchAndShowCurrentLocation();
        },
        child: Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }

  Future<void> fetchAndShowCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      Position position = await getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Update markers and move camera
      setState(() {
        markers = {
          Marker(
            markerId: MarkerId("MyLocation"),
            position: userLocation,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
          ),
        };
      });

      googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 15),
      );
    } catch (e) {
      // Show error as a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
}
