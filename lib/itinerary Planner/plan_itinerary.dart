import 'dart:async';

import 'package:firestore_basics/Directions/directions_repository.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/Ui/top_icon.dart';
import 'package:firestore_basics/Ui/white_buttons.dart';
import 'package:firestore_basics/itinerary%20Planner/itinerary_summary.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firestore_basics/Directions/directions_model.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Mapwithitems extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems; // Accept destinations here

  // Constructor to receive destinations
  const Mapwithitems({super.key, required this.cartItems});
  @override
  _MapwithitemsState createState() => _MapwithitemsState();
}

class _MapwithitemsState extends State<Mapwithitems> {
  //variable for map and destinations
  GoogleMapController? mapController;
  Set<Marker> markers = {}; // Markers for destinations
  LatLng? userLocation; // User's location
  Directions? _info; // Route information
  Set<Polyline> polylines = {}; // Polylines for the route
  bool showRoute = false; // Toggle to show/hide route
  final TextEditingController itineraryNameController =
      TextEditingController(); // for naming the itinerary
  bool isLoading = false; // for triggering user location fetch
  LocationData? currentLocation; // Current user location

  //Allocation of destinations to days
  List<Map<String, dynamic>> cartItems = []; // Main cart items
  Map<int, List<Map<String, dynamic>>> dailyDestinations =
      {}; // Destinations grouped by day

  int numberOfDays = 0; // Total days

  int selectedDay = 0; // Currently selected day

//builder for the buttons of days
  Widget _buildDayDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: (numberOfDays >= 1 && numberOfDays <= 7) ? numberOfDays : 0,
          items: [
            DropdownMenuItem(
              value: 0, // UI only
              child: Text(
                '0',
                style: TextStyle(color: Color(0xFFA52424)),
              ),
            ),
            ...List.generate(7, (index) => index + 1)
                .map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(
                        '$day',
                        style: TextStyle(color: Color(0xFFA52424)),
                      ),
                    ))
                .toList(),
          ],
          onChanged: (value) {
            if (value != null && value != 0) {
              // Ignore "0" in logic
              setState(() {
                numberOfDays = value;
                dailyDestinations.clear();
                for (int i = 1; i <= numberOfDays; i++) {
                  dailyDestinations[i] = [];
                }
              });
            }
          },
        ),
      ],
    );
  }

  // extension function to check if a destination is already in any day
  bool isDestinationAlreadyAdded(Map<String, dynamic> destination) {
    for (var dayDestinations in dailyDestinations.values) {
      if (dayDestinations.any((d) => d['name'] == destination['name'])) {
        return true; // Destination is already added
      }
    }
    return false;
  }

//function for showing the details of the day
  Widget showDayDetails(int day) {
    List<Map<String, dynamic>> destinations = dailyDestinations[day]!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destinations for Day $day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ReorderableListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  // Fix index adjustment during reordering
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                    _updateMapForSelectedDay();
                  }
                  final item = destinations.removeAt(oldIndex);
                  destinations.insert(newIndex, item);

                  // Update the day's destinations
                  dailyDestinations[day] = destinations;
                });
              },
              children: List.generate(destinations.length, (index) {
                // Reverse the list to ensure that the route starts from the top
                var destination = destinations[destinations.length - index - 1];
                return Card(
                  key: ValueKey(destination),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(destination['name']),
                    subtitle: Text(destination['address']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          destinations.removeAt(index);
                          dailyDestinations[day] = destinations;
                          _updateMapForSelectedDay();
                        });
                      },
                    ),
                  ),
                );
              }),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (destinations.isEmpty)
                  Center(
                    child: Text(
                      'No destinations added yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Color(0xFFA52424)),
                    ),
                    onPressed: () async {
                      List<Map<String, dynamic>> cartItems = _fetchCartItems()
                          .where((cartItem) =>
                              !isDestinationAlreadyAdded(cartItem))
                          .toList();

                      if (cartItems.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text('No more destinations to add.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

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
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          destinations.add(item);
                                          dailyDestinations[day] = destinations;
                                          _updateMapForSelectedDay();
                                        });

                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'Add Destination from Cart',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// function for transfering the items from the cart
  List<Map<String, dynamic>> _fetchCartItems() {
    // Replace this with your actual logic to fetch cart items
    return widget.cartItems;
  }

//not used yet
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

      //_generateRoute();
      fetchAndShowCurrentLocation();
      startLocationStream();
    });
  }

