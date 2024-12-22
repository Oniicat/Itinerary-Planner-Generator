import 'package:firestore_basics/directions_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firestore_basics/directions_model.dart';

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
  static const LatLng _Jabee = LatLng(14.492796103262384, 121.18167384328976);
  static const LatLng _Mcdo = LatLng(14.49208236393375, 121.18131129901126);

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
            position: _Jabee),
        Marker(
            markerId: MarkerId("Mcdo"),
            icon: BitmapDescriptor.defaultMarker,
            position: _Mcdo)
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

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  String? _selectedType; // Holds the current filter type
  List<String> _locationTypes = []; // Types of locations fetched from Firestore
  late String lat;
  late String long;
  LatLng? userLocation;
  LatLng? pointB;
  Directions? _info; // route information
  Set<Polyline> polylines = {}; //added this for multiple destinations
  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _getUserLocation();
    _pointB();
  }

//sample point b marker
  void _pointB() {
    setState(() {
      pointB = LatLng(14.49208236393375, 121.18131129901126);
      markers.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: pointB!,
          infoWindow: InfoWindow(title: "Point B"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange), // Custom marker color
        ),
      );
    });
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

  Future<void> _fetchDestinations() async {
    try {
      var destinations = await fetchFilteredDestinations(
          _selectedType == 'All' ? null : _selectedType);

      setState(() {
        markers.clear();
        List<LatLng> destinationPositions = [];

        for (var destination in destinations) {
          final position =
              LatLng(destination['latitude'], destination['longitude']);
          destinationPositions.add(position);

          markers.add(Marker(
            markerId: MarkerId(
                'destination_marker_${destination['latitude']}_${destination['longitude']}'),
            position: position,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(destination['name'],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Address: ${destination['address']}"),
                        SizedBox(height: 8),
                        Text("Description: ${destination['description']}"),
                        SizedBox(height: 8),
                        Text("Contact: ${destination['contact']}"),
                      ],
                    ),
                  );
                },
              );
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
      });
    } catch (e) {
      print('Error fetching destinations: $e'); //for catching an error bai
    }
  }

  Future<void> _generateRoute(List<LatLng> positions) async {
    try {
      List<LatLng> routePoints = [];

      for (int i = 0; i < positions.length - 1; i++) {
        final directions = await DirectionsRepository().getDirections(
          userLocation: positions[i],
          pointB: positions[i + 1],
        );

        if (directions != null) {
          routePoints.addAll(directions.polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList());
        }
      }

      // Add the complete route as a single polyline
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

  void _onFilterChanged(String? type) {
    setState(() {
      _selectedType = type ?? 'All'; // Fallback to 'All' if type is null
    });
    _fetchDestinations(); // Fetch destinations with the selected filter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
        actions: [
          if (_locationTypes.isNotEmpty)
            DropdownButton<String>(
              value: _selectedType,
              onChanged: _onFilterChanged,
              items: _locationTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type), // Display the type name
                );
              }).toList(),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            polylines: polylines,
            initialCameraPosition: CameraPosition(
              target: LatLng(14.483173939202675, 121.18757019252007),
              zoom: 12,
            ),
            markers: markers,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
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