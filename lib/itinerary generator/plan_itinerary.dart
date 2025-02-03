import 'package:firestore_basics/Directions/directions_model.dart';
import 'package:firestore_basics/Directions/directions_repository.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/itinerary%20Planner/tripsummary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PlanItinerary extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int numberOfDays;
  const PlanItinerary(
      {super.key, required this.cartItems, required this.numberOfDays});

  @override
  State<PlanItinerary> createState() => _PlanItineraryState();
}

class _PlanItineraryState extends State<PlanItinerary> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Map<String, dynamic>? _selectedDestination;
  LatLng? userLocation =
      LatLng(14.499111632246139, 121.18714131749572); //dummy muna
  List<Map<String, dynamic>> cartItems = [];
  int selectedDay = 0;
  int numberOfDays = 0;
  int days = 0;
  bool showRoute = false;
  Directions? _info; // Route information
  Set<Polyline> polylines = {}; // Polylines for the route
  final TextEditingController itineraryNameController =
      TextEditingController(); // for naming the itinerary

  LocationData? currentLocation; // Current user location

  Map<int, List<Map<String, dynamic>>> dailyDestinations = {};

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

  Widget _buildDayDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: (numberOfDays >= 1 && numberOfDays <= 7) ? numberOfDays : 1,
          items: List.generate(7, (index) => index + 1)
              .map((day) => DropdownMenuItem(
                    value: day,
                    child: Text('$day'),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                numberOfDays = value; // Update the number of days
                dailyDestinations.clear(); // Clear and reset destinations
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

  void dailydestinationlist() {
    setState(() {
      numberOfDays = widget.numberOfDays; // Update the number of days
      dailyDestinations.clear(); // Clear and reset destinations
      for (int i = 1; i <= numberOfDays; i++) {
        dailyDestinations[i] = [];
      }
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

      markers.add(Marker(
        markerId: MarkerId('user_location'),
        position: userLocation!,
        infoWindow: InfoWindow(title: 'This is you nigga'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      _generateRoute(destinations
          .map((d) => LatLng(d['latitude'], d['longitude']))
          .toList());
    });
  }

  // function for transfering the items from the cart
  List<Map<String, dynamic>> _fetchCartItems() {
    // Replace this with your actual logic to fetch cart items
    return widget.cartItems;
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
                  }
                  final item = destinations.removeAt(oldIndex);
                  destinations.insert(newIndex, item);

                  // Update the day's destinations
                  dailyDestinations[day] = destinations;
                });
              },
              children: List.generate(destinations.length, (index) {
                var destination = destinations[index];
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
        _generateRoute([]);
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

      // ignore: unnecessary_null_comparison
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

  @override
  void initState() {
    //numberOfDays = widget.numberOfDays;
    cartItems = widget.cartItems;
    dailydestinationlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: 65, left: 65, child: _showdistanddur()),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButtonRed(),
                Spacer(),
                Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                      onPressed: () {
                        String itineraryName = itineraryNameController.text;
                        if (itineraryName.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(
                                    'Tol pangalanan mo naman muna yung trip mo'),
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
            // Fetch Location Button
            Positioned(
              top: 140,
              left: 20,
              child: ElevatedButton(
                onPressed: () {
                  _getCurrentLocation();
                  //_onGenerateRouteClicked();
                },
                child: Icon(Icons.my_location, size: 30, color: Colors.red),
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
                              Padding(
                                padding: const EdgeInsets.only(right: 152),
                                child: Text(
                                  'Name your trip',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    print('ilang araw $numberOfDays');
                                    print('cart items $cartItems');
                                  },
                                  child: Text('testing')),
                              SizedBox(height: 5),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 40,
                                child: TextField(
                                  controller: itineraryNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Name your trip',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              if (numberOfDays > 0) _buildDayButtons(),
                              if (selectedDay > 0)
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
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
