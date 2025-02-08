import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/itinerary%20Planner/view_trip.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class ItineraryListScreen extends StatefulWidget {
  const ItineraryListScreen({super.key // Initialize this
      });

  @override
  _ItineraryListScreenState createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0, // Removes shadow by default
        // backgroundColor: Colors.transparent, // Transparent background
        // elevation: 0, // Removes shadow
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BackButtonRed(),
        ),
      ),
      body: Column(
        children: [
          Text(
            'History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row(
              //   children: [
              //     ElevatedButton(
              //         onPressed: () {},
              //         style: ElevatedButton.styleFrom(
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius
              //                 .zero, // This removes the border radius to make it a box shape
              //           ),
              //         ),
              //         child: Text('Itinerary')),
              //     ElevatedButton(
              //         onPressed: () {},
              //         style: ElevatedButton.styleFrom(
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius
              //                 .zero, // This removes the border radius to make it a box shape
              //           ),
              //         ),
              //         child: Text('Booking'))
              //   ],
              // ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Itineraries')
                  .orderBy('createdAt',
                      descending: true) // Sort from newest to oldest
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No itineraries found.'));
                }

                final itineraries = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: itineraries.length,
                  itemBuilder: (context, index) {
                    final itinerary = itineraries[index];
                    final itineraryName =
                        itinerary['itineraryName'] ?? 'Unnamed Trip';
                    final numberOfDays = itinerary['numberOfDays'] ?? 0;
                    final createdAt = itinerary['createdAt'] != null
                        ? (itinerary['createdAt'] as Timestamp)
                            .toDate()
                            .toString()
                        : 'Unknown Date';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                itineraryName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              subtitle: Text(
                                DateFormat('MMMM d, y')
                                    .format(DateTime.parse(createdAt)),
                              ),
                              onTap: () {
                                String selectedDay =
                                    "Day ${index + 1}"; // Example selected day logic
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripDetails(
                                      itineraryName: itineraryName,
                                      selectedDay: selectedDay,
                                      numberOfDays: numberOfDays,
                                      dailyDestinations:
                                          _mapFirestoreData(itinerary['days']),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: ElevatedButton(
                            //     style: ButtonStyle(
                            //       backgroundColor: WidgetStateProperty.all(
                            //           Color(0xFFA52424)),
                            //       foregroundColor:
                            //           WidgetStateProperty.all(Colors.white),
                            //     ),
                            //     onPressed: () {
                            //       showDialog(
                            //         context: context,
                            //         builder: (context) => AlertDialog(
                            //           content: Text(
                            //               'Teka lang boss wala pa akong function'),
                            //           actions: [
                            //             TextButton(
                            //               onPressed: () {
                            //                 Navigator.pop(context);
                            //               },
                            //               child: Text('Oumki'),
                            //             ),
                            //           ],
                            //         ),
                            //       );
                            //     },
                            //     child: Text(
                            //       'Done',
                            //       style: TextStyle(color: Colors.white),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Map<int, List<Map<String, dynamic>>> _mapFirestoreData(
    Map<dynamic, dynamic>? firestoreData) {
  if (firestoreData == null) return {};

  return firestoreData.map<int, List<Map<String, dynamic>>>(
    (key, value) {
      List<Map<String, dynamic>> destinations =
          List<Map<String, dynamic>>.from(value);
      return MapEntry(int.parse(key), destinations);
    },
  );
}

class TripDetails extends StatefulWidget {
  final String itineraryName;
  final int numberOfDays;
  final Map<int, List<Map<String, dynamic>>> dailyDestinations;
  final String selectedDay; // Add selectedDay

  const TripDetails({
    super.key,
    required this.itineraryName,
    required this.numberOfDays,
    required this.dailyDestinations,
    required this.selectedDay,
  });

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  int numberOfDays = 0; // Total days
  int selectedDay = 0;
  Map<int, List<Map<String, dynamic>>> dailyDestinations = {};
  String itineraryName = '';
  Set<Marker> markers = {};

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

  @override
  void initState() {
    super.initState();
    markers = {};
    numberOfDays = widget.numberOfDays;
    dailyDestinations = widget.dailyDestinations;
    itineraryName = widget.itineraryName;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: BackButtonRed(),
          ),
        ),
        body: SafeArea(
          child: Center(
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
                      SizedBox(height: 10),
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Color(0xFFA52424)),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                        ),
                        onPressed: () {
                          if (dailyDestinations[selectedDay] != null) {
                            _updateMapForSelectedDay(); // Ensure markers are set
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewTrip(
                                  itineraryName: itineraryName,
                                  selectedDay: selectedDay,
                                  selectedDayDestinations:
                                      dailyDestinations[selectedDay]!,
                                  markers: markers,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'No destinations for the selected day!')),
                            );
                          }
                        },
                        child: Text('View'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ));
  }
}
