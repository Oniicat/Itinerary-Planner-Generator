import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/Ui/forward_button_red.dart';
import 'package:firestore_basics/Ui/top_icon.dart';
import 'package:firestore_basics/Ui/white_buttons.dart';
import 'package:firestore_basics/itinerary%20generator/plan_itinerary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectDestinations extends StatefulWidget {
  final int numberOfTravelers;
  final List<String> selectedMunicipalities;
  final String? selectedTripType;
  final Set<String> selectedActivities;
  final int? minBudget;
  final int? maxBudget;

  final int numberOfDays;
  const SelectDestinations(
      {super.key,
      required this.selectedActivities,
      required this.selectedMunicipalities,
      required this.selectedTripType,
      required this.numberOfTravelers,
      required this.minBudget,
      required this.maxBudget,
      required this.numberOfDays});

  @override
  State<SelectDestinations> createState() => _SelectDestinationsState();
}

class _SelectDestinationsState extends State<SelectDestinations> {
  int numberOfTravelers = 1;
  List<String> selectedMunicipalities = [];
  String? selectedTripType;
  List<String> activityType = [];
  Set<String> selectedActivities = {};

  int? minBudget;
  int? maxBudget;

  int numberOfDays = 0;
  int days = 0;

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Map<String, dynamic>? _selectedDestination;
  LatLng? userLocation;
  final List<Map<String, dynamic>> cartItems = [];

  Future<void> fetchDestinationsAndAddMarkers({
    required int minBudget,
    required int maxBudget,
    required String? selectedTripType,
    required List<String> selectedActivities,
    required List<String> selectedMunicipalities,
    required Set<Marker> markers,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('test_destinations')
        .where('pricing', isLessThanOrEqualTo: maxBudget);

    try {
      QuerySnapshot snapshot = await query.get();

      // Clear existing markers
      markers.clear();

      // Filter by type and municipality locally
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Check if type matches any selected activities
        final typeMatches = selectedActivities.isEmpty ||
            selectedActivities.contains(data['type']);

        // Check if municipality matches any selected municipalities
        final municipalityMatches = selectedMunicipalities.isEmpty ||
            selectedMunicipalities.contains(data['municipality']);

        return typeMatches && municipalityMatches;
      }).toList();

      // Add markers for the filtered documents
      for (var doc in filteredDocs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        double lat = (data['latitude'] as num).toDouble();
        double lng = (data['longitude'] as num).toDouble();
        String municipality = data['municipality'];

        String title = data['name'] ?? 'Destination';

        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: title),
            onTap: () {
              setState(() {
                _selectedDestination = {
                  'name': title,
                  'municipality': municipality,
                  'address': data['address'],
                  'latitude': lat,
                  'longitude': lng,
                  'type': data['type'],
                  'pricing': data['pricing'],
                };
              });
            },
          ),
        );
      }

      print("Added ${markers.length} markers after filtering.");
    } catch (e) {
      print('Error fetching destinations: $e');
    }
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

  void _addToCart(Map<String, dynamic> destination) {
    if (cartItems.any((item) =>
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
        cartItems.add(destination);
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
                  print('Item $cartItems added');
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

  Widget _buildDestinationDetails() {
    if (_selectedDestination == null) {
      return Center(child: Text('Tap on a destination to see details'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDestination!['name'] ?? '',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA52424)),
                  ),
                  Text(
                    "${_selectedDestination!['municipality'] ?? ''}",
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
              Spacer(),
              Text(
                '${_selectedDestination!['pricing'].toString()}.00',
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            "Address: ${_selectedDestination!['address'] ?? ''}",
            style: TextStyle(fontSize: 11),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Spacer(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(70, 25),
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      backgroundColor: Color(0xFFA52424),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    _addToCart(_selectedDestination!);
                  },
                  child: Text('Add', style: TextStyle(fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  void _checkdata() {
    print('Minimum: $minBudget');
    print('Maximum: $maxBudget');
    print('Number of days: $numberOfDays');
    print('Selected Activities: $selectedActivities');
    print('Selected Municipalities: $selectedMunicipalities');
    print('Selected Trip Type: $selectedTripType');
    print('Number of Travelers: $numberOfTravelers');
  }

  Future<void> fetchAndSetMarkers() async {
    await fetchDestinationsAndAddMarkers(
      minBudget: minBudget ?? 0,
      maxBudget: maxBudget ?? 0,
      selectedTripType: selectedTripType,
      selectedActivities: selectedActivities.toList(),
      selectedMunicipalities: selectedMunicipalities,
      markers: markers,
    );
    setState(() {}); // Update UI with new markers.
  }

  @override
  void initState() {
    minBudget = widget.minBudget;
    maxBudget = widget.maxBudget;
    numberOfDays = widget.numberOfDays;
    numberOfTravelers = widget.numberOfTravelers;
    selectedMunicipalities = widget.selectedMunicipalities;
    selectedTripType = widget.selectedTripType;
    selectedActivities = widget.selectedActivities;
    fetchAndSetMarkers();
    _getUserLocation();
    _checkdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 16), // Adjust the padding as needed
                child: Closedbutton(),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                right: 300), // Add padding to avoid touching the screen edge
            child: Text(
              '5 of 6',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          Stack(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 30),
                  height: MediaQuery.of(context).size.height *
                      0.50, // 50% of screen height
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
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1.0),
            ),
            child: _buildDestinationDetails(),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: BackButtonWhite(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: NextButtonWhite(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  PlanItinerary(
                                      cartItems: cartItems,
                                      numberOfDays: numberOfDays,
                                      selectedTripType: selectedTripType),
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
