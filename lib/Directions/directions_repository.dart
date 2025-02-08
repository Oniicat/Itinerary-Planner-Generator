import 'package:dio/dio.dart';
import 'package:firestore_basics/Directions/.emv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firestore_basics/Directions/directions_model.dart';

// class DirectionsRepository {
//   static const String _baseURL =
//       'https://maps.googleapis.com/maps/api/directions/json?';

//   final Dio _dio;

//   DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

//   Future<Directions> getDirections({
//     required LatLng userLocation,
//     required Set<Marker> markers,
//   }) async {
//     // Create a list to store marker coordinates as strings
//     List<String> markerCoordinates = [];

//     // Iterate through the set of markers and extract the latitude and longitude
//     for (var marker in markers) {
//       final position = marker.position;
//       markerCoordinates.add('${position.latitude},${position.longitude}');
//     }

//     // Combine all marker coordinates as a single string, separated by a pipe "|"
//     final markersString = markerCoordinates.join('|');

//     // Make the API request
//     final response = await _dio.get(_baseURL, queryParameters: {
//       'origin':
//           '${userLocation.latitude},${userLocation.longitude}', // Origin is userLocation
//       'destination': markersString, // Destination markers (list of coordinates)
//       'key': googleAPIKey,
//     });

//     // Check if the response is successful
//     if (response.statusCode == 200) {
//       return Directions.fromMap(response.data);
//     }

//     throw Exception('Failed to fetch directions');
//   }
// }

//orig code without setting markers as <Marker>
// class DirectionsRepository {
//   static const String _baseURL =
//       'https://maps.googleapis.com/maps/api/directions/json?';

//   final Dio _dio;

//   DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

//   Future<Directions> getDirections({
//     required LatLng userLocation,
//     required LatLng pointB,
//   }) async {
//     final response = await _dio.get(_baseURL, queryParameters: {
//       'userLocation': '${userLocation.latitude}, ${userLocation.longitude}',
//       'pointB': '${pointB.latitude}, ${pointB.longitude}',
//       'key': googleAPIKey,
//     });

//     //check if response is successful
//     if (response.statusCode == 200) {
//       return Directions.fromMap(response.data);
//     }

//     throw Exception('Failed to fetch directions');
//   }
// }

//another try for fetching userlocation and pointb directions(it worked only for point A to point B)
class DirectionsRepository {
  static const String _baseURL =
      'https://maps.googleapis.com/maps/api/directions/json';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    required LatLng userLocation,
    required LatLng pointB,
  }) async {
    final response = await _dio.get(_baseURL, queryParameters: {
      'origin': '${userLocation.latitude},${userLocation.longitude}',
      'destination': '${pointB.latitude},${pointB.longitude}',
      'key': googleAPIKey,
    });

    if (response.statusCode == 200 && response.data != null) {
      if (response.data['routes'] != null &&
          response.data['routes'].isNotEmpty) {
        return Directions.fromMap(response.data);
      } else {
        throw Exception('No routes found in the response.');
      }
    }

    throw Exception('Failed to fetch directions');
  }
}
