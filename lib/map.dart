import 'package:flutter/material.dart';
import 'package:firestore_basics/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/directions_model.dart';
import 'package:firestore_basics/cart.dart';

class CreateItinerary extends StatefulWidget {
  const CreateItinerary({super.key});

  @override
  State<CreateItinerary> createState() => _CreateItineraryState();
}

Future<List<Map<String, dynamic>>> fetchFilteredDestinations(
    String? type) async {
  Query query = FirebaseFirestore.instance.collection('Destinations');

  if (type != null) {
    query = query.where('type', isEqualTo: type);
  }

  var snapshot = await query.get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'name': data['name'], // Name of the destination
        'latitude': data['latitude']?.toDouble() ?? 0.0,
        'longitude': data['longitude']?.toDouble() ?? 0.0,
        'type': data['type'], // Type of the destination
        'description': data['description'] ?? "No description available",
        'address': data['address'] ?? "No address available",
        'contact': data['contact'] ?? "No contact available"
      };
    }).toList();
  } else {
    print("No destinations found for type: $type");
    return [];
  }
}

//fetch the location type
Future<List<String>> fetchLocationTypes() async {
  try {
    // Fetch all documents in the collection
    var snapshot =
        await FirebaseFirestore.instance.collection('Destinations').get();

    if (snapshot.docs.isNotEmpty) {
      // Use a Set to collect unique types
      Set<String> types = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data['type'] as String;
      }).toSet();

      return types.toList();
    } else {
      print("No destinations found!");
      return [];
    }
  } catch (e) {
    print("Error fetching location types: $e");
    return [];
  }
}

class _CreateItineraryState extends State<CreateItinerary> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  String? _selectedType; // Holds the current filter type
  List<String> _locationTypes = []; // Types of locations fetched from Firestore
  // late String lat;
  // late String long;
  LatLng? userLocation;
  LatLng? pointB;
  Directions? _info; // route information
  Set<Polyline> polylines = {}; //storing routes for multiple destinations
  bool showRoute = false;
  Map<String, dynamic>? _selectedDestination;
  List<Map<String, dynamic>> _cartItems = [];

  // Search functionality
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _getUserLocation();
  }

  //function ng add to cart bai
  void _addToCart(Map<String, dynamic> destination) {
    if (_cartItems.any((item) =>
        item['name'] ==
        destination['name'])) // Check if the destination is already in the cart
    {
      // Show pop-up dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('${destination['name']} is already in the cart.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Add the destination to the cart
      setState(() {
        _cartItems.add(destination);
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('${destination['name']} is added in the cart.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('${destination['name']} added to cart'),
      //   ),
      // );
    }
  }

//function ng remove from cart

  // Function to navigate to the search screen
  void _openSearchScreen() async {
    final selectedDestination = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SearchScreen(
                initialQuery: _selectedDestination?['name'],
              )),
    );

    if (selectedDestination != null) {
      setState(() {
        _searchController.text = selectedDestination['name'];
        _selectedDestination = selectedDestination;
        _focusOnDestination(selectedDestination);
      });
    }
  }

// Update the filtered list of destinations based on search query
  // void _filterDestinations(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       _filteredDestinations = [];
  //       _fetchDestinations();
  //     } else {
  //       _filteredDestinations = _filteredDestinations
  //           .where((destination) =>
  //               destination['name'].toLowerCase().contains(query.toLowerCase()))
  //           .toList();
  //     }
  //   });
  // }

  // Focus the map on the selected destination
  void _focusOnDestination(Map<String, dynamic> destination) {
    final LatLng destinationLatLng = LatLng(
      destination['latitude'],
      destination['longitude'],
    );

    setState(() {
      // Clear previous markers and add a new one for the selected destination
      //markers.clear();
      _selectedType = 'All'; // Reset the selected type
      markers.add(Marker(
        markerId: MarkerId(destination['name']),
        position: destinationLatLng,
        infoWindow: InfoWindow(title: destination['name']),
      ));
      _selectedDestination = destination;
    });

    // Animate camera to the destination
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(destinationLatLng, 18.0),
    );
  }