//arrangement of buttons of days
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
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  selectedDay == day ? Color(0xFFA52424) : Colors.white,
                ),
                foregroundColor: WidgetStateProperty.all(
                  selectedDay == day ? Colors.white : Color(0xFFA52424),
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedDay = day;
                });
                showDayDetails(day);
                _updateMapForSelectedDay();
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
    // _initializemap();
    _getUserLocation();
    //_getcurrentLocation();
    // _generateRoute([]);
    //_onGenerateRouteClicked();
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

  void _getCurrentLocation() {
    Location location = Location();

    // Fetch the initial location
    location.getLocation().then((locationData) {
      setState(() {
        currentLocation = locationData;

        // Add the initial marker for the user's location
        markers.add(
          Marker(
            markerId: MarkerId("MyLocation"),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
          ),
        );
        //_generateRoute();
      });
    });

    // Listen for location changes
    location.onLocationChanged.listen((newLoc) {
      setState(() {
        currentLocation = newLoc;

        markers.removeWhere((marker) => marker.markerId.value == "MyLocation");
        // Update the marker's position dynamically

        markers.add(
          Marker(
            markerId: MarkerId("MyLocation"),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
          ),
        );
        userLocation = LatLng(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        );
      });
    });
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
        // _generateRoute();
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
      // _generateRoute();
      mapController?.animateCamera(CameraUpdate.newLatLng(userLocation));
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
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
                style: const TextStyle(fontSize: 18.0, color: Colors.black),
              )
            : Text(
                'Generating route...',
                style: const TextStyle(fontSize: 18.0, color: Colors.black),
              ),
      );
    }
  }

//camera position sa map
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
      print("Error fetching user location: $e");
    }
  }

//saving to firestore
  Future<void> saveItinerary() async {
    final itineraryData = {
      'itineraryName': 'Sample Itinerary',
      'travelerName': 'John Doe',
      'numberOfDays': numberOfDays,
      'createdAt': FieldValue.serverTimestamp(),
      'days': Map.fromIterable(
        List.generate(numberOfDays, (index) => index + 1),
        key: (day) => day.toString(),
        value: (day) {
          return dailyDestinations[day]!.map((destination) {
            return {
              'name': destination['name'],
              'latitude': destination['latitude'],
              'longitude': destination['longitude'],
              'address': destination['address'],
            };
          }).toList();
        },
      ),
    };

    try {
      final itineraryRef =
          FirebaseFirestore.instance.collection('Itineraries').doc();
      await itineraryRef.set(itineraryData);
      print('Itinerary saved successfully!');
    } catch (e) {
      print('Error saving itinerary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        // Left-side button
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BackButtonWhite(),
        ),

        // Right-side button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Closedbutton(),
          ),
        ],
      ),
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 15),
              child: Text(
                '3 of 3',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            // Google Map
            Center(
              child: Container(
                padding: EdgeInsets.only(bottom: 120),
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.9,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: userLocation ?? LatLng(0, 0),
                    zoom: 12,
                  ),
                  markers: markers,
                  polylines: showRoute ? polylines : {},
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                ),
              ),
            ),
            // Back Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                      onPressed: () {
                        String itineraryName = itineraryNameController.text;
                        if (itineraryName.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text('Please name your trip'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                        if (numberOfDays == 0) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text('Please set up number of days'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                        // Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text(
                                'Finish planning your trip and proceed to summary?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TripSummary(
                                        itineraryName: itineraryName,
                                        numberOfDays: numberOfDays,
                                        dailyDestinations: dailyDestinations,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Proceed'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFA52424),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      child: Text('Done')),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 600), // Adjust as needed
                child: _showdistanddur(),
              ),
            ),

            // Draggable Scrollable Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Name your trip',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 30),
                                  Row(
                                    children: [
                                      Text(
                                        'How many days:',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFFA52424),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 8),
                                      _buildDayDropdown(),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 40,
                                child: TextField(
                                  controller: itineraryNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter name of trip',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              if (numberOfDays > 0) _buildDayButtons(),
                              if (selectedDay > 0)
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: showDayDetails(selectedDay),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
