import 'package:firestore_basics/Directions/directions_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Directions/directions_model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const LatLng _initialCameraPosition =
      LatLng(14.483173939202675, 121.18757019252007);

  static const LatLng _destination1 =
      LatLng(14.48278480841818, 121.18716191070331);
  static const LatLng jabee = LatLng(14.492796103262384, 121.18167384328976);
  static const LatLng mcdo = LatLng(14.49208236393375, 121.18131129901126);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialCameraPosition,
        zoom: 12, // Set default zoom level
      ),
      markers: {
        Marker(
            markerId: MarkerId("destination1"),
            icon: BitmapDescriptor.defaultMarker,
            position: _destination1),
        Marker(
            markerId: MarkerId("Jollibee"),
            icon: BitmapDescriptor.defaultMarker,
            position: jabee),
        Marker(
            markerId: MarkerId("Mcdo"),
            icon: BitmapDescriptor.defaultMarker,
            position: mcdo)
      },
    ));
  }
}

//Fetch with filter
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
        var data = doc.data();
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

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _getUserLocation();
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

//remove marker function (still need to be fixed)
  void removeMarker(LatLng position) {
    setState(() {
      markers.removeWhere((marker) => marker.position == position);
    });

    // Refresh the route with the updated markers
    List<LatLng> remainingPositions =
        markers.map((marker) => marker.position).toList();

    // Ensure the user's location is the starting point
    if (userLocation != null) {
      remainingPositions.insert(0, userLocation!);
    }

    if (showRoute == true) {
      setState(() {
        _generateRoute(remainingPositions);
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
        if (userLocation != null) {
          markers.add(Marker(
            markerId: MarkerId("user_location"),
            position: userLocation!,
            infoWindow: InfoWindow(title: "Your Location"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ));

          destinationPositions.insert(
              0, userLocation!); // Add user's location as the starting point
        }

        // Generate polylines for the entire route
        _generateRoute(destinationPositions);
        _selectedDestination = null;
        polylines.clear();
      });
    } catch (e) {
      print('Error fetching destinations: $e'); //for catching an error bai
    }
  }

//clicking the clear route button
  // void _clearRoute() {
  //   setState(() {
  //     polylines.clear();
  //     showRoute = false;
  //   });
  // }

// extended funtion for  generate route button (still need to be fixed)
  // void _onGenerateRouteClicked() {
  //   List<LatLng> positions = markers.map((marker) => marker.position).toList();

  //   // Ensure the user's location is included as the starting point
  //   if (userLocation != null) {
  //     positions.insert(0, userLocation!);
  //   }

  //   _generateRoute(positions);

  //   // Set the route visibility to true
  //   setState(() {
  //     showRoute = true;
  //   });
  // }

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

        // Update route points
        routePoints.addAll(directions.polylinePoints
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList());

        // Update the _info variable to hold total distance and duration
        setState(() {
          _info = directions;
        });
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

          // actions: [
          //   if (_locationTypes.isNotEmpty)
          //     DropdownButton<String>(
          //       value: _selectedType,
          //       onChanged: _onFilterChanged,
          //       items: _locationTypes.map((type) {
          //         return DropdownMenuItem(
          //           value: type,
          //           child: Text(type), // Display the type name
          //         );
          //       }).toList(),
          //     ),
          // ],
          ),
      body: Column(
        children: [
          // Row(
          //   children: [
          //     ElevatedButton(
          //       onPressed: () {
          //         _clearRoute();
          //       },
          //       child:
          //           Text('Clear Route', style: TextStyle(color: Colors.white)),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.red,
          //       ),
          //     ),
          //     Spacer(),
          //     ElevatedButton(
          //       onPressed: () {
          //         _onGenerateRouteClicked();
          //       },
          //       child: Text('Generate Route',
          //           style: TextStyle(color: Colors.white)),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.blueAccent,
          //       ),
          //     ),
          //   ],
          // ),
          Positioned(top: 20, left: 65, child: _showdistanddur()),

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
                      // Navigator.of(context).push(
                      //   PageRouteBuilder(
                      //     pageBuilder: (context, animation, secondaryAnimation) => KindofTrip(),
                      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      //       const begin = Offset(1.0, 0.0); // Slide from the right
                      //       const end = Offset.zero; // End at the center
                      //       const curve = Curves.easeInOut;
                      //       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      //       var offsetAnimation = animation.drive(tween);

                      //       return SlideTransition(
                      //         position: offsetAnimation,
                      //         child: child,
                      //       );
                      //     },
                      //   ),
                      // );
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

//function for getting user location

//   Future<Position> _getcurrentlocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

//     if (!serviceEnabled) {
//       return Future.error('Location services not available');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permission');
//     }
//     return await Geolocator.getCurrentPosition();
//   }
// }


 


//orig code without the fetch destination for multiple destinations
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   Set<Marker> markers = {};
//   String? _selectedType; // Holds the current filter type
//   List<String> _locationTypes = []; // Types of locations fetched from Firestore
//   late String lat;
//   late String long;
//   LatLng? userLocation;
//   LatLng? pointB;
//   Directions? _info;
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//     _getUserLocation();
//     _pointB();
//   }

// //sample point b marker
//   void _pointB() {
//     setState(() {
//       pointB = LatLng(14.49208236393375, 121.18131129901126);
//       markers.add(
//         Marker(
//           markerId: MarkerId("user_location"),
//           position: pointB!,
//           infoWindow: InfoWindow(title: "Point B"),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//               BitmapDescriptor.hueOrange), // Custom marker color
//         ),
//       );
//     });
//   }

// //kunyare lang to
//   Future<void> _getUserLocation() async {
//     try {
//       // Fetch current location (for demonstration purposes)
//       setState(() {
//         userLocation = LatLng(
//             14.499111632246139, 121.18714131749572); // Example coordinates

//         // Add marker for user's location
//         markers.add(
//           Marker(
//             markerId: MarkerId("user_location"),
//             position: userLocation!,
//             infoWindow: InfoWindow(title: "Your Location"),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueBlue), // Custom marker color
//           ),
//         );
//       });

//       // Move the camera to the user's location (ensure it's not null)
//       if (mapController != null && userLocation != null) {
//         mapController!.animateCamera(
//           CameraUpdate.newLatLngZoom(userLocation!, 14), // Adjust zoom level
//         );
//       }
//     } catch (e) {
//       print("Error fetching user location: $e");
//     }
//   }

//   Future<void> _initializeScreen() async {
//     try {
//       // Fetch location types
//       List<String> types = await fetchLocationTypes();

//       setState(() {
//         _locationTypes = ['All', ...types]; // Add 'All' as the first option
//         _selectedType = 'All'; // Default to showing all locations
//       });

//       // Fetch all destinations initially
//       await _fetchDestinations();
//     } catch (e) {
//       print('Error initializing screen: $e');
//       setState(() {
//         _locationTypes = ['All']; // Fallback to default
//         _selectedType = 'All';
//       });
//     }
//   }

//   Future<void> _fetchDestinations() async {
//     try {
//       var destinations = await fetchFilteredDestinations(
//           _selectedType == 'All' ? null : _selectedType);
//       setState(() {
//         markers.clear();

//         for (var destination in destinations) {
//           markers.add(Marker(
//               markerId: MarkerId(
//                   'destination_marker_${destination['latitude']}_${destination['longitude']}'),
//               position:
//                   LatLng(destination['latitude'], destination['longitude']),
//               onTap: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   builder: (context) {
//                     return Padding(
//                       padding: const EdgeInsets.all(40.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(destination['name'],
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold)),
//                           SizedBox(height: 8),
//                           Text("Address: ${destination['address']}"),
//                           SizedBox(height: 8),
//                           Text("Description: ${destination['description']}"),
//                           SizedBox(height: 8),
//                           Text("Contact: ${destination['contact']}"),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               }));
//         }

