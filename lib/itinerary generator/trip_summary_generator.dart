import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/Ui/navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripSummaryGenerator extends StatefulWidget {
  final String itineraryName;
  final int numberOfDays;
  final String? selectedTripType;
  final Map<int, List<Map<String, dynamic>>> dailyDestinations;
  const TripSummaryGenerator(
      {super.key,
      required this.itineraryName,
      required this.numberOfDays,
      required this.dailyDestinations,
      required this.selectedTripType});

  @override
  State<TripSummaryGenerator> createState() => _TripSummaryGeneratorState();
}

class _TripSummaryGeneratorState extends State<TripSummaryGenerator> {
  Set<Marker> markers = {};
  int numberOfDays = 0; // Total days
  int selectedDay = 0;
  Map<int, List<Map<String, dynamic>>> dailyDestinations = {};
  String itineraryName = '';
  String? selectedTripType;
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
      'itineraryName': itineraryName,
      'travelerName': 'Baymax',
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Itinerary saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  // Ensure correct navigation
                  context,
                  MaterialPageRoute(builder: (context) => NavBar()),
                );
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
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
    itineraryName = widget.itineraryName;
    selectedTripType = widget.selectedTripType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButtonRed(),
          Center(
            child: Column(
              children: [
                Text(
                  'Trip Summary',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 25),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 25),
                          Text('Trip Name:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(width: 25),
                          Text(
                            '$itineraryName',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 25),
                          Text('No. of Days:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(width: 25),
                          Text(
                            ' $numberOfDays ',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          if (numberOfDays > 0) _buildDayButtons(),
                          SizedBox(height: 20),
                          if (selectedDay > 0)
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.grey),
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
                    ],
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color(0xFFA52424)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text('Save Itinerary Trip?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              saveItinerary();
                            },
                            child: Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('No'),
                          ),
                        ],
                      ),
                    );
                    // Call the save itinerary function when the button is pressed
                  },
                  child: Text('Save Itinerary'),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
