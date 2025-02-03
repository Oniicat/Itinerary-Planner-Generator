import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewTrip extends StatefulWidget {
  final String itineraryName;
  final List<Map<String, dynamic>> selectedDayDestinations;
  final Set<Marker> markers;

  const ViewTrip({
    Key? key,
    required this.itineraryName,
    required this.selectedDayDestinations,
    required this.markers,
  }) : super(key: key);

  @override
  State<ViewTrip> createState() => _ViewTripState();
}

class _ViewTripState extends State<ViewTrip> {
  LatLng? userLocation;
  GoogleMapController? mapController;
  Map<String, dynamic>? _selectedDestination;
  Set<Marker> markers = {};
  late Map<int, List<Map<String, dynamic>>> dailyDestinations;
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
        ],
      ),
    );
  }

  void printstate() {
    print('these are the destinations: $dailyDestinations');
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    markers = widget.markers;

    for (var destination in widget.selectedDayDestinations) {
      LatLng position =
          LatLng(destination['latitude'], destination['longitude']);
      markers.add(
        Marker(
          markerId: MarkerId(
              'marker_${destination['latitude']}_${destination['longitude']}'),
          position: position,
          infoWindow: InfoWindow(title: destination['name']),
          onTap: () {
            setState(() {
              _selectedDestination = destination;
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButtonRed(),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 50.0),
                  height: MediaQuery.of(context).size.height *
                      0.55, // 50% of screen height
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: userLocation ?? LatLng(0, 0),
                      zoom: 12,
                    ),
                    markers: markers,
                    // Show polylines conditionally
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),
              ),

              // Display the filtered search results below the search bar
            ],
          ),
          SizedBox(height: 20),
          //container of the destination details
          Container(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1.0),
            ),
            child: _buildDestinationDetails(),
          ),
        ],
      ),
    );
  }
}
