import 'package:firestore_basics/directions_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firestore_basics/directions_model.dart';

class Setdays extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems; // Accept destinations here

  // Constructor to receive destinations
  Setdays({required this.cartItems});
  @override
  _SetdaysState createState() => _SetdaysState();
}

class _SetdaysState extends State<Setdays> {
  GoogleMapController? mapController;
  Set<Marker> markers = {}; // Markers for destinations
  LatLng? userLocation; // User's location
  Directions? _info; // Route information
  Set<Polyline> polylines = {}; // Polylines for the route
  bool showRoute = false; // Toggle to show/hide route
  Map<String, dynamic>? _selectedDestination; //current items in the cart
  bool isLoading = false;

//add days
  List<Map<String, dynamic>> cartItems = []; // Main cart items
  Map<int, List<Map<String, dynamic>>> dailyDestinations =
      {}; // Destinations grouped by day
  int numberOfDays = 0; // Total days
  int selectedDay = 0; // Currently selected day

  void _setDays() {
    showDialog(
      context: context,
      builder: (context) {
        int tempDays = numberOfDays; // Temporary variable for dialog input
        return AlertDialog(
          title: Text('Set Number of Days'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter number of days'),
            onChanged: (value) {
              tempDays = int.tryParse(value) ?? numberOfDays;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  numberOfDays = tempDays;
                  dailyDestinations.clear();
                  for (int i = 1; i <= numberOfDays; i++) {
                    dailyDestinations[i] = [];
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void _showDayDetails(int day) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<Map<String, dynamic>> destinations = dailyDestinations[day]!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Destinations for Day $day',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      var destination = destinations[index];
                      return ListTile(
                        title: Text(destination['name']),
                        subtitle: Text(destination['address']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setModalState(() {
                              destinations.removeAt(index);
                            });
                            setState(() {
                              dailyDestinations[day] = destinations;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Fetch destinations from the cart
                    List<Map<String, dynamic>> cartItems = _fetchCartItems()
                        .where((cartItem) => !destinations.any((destination) =>
                            destination['name'] == cartItem['name']))
                        .toList();

                    if (cartItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No more destinations to add.')),
                      );
                      return;
                    }

                    // Show a dialog to select items from the filtered cart
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Select Destination from Cart'),
                          content: Container(
                            width: double.maxFinite,
                            child: ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return ListTile(
                                  title: Text(item['name']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item['address'] ??
                                          "No address provided"),
                                      Text("Latitude: ${item['latitude']}"),
                                      Text("Longitude: ${item['longitude']}"),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      // Add the selected cart item to the day's destinations
                                      setModalState(() {
                                        destinations.add(item);
                                      });
                                      setState(() {
                                        dailyDestinations[day] = destinations;
                                      });

                                      // Remove the item from the cart (widget.cartItems)
                                      // setState(() {
                                      //   widget.cartItems.removeWhere(
                                      //       (cartItem) =>
                                      //           cartItem['name'] ==
                                      //           item['name']);
                                      // });

                                      Navigator.pop(context); // Close dialog
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                              },
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Add Destination from Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// function for transfering the items from the cart
  List<Map<String, dynamic>> _fetchCartItems() {
    // Replace this with your actual logic to fetch cart items
    return widget.cartItems;
  }

  void _updateMapForSelectedDay() {
    setState(() {
      markers.clear();
      polylines.clear();

      List<Map<String, dynamic>> destinations =
          dailyDestinations[selectedDay] ?? [];

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

      _generateRoute(destinations
          .map((d) => LatLng(d['latitude'], d['longitude']))
          .toList());
    });
  }

  Widget _buildDayButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(numberOfDays, (index) {
          int day = index + 1;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedDay = day;
                });
                _showDayDetails(day);
              },
              child: Text('Day $day'),
            ),
          );
        }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializemap();
    _getUserLocation();
    //_generateRoute([]);
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
        _generateRoute([]);
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

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = widget.cartItems.removeAt(oldIndex);
      widget.cartItems.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Your Trip'),
        actions: [
          IconButton(
            onPressed: _setDays,
            icon: Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: Column(
        children: [
          if (numberOfDays > 0) _buildDayButtons(),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLocation ?? LatLng(0, 0),
                zoom: 12,
              ),
              markers: markers,
              polylines: polylines,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}
