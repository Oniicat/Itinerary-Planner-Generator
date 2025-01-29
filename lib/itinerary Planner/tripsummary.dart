import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripSummary extends StatefulWidget {
  final String itineraryName;
  final int numberOfDays;
  final Map<int, List<Map<String, dynamic>>> dailyDestinations;
  const TripSummary({
    super.key,
    required this.itineraryName,
    required this.numberOfDays,
    required this.dailyDestinations,
  });

  @override
  State<TripSummary> createState() => _TripSummaryState();
}

class _TripSummaryState extends State<TripSummary> {
  Set<Marker> markers = {};
  int numberOfDays = 0; // Total days
  int selectedDay = 0;
  Map<int, List<Map<String, dynamic>>> dailyDestinations = {};
  Widget showDayDetails(int day) {
    List<Map<String, dynamic>> destinations = dailyDestinations[day]!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Destinations for Day $day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (destinations.isEmpty)
              Center(
                child: Text(
                  'No destinations added yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ReorderableListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  // Fix index adjustment during reordering
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = destinations.removeAt(oldIndex);
                  destinations.insert(newIndex, item);

                  // Update the day's destinations
                  dailyDestinations[day] = destinations;
                });
              },
              children: List.generate(destinations.length, (index) {
                var destination = destinations[index];
                return Card(
                  key: ValueKey(destination),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(destination['name']),
                    subtitle: Text(destination['address']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          destinations.removeAt(index);
                          dailyDestinations[day] = destinations;
                        });
                      },
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(numberOfDays, (index) {
          int day = index + 1;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  selectedDay == day ? Color(0xFFA52424) : Colors.white,
                ),
                foregroundColor: WidgetStateProperty.all(
                  selectedDay == day ? Colors.white : Color(0xFFA52424),
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedDay = day;
                });
                showDayDetails(day);
                _updateMapForSelectedDay();
              },
              child: Text('Day $day'),
            ),
          );
        }),
      ),
    );
  }

  void _updateMapForSelectedDay() {
    setState(() {
      List<Map<String, dynamic>> destinations =
          dailyDestinations[selectedDay] ?? [];

      for (var destination in destinations) {
        LatLng position =
            LatLng(destination['latitude'], destination['longitude']);
        markers.add(Marker(
          markerId: MarkerId(
              'marker_${destination['latitude']}_${destination['longitude']}'),
          position: position,
          infoWindow: InfoWindow(title: destination['name']),
        ));
      }
    });
  }

  //save itinerary trip
  Future<void> saveItinerary() async {
    final itineraryData = {
      'itineraryName': 'Sample Itinerary',
      'travelerName': 'John Doe',
      'numberOfDays': numberOfDays,
      'createdAt': FieldValue.serverTimestamp(),
      'days': Map.fromIterable(
        List.generate(numberOfDays, (index) => index + 1),
        key: (day) => day.toString(),
        value: (day) {
          return dailyDestinations[day]!.map((destination) {
            return {
              'name': destination['name'],
              'latitude': destination['latitude'],
              'longitude': destination['longitude'],
              'address': destination['address'],
            };
          }).toList();
        },
      ),
    };

    try {
      final itineraryRef =
          FirebaseFirestore.instance.collection('Itineraries').doc();
      await itineraryRef.set(itineraryData);
      print('Itinerary saved successfully!');
    } catch (e) {
      print('Error saving itinerary: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    markers = {};
    numberOfDays = widget.numberOfDays;
    dailyDestinations = widget.dailyDestinations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_circle_left,
                  size: 50,
                  color: Color(0xFFA52424),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Text(
              'Trip Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  Text(widget.itineraryName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 25),
                      Text('Kind of Trip:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 25),
                      Text('Trip trip lang'),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 25),
                      Text('No. of Days:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 15),
                      Text(
                        ' $numberOfDays ',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Column(
                      children: [
                        if (numberOfDays > 0) _buildDayButtons(),
                        SizedBox(height: 20),
                        if (selectedDay > 0)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.75,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: showDayDetails(selectedDay),
                          ),
                        if (selectedDay == 0)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.75,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Center(
                                child: Text('Select a day to view details')),
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Call the save itinerary function when the button is pressed
                      saveItinerary();
                    },
                    child: Text('Save Itinerary'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
