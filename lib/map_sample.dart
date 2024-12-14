import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const LatLng _initialCameraPosition =
      LatLng(14.483173939202675, 121.18757019252007);

//
  static const LatLng _destination1 =
      LatLng(14.48278480841818, 121.18716191070331);
  static const LatLng _Jabee = LatLng(14.492796103262384, 121.18167384328976);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialCameraPosition,
      ),
      markers: {
        Marker(
            markerId: MarkerId("destination1"),
            icon: BitmapDescriptor.defaultMarker,
            position: _destination1),
        Marker(
            markerId: MarkerId("Jollibee"),
            icon: BitmapDescriptor.defaultMarker,
            position: _Jabee)
      },
    ));
  }
}
