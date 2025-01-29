// /c:/Android applications/firestore_basics/lib/for_future_use.dart

// This file is a scrapyard for code snippets and utilities that might be useful in the future.

// Fetch destination from Firestore
// Future<List<Map<String, dynamic>>> fetchAllDestinations() async {
//   var snapshot = await FirebaseFirestore.instance
//       .collection('Destinations')
//       .get(); // Fetch all documents

//   if (snapshot.docs.isNotEmpty) {
//     List<Map<String, dynamic>> destinations = [];

//     for (var doc in snapshot.docs) {
//       var data = doc.data() as Map<String, dynamic>;
//       double latitude = data['latitude']?.toDouble() ?? 0.0;
//       double longitude = data['longitude']?.toDouble() ?? 0.0;
//       String name = data['name'] ??
//           'Unknown Destination'; // if name of the location is blank
//       destinations.add({
//         'latitude': latitude,
//         'longitude': longitude,
//         'name': name, // Include the name in the map
//       });

//       print(
//           "Fetched data: latitude = $latitude, longitude = $longitude, name = $name");
//     }

//     return destinations;
//   } else {
//     print("No destinations found!");
//     throw Exception('No destinations found');
//   }
// }
