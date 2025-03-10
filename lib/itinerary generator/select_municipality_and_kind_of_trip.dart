import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/Ui/button_red.dart';
import 'package:firestore_basics/Ui/forward_button_red.dart';
import 'package:firestore_basics/Ui/top_icon.dart';
import 'package:firestore_basics/Ui/white_buttons.dart';
import 'package:firestore_basics/itinerary%20generator/select_activity_and_set_budget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SelectMunicipality extends StatefulWidget {
  const SelectMunicipality({super.key});

  @override
  State<SelectMunicipality> createState() => _SelectMunicipalityState();
}

class _SelectMunicipalityState extends State<SelectMunicipality> {
  // List to keep track of selected municipalities
  List<String> selectedMunicipalities = [];

  // Method to toggle municipality selection
  void toggleMunicipality(String municipality) {
    setState(() {
      if (selectedMunicipalities.contains(municipality)) {
        selectedMunicipalities
            .remove(municipality); // Remove if already selected
      } else {
        selectedMunicipalities.add(municipality); // Add if not selected
      }
    });
  }

//permission for accessing gps
  Future<Position> getCurrentPosition() async {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception("Location services are disabled. Please enable them.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 16), // Adjust the padding as needed
                child: Closedbutton(),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 320),
              child: Text(
                '1 of 6',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 37),
                    child: Text(
                      'Select Municipality',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFFA52424)),
                    )),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.55,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center vertically
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center horizontally
                                children: [
                                  MunicipalityButton(
                                    text: 'Angono',
                                    isSelected: selectedMunicipalities
                                        .contains('Angono'),
                                    onTap: () => toggleMunicipality('Angono'),
                                  ),
                                  const SizedBox(width: 10),
                                  MunicipalityButton(
                                    text: 'Antipolo',
                                    isSelected: selectedMunicipalities
                                        .contains('Antipolo'),
                                    onTap: () => toggleMunicipality('Antipolo'),
                                  ),
                                ],
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MunicipalityButton(
                                      text: 'Baras',
                                      isSelected: selectedMunicipalities
                                          .contains('Baras'),
                                      onTap: () => toggleMunicipality('Baras'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    MunicipalityButton(
                                      text: 'Binangonan',
                                      isSelected: selectedMunicipalities
                                          .contains('Binangonan'),
                                      onTap: () =>
                                          toggleMunicipality('Binangonan'),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MunicipalityButton(
                                      text: 'Cainta',
                                      isSelected: selectedMunicipalities
                                          .contains('Cainta'),
                                      onTap: () => toggleMunicipality('Cainta'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    MunicipalityButton(
                                      text: 'Cardona',
                                      isSelected: selectedMunicipalities
                                          .contains('Cardona'),
                                      onTap: () =>
                                          toggleMunicipality('Cardona'),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MunicipalityButton(
                                      text: 'Jala-jala',
                                      isSelected: selectedMunicipalities
                                          .contains('Jala-Jala'),
                                      onTap: () =>
                                          toggleMunicipality('Jala-Jala'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    MunicipalityButton(
                                      text: 'Morong',
                                      isSelected: selectedMunicipalities
                                          .contains('Morong'),
                                      onTap: () => toggleMunicipality('Morong'),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MunicipalityButton(
                                      text: 'Rodriguez',
                                      isSelected: selectedMunicipalities
                                          .contains('Rodriguez'),
                                      onTap: () =>
                                          toggleMunicipality('Rodriguez'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    MunicipalityButton(
                                      text: 'Pililla',
                                      isSelected: selectedMunicipalities
                                          .contains('Pililla'),
                                      onTap: () =>
                                          toggleMunicipality('Pililla'),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MunicipalityButton(
                                      text: 'San Mateo',
                                      isSelected: selectedMunicipalities
                                          .contains('San Mateo'),
                                      onTap: () =>
                                          toggleMunicipality('San Mateo'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    MunicipalityButton(
                                      text: 'Tanay',
                                      isSelected: selectedMunicipalities
                                          .contains('Tanay'),
                                      onTap: () => toggleMunicipality('Tanay'),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MunicipalityButton(
                                      text: 'Taytay',
                                      isSelected: selectedMunicipalities
                                          .contains('Taytay'),
                                      onTap: () => toggleMunicipality('Taytay'),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    MunicipalityButton(
                                      text: 'Teresa',
                                      isSelected: selectedMunicipalities
                                          .contains('Teresa'),
                                      onTap: () => toggleMunicipality('Teresa'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(right: 50),
                              child: NextButtonWhite(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          Kindoftrip(
                                        selectedMunicipalities:
                                            selectedMunicipalities,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(
                                            1.0, 0.0); // Start from right
                                        const end = Offset
                                            .zero; // End at original position
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);
                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ])
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MunicipalityButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  const MunicipalityButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      width: MediaQuery.of(context).size.width * 0.40,
      padding: const EdgeInsets.all(14.0),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(
            isSelected ? const Color(0xFFA52424) : Colors.white,
          ),
          foregroundColor: WidgetStateProperty.all(
            isSelected ? Colors.white : const Color(0xFFA52424),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class Kindoftrip extends StatefulWidget {
  final List<String> selectedMunicipalities;
  const Kindoftrip({super.key, required this.selectedMunicipalities});

  @override
  State<Kindoftrip> createState() => _KindoftripState();
}

class _KindoftripState extends State<Kindoftrip> {
  String? selectedTripType;
  TextEditingController numberOfTravelersController = TextEditingController();
  List<String> tripTypes = [];
  int numberOfTravelers = 1;
  List<String> selectedMunicipalities = [];

  Future<void> fetchTripTypes() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('typeoftrip').get();
    setState(() {
      tripTypes = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  // Update number of travelers based on the selected trip type
  void updateTravelersBasedOnType(String type) {
    setState(() {
      if (type == 'Solo') {
        numberOfTravelersController.text = '1';
        numberOfTravelers = 1;
      } else if (type == 'Partner') {
        numberOfTravelersController.text = '2';
        numberOfTravelers = 2;
      } else {
        numberOfTravelersController.text =
            ''; // Clear the field for other types
        numberOfTravelers = 0;
      }
    });
  }

  // Validate the number of travelers
  void validateTravelers(String text) {
    if (selectedTripType == 'Solo') {
      if (text != '1') {
        numberOfTravelersController.text = '1';
        numberOfTravelers = 1;
      }
    } else if (selectedTripType == 'Partner') {
      if (text != '2') {
        numberOfTravelersController.text = '2';
        numberOfTravelers = 2;
      }
    } else {
      int? input = int.tryParse(text);
      if (input != null) {
        numberOfTravelersController.text = '0'; // Lock to 3 if it's less than 3
        numberOfTravelers = 3;
      } else {
        numberOfTravelers = input ?? 0;
      }
    }
  }

  void initState() {
    super.initState();
    fetchTripTypes();
    selectedMunicipalities = widget.selectedMunicipalities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 16), // Adjust the padding as needed
                child: Closedbutton(),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                '2 of 6',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                'What Kind of Trip?',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA52424)),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<String>(
                        hint: Text('Select'),
                        value: selectedTripType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTripType = newValue;
                            updateTravelersBasedOnType(newValue!);
                          });
                        },
                        isExpanded: true,
                        items: tripTypes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
            Container(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                'Number of Travelers',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA52424)),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 40,
                child: TextField(
                  controller: numberOfTravelersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Number of Travelers',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    if (int.tryParse(text) != null) {
                      setState(() {
                        numberOfTravelers = int.parse(text);
                      });
                    }
                  },
                  readOnly: selectedTripType == 'Solo' ||
                      selectedTripType == 'Partner',
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BackButtonWhite(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.6),
                NextButtonWhite(
                  onPressed: () {
                    print('$numberOfTravelers');
                    if (numberOfTravelers < 3 &&
                        selectedTripType != 'Solo' &&
                        selectedTripType != 'Partner') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                                'The number of travelers does not match the selected trip type. Please select a valid number of travelers.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (numberOfTravelers == 0 &&
                        selectedTripType != 'Family') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                                'The number of travelers does not match the selected trip type. Please select a valid number of travelers.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SelectActivity(
                            selectedMunicipalities: selectedMunicipalities,
                            selectedTripType: selectedTripType,
                            numberOfTravelers: numberOfTravelers,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Start from right
                            const end = Offset.zero; // End at original position
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
