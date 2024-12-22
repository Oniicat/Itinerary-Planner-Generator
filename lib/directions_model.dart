import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final String totalDistance;
  final String totalDuration;
  final List<LatLng> polylinePoints;

  Directions({
    required this.totalDistance,
    required this.totalDuration,
    required this.polylinePoints,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    if (map['routes'] == null || map['routes'].isEmpty) {
      throw Exception('No routes available');
    }

    final route = map['routes'][0];
    final leg = route['legs'][0];

    return Directions(
      totalDistance: leg['distance']['text'] ?? '',
      totalDuration: leg['duration']['text'] ?? '',
      polylinePoints: PolylinePoints()
          .decodePolyline(route['overview_polyline']['points'] ?? '')
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
    );
  }
}