//         // Add user location marker
//         if (userLocation != null) {
//           markers.add(Marker(
//             markerId: MarkerId("user_location"),
//             position: userLocation!,
//             infoWindow: InfoWindow(title: "Your Location"),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueBlue), // Custom color for user location
//           ));
//         }
//         if (pointB != null) {
//           markers.add(
//             Marker(
//               markerId: MarkerId("user_location"),
//               position: pointB!,
//               infoWindow: InfoWindow(title: "Point B"),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueOrange), // Custom marker color
//             ),
//           );
//         }
//         // Move camera to the first destination or user location (whichever is available)
//         if (markers.isNotEmpty) {
//           LatLng targetLocation =
//               markers.first.position; // Use first marker's position
//           mapController?.animateCamera(
//             CameraUpdate.newLatLngZoom(targetLocation, 14), // Adjust zoom level
//           );
//         }
//       });

//       // Directions API logic (ensure userLocation is not null before using it)
//       if (userLocation != null) {
//         final directions = await DirectionsRepository()
//             .getDirections(userLocation: userLocation!, pointB: pointB!);
//         setState(() => _info = directions);
//       }
//     } catch (e) {
//       print('Error fetching destinations: $e');
//     }
//   }

//   void _onFilterChanged(String? type) {
//     setState(() {
//       _selectedType = type ?? 'All'; // Fallback to 'All' if type is null
//     });
//     _fetchDestinations(); // Fetch destinations with the selected filter
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Map Screen'),
//         actions: [
//           if (_locationTypes.isNotEmpty)
//             DropdownButton<String>(
//               value: _selectedType,
//               onChanged: _onFilterChanged,
//               items: _locationTypes.map((type) {
//                 return DropdownMenuItem(
//                   value: type,
//                   child: Text(type), // Display the type name
//                 );
//               }).toList(),
//             ),
//         ],
//       ),
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           GoogleMap(
//             polylines: _info != null
//                 ? {
//                     Polyline(
//                       polylineId: const PolylineId('overview_polyline'),
//                       color: Colors.purple,
//                       width: 5,
//                       points: _info!.polylinePoints
//                           .map((e) => LatLng(e.latitude, e.longitude))
//                           .toList(),
//                     )
//                   }
//                 : {},
//             initialCameraPosition: CameraPosition(
//               target: LatLng(14.483173939202675, 121.18757019252007),
//               zoom: 12,
//             ),
//             markers: markers,
//             mapType: MapType.normal,
//             onMapCreated: (GoogleMapController controller) {
//               mapController = controller;
//             },
//           ),
//           if (_info != null)
//             Positioned(
//                 top: 20.0,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 6.0,
//                     horizontal: 12.0,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: Text(
//                       '${_info!.totalDistance}, ${_info!.totalDuration}',
//                       style:
//                           const TextStyle(fontSize: 18.0, color: Colors.white)),
//                 ))
//         ],
//       ),
//     );
//   }
// } 