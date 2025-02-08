import 'dart:async';

import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/itinerary%20Planner/cart.dart';

class CreateItinerary extends StatefulWidget {
  const CreateItinerary({super.key});

  @override
  State<CreateItinerary> createState() => _CreateItineraryState();
}

//fetch the location type
Future<List<String>> fetchLocationTypes() async {
  try {
    // Fetch all documents in the collection
    var snapshot =
        await FirebaseFirestore.instance.collection('test_destinations').get();

    if (snapshot.docs.isNotEmpty) {
      // Use a Set to collect unique types
      Set<String> types = snapshot.docs.map((doc) {
        var data = doc.data();
        return data['type'] as String;
      }).toSet();

      return types.toList();
    } else {
      if (kDebugMode) {
        print("No destinations found!");
      }
      return [];
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error fetching location types: $e");
    }
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
  //Directions? _info; // route information
  Set<Polyline> polylines = {}; //storing routes for multiple destinations
  bool showRoute = false;
  Map<String, dynamic>? _selectedDestination;
  final List<Map<String, dynamic>> _cartItems = [];

  Set<String> selectedTypes = {}; // Track selected types
  List<String> activityTypes = [];
  // Search functionality
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _getUserLocation();
    _loadActivityTypes();
    _fetchDestinations();
  }

  //function ng add to cart
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

//new filter button for testing

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
      if (kDebugMode) {
        print("Error fetching user location: $e");
      }
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
      if (kDebugMode) {
        print('Error initializing screen: $e');
      }
      setState(() {
        _locationTypes = ['All']; // Fallback to default
        _selectedType = 'All';
      });
    }
  }

  Future<void> _loadActivityTypes() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('typeofactivity').get();

    setState(() {
      activityTypes =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  Future<void> _fetchDestinations({bool showAll = true}) async {
    try {
      markers.clear();

      List<Map<String, dynamic>> destinations = [];
      if (showAll) {
        // Fetch all destinations
        destinations = await fetchFilteredDestinations(null);
      } else {
        for (var type in selectedTypes) {
          var filtered = await fetchFilteredDestinations(type);
          destinations.addAll(filtered);
        }
      }

      setState(() {
        for (var destination in destinations) {
          final position = LatLng(
            destination['latitude'],
            destination['longitude'],
          );

          final markerId =
              'destination_marker_${destination['latitude']}_${destination['longitude']}';

          markers.add(
            Marker(
              markerId: MarkerId(markerId),
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
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching destinations: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchFilteredDestinations(
      String? type) async {
    Query query = FirebaseFirestore.instance.collection('test_destinations');

    // Check if a specific type filter is provided
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }

    var snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'],
          'latitude': data['latitude']?.toDouble() ?? 0.0,
          'longitude': data['longitude']?.toDouble() ?? 0.0,
          'type': data['type'],
          'description': data['description'] ?? "No description available",
          'address': data['address'] ?? "No address available",
          'contact': data['contact'] ?? "No contact available",
          'pricing': data['pricing']?.toDouble() ?? 0.0,
        };
      }).toList();
    } else {
      if (kDebugMode) {
        print("No destinations found for type: $type");
      }
      return [];
    }
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
            'Pricing: ${_selectedDestination!['pricing'].toString()}',
            style: TextStyle(fontSize: 13),
          ),
          Text(
            "Address: ${_selectedDestination!['address'] ?? ''}",
            style: TextStyle(fontSize: 10),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BackButtonRed(),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 20.0),
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
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: GestureDetector(
                    onTap: _openSearchScreen, // Navigate to the search screen
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      height: 40,
                      //padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search),
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
                                  _selectedDestination =
                                      null; // Clear searchbar
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
              ),
              //buttons for filtering
              Padding(
                padding: const EdgeInsets.only(top: 65),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: activityTypes.map((type) {
                      final isSelected = selectedTypes.contains(type);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? Color(0xFFA52424) : Colors.white,
                            foregroundColor:
                                isSelected ? Colors.white : Color(0xFFA52424),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                selectedTypes.remove(type);
                              } else {
                                selectedTypes.add(type);
                              }
                            });
                            _fetchDestinations(showAll: selectedTypes.isEmpty);
                          },
                          child: Text(type),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          //container of the destination details
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
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

//Search Screen
class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDestinations = [];
  Timer? _debounce;

//update query for case insensitive searching (kahit lowercase may lalabas pa rin)
  void updateDocuments() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('test_destinations').get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      await doc.reference.update({'nameLower': data['name'].toLowerCase()});
    }
  }

  @override
  void initState() {
    super.initState();
    updateDocuments();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchDestinations(widget.initialQuery!);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchDestinations(_searchController.text);
    });
  }

  void _searchDestinations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredDestinations.clear();
      });
      return;
    }

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('test_destinations')
          .where('nameLower', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('nameLower',
              isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .get();

      List<Map<String, dynamic>> destinations = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _filteredDestinations = destinations;
      });
    } catch (e) {
      debugPrint('Error fetching destinations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Destinations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
          Expanded(
            child: _filteredDestinations.isEmpty
                ? const Center(
                    child: Text('No destinations found'),
                  )
                : ListView.builder(
                    itemCount: _filteredDestinations.length,
                    itemBuilder: (context, index) {
                      var destination = _filteredDestinations[index];
                      return ListTile(
                        title: Text(destination['name']),
                        subtitle: Text(
                            '${destination['latitude']}, ${destination['longitude']}'),
                        onTap: () {
                          Navigator.pop(context, destination);
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
