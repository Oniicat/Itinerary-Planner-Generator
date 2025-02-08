import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Imthemap extends StatefulWidget {
  const Imthemap({super.key});

  @override
  State<Imthemap> createState() => _ImthemapState();
}

class _ImthemapState extends State<Imthemap> {
  LatLng intialcamerapos = LatLng(14.499297797531815, 121.18708244965396);
  Set<Marker> watermark = {};
  Set<Marker> allmarkers = {
    Marker(
      markerId: MarkerId('Home'),
      position: LatLng(14.499297797531815, 121.18708244965396),
      infoWindow: InfoWindow(title: 'bahay ng pogi'),
    ),
    Marker(
      markerId: MarkerId('Restaurants'),
      position: LatLng(
        14.49208236393375,
        121.18131129901126,
      ),
      infoWindow: InfoWindow(title: 'mcdo'),
    ),
    Marker(
      markerId: MarkerId('Schools'),
      position: LatLng(14.493510842591018, 121.18203638756826),
      infoWindow: InfoWindow(title: 'school'),
    ),
  };
  Set<Marker> visiblemarkers = {};
  List<String> filterMarkers = [
    'All',
    'Restaurants',
    'Schools',
    'Hospitals',
    'Home'
  ];
  String selectedFilter = 'All';
  String filter = 'All';

  List<Map<String, dynamic>> locations = [
    {
      'latitude': 14.49208236393375,
      'longitude': 121.18131129901126,
      'name': 'Mcdo',
      'type': 'Restaurants'
    },
    {
      'latitude': 14.492796103262384,
      'longitude': 121.18167384328976,
      'name': 'Jabee',
      'type': 'Restaurants'
    },
    {
      'latitude': 14.493510842591018,
      'longitude': 121.18203638756826,
      'name': 'Kunyare school',
      'type': 'Schools'
    }
  ];

  @override
  void initState() {
    super.initState();
    userlocation();
    filtermap(filter);
  }

  void loopingofloc() {
    setState(() {
      for (var loc in locations) {
        watermark.add(Marker(
            markerId: MarkerId(loc['type']),
            position: LatLng(loc['latitude'], loc['longitude'])));
      }
    });
  }

  void filtermap(String filter) {
    setState(() {
      if (filter == 'All') {
        visiblemarkers = allmarkers;
      } else {
        visiblemarkers = allmarkers.where((allmarkers) {
          return allmarkers.markerId == MarkerId(filter);
        }).toSet();
      }
    });
  }

  void userlocation() async {
    setState(() {
      locations.add({
        'latitude': 14.499297797531815,
        'longitude': 121.18708244965396,
        'type': 'bahay ng pogi'
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          GoogleMap(
            markers: visiblemarkers,
            initialCameraPosition: CameraPosition(
              target: intialcamerapos,
              zoom: 16,
            ),
          ),
          DropdownButton(
            value: selectedFilter,
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
              });
              filtermap(selectedFilter);
            },
            items: filterMarkers.map((String filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
          )
        ],
      )),
    ));
  }
}