//kunyare lang to
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
      print("Error fetching user location: $e");
    }
  }

  Future<void> _initializeScreen() async {
    try {
      // Fetch location types
      List<String> types = await fetchLocationTypes();

      setState(() {
        _locationTypes = ['All', ...types]; // Add 'All' as the first option
        _selectedType = 'All'; // Default to showing all locations
      });

      // Fetch all destinations initially
      await _fetchDestinations();
    } catch (e) {
      print('Error initializing screen: $e');
      setState(() {
        _locationTypes = ['All']; // Fallback to default
        _selectedType = 'All';
      });
    }
  }

  Future<void> _fetchDestinations() async {
    try {
      var destinations = await fetchFilteredDestinations(
          _selectedType == 'All' ? null : _selectedType);

      setState(() {
        markers.clear();
        showRoute = false;
        List<LatLng> destinationPositions = [];
        // Store filtered destinations
        //_filteredDestinations = destinations;

        for (var destination in destinations) {
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

        // Add user location marker
        // if (userLocation != null) {
        //   markers.add(Marker(
        //     markerId: MarkerId("user_location"),
        //     position: userLocation!,
        //     infoWindow: InfoWindow(title: "Your Location"),
        //     icon:
        //         BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        //   ));

        //   destinationPositions.insert(
        //       0, userLocation!); // Add user's location as the starting point
        // }

        // Generate polylines for the entire route
        // _generateRoute(destinationPositions);
        _selectedDestination = null;
        polylines.clear();
      });
    } catch (e) {
      print('Error fetching destinations: $e'); //for catching an error bai
    }
  }

//clicking the clear route button
  void _clearRoute() {
    setState(() {
      polylines.clear();
      showRoute = false;
    });
  }

// extended funtion for  generate route button (still need to be fixed)
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

//for generating the travel route
  Future<void> _generateRoute(List<LatLng> positions) async {
    try {
      showRoute = true;
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
    } catch (e) {
      print('Error generating route: $e');
    }
  }

//for showing the distance and duration
  Widget _showdistanddur() {
    if (showRoute != true) {
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
  void _onFilterChanged(String? type) {
    setState(() {
      _selectedType = type ?? 'All'; // Fallback to 'All' if type is null
    });
    _fetchDestinations(); // Fetch destinations with the selected filter
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
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(120, 0.5),
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      backgroundColor: Color(0xFFA52424),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    _addToCart(_selectedDestination!);
                  },
                  child: Text('Add to Cart', style: TextStyle(fontSize: 15))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          PreferredSize(preferredSize: Size.fromHeight(35), child: AppBar()),
      body: Column(
        children: [
          Positioned(
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _openSearchScreen, // Navigate to the search screen
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 30,
                //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDestination != null
                            ? _selectedDestination![
                                'name'] // Show selected destination
                            : 'Search Destinations', // Placeholder text
                        style: TextStyle(color: Colors.black54),
                        overflow: TextOverflow
                            .ellipsis, // Truncate text if it's too long
                      ),
                    ),
                    if (_selectedDestination !=
                        null) // Show clear button only when needed
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDestination = null; // Clear searchbar
                            // _selectedType = 'All';
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

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
                    polylines: showRoute
                        ? polylines
                        : {}, // Show polylines conditionally
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),
              ),

              // Display the filtered search results below the search bar

              if (_locationTypes.isNotEmpty)
                Positioned(
                  top: 60,
                  child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(left: 260),
                    decoration: BoxDecoration(
                      color: Color(0xFFA52424),
                      // border: Border.all(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: DropdownButton<String>(
                      style: TextStyle(color: Colors.white),
                      value: _selectedType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                        _onFilterChanged(newValue); // Your filtering logic
                      },
                      items: _locationTypes
                          .map<DropdownMenuItem<String>>((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type), // Display the type name
                        );
                      }).toList(),
                      dropdownColor: Color(0xFFA52424),
                      underline: SizedBox.shrink(),
                    ),
                  ),
                ),
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
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_circle_right,
                      size: 50,
                      color: Color(0xFFA52424),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  CartScreen(
                            cartItems: _cartItems,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Start from right
                            const end = Offset.zero; // End at original position
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  SearchScreen({this.initialQuery});
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDestinations = [];

  @override
  void initState() {
    super.initState();

    // Set the search bar text to the initial query if provided
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchDestinations(widget.initialQuery!);
    }

    _searchController.addListener(_filterDestinations);
  }

  // Search Firestore for destinations matching the query
  void _searchDestinations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredDestinations = [];
      });
      return;
    }

    // Query Firestore collection 'Destinations' for documents with name matching the query
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Destinations')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    List<Map<String, dynamic>> destinations = [];
    for (var doc in querySnapshot.docs) {
      destinations.add(doc.data() as Map<String, dynamic>);
    }

    setState(() {
      _filteredDestinations = destinations;
    });
  }

  void _filterDestinations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDestinations = _filteredDestinations.where((destination) {
        return destination['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Destinations'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Destinations',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _searchDestinations,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDestinations.length,
              itemBuilder: (context, index) {
                var destination = _filteredDestinations[index];
                return ListTile(
                  title: Text(destination['name']),
                  subtitle: Text(
                      '${destination['latitude']}, ${destination['longitude']}'), //details shown along with the
                  onTap: () {
                    // Handle tapping a destination (select or show details)

                    Navigator.pop(
                        context, destination); // Pass selected destination back
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
