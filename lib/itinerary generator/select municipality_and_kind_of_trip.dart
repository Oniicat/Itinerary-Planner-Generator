import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/Ui/button_red.dart';
import 'package:firestore_basics/Ui/forward_button_red.dart';
import 'package:firestore_basics/itinerary%20generator/select_activity_and_set_budget.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    padding: const EdgeInsets.all(3.0),
                    width: MediaQuery.of(context).size.width * 0.82,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Row(
                                children: [
                                  MunicipalityButton(
                                    text: 'Angono',
                                    isSelected: selectedMunicipalities
                                        .contains('Angono'),
                                    onTap: () => toggleMunicipality('Angono'),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  MunicipalityButton(
                                    text: 'Antipolo',
                                    isSelected: selectedMunicipalities
                                        .contains('Antipolo'),
                                    onTap: () => toggleMunicipality('Antipolo'),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Row(
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
                                    onTap: () => toggleMunicipality('Cardona'),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Row(
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
                                children: [
                                  MunicipalityButton(
                                    text: 'Montalban',
                                    isSelected: selectedMunicipalities
                                        .contains('Montalban'),
                                    onTap: () =>
                                        toggleMunicipality('Montalban'),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  MunicipalityButton(
                                    text: 'Pililla',
                                    isSelected: selectedMunicipalities
                                        .contains('Pililla'),
                                    onTap: () => toggleMunicipality('Pililla'),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Row(
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
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 50),
                        child: ForwardButtonRed(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Kindoftrip(
                                  selectedMunicipalities:
                                      selectedMunicipalities,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ])
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
  const MunicipalityButton(
      {super.key,
      required this.text,
      required this.onTap,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      width: MediaQuery.of(context).size.width * 0.39,
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5), // This sets the border radius to 20
            ),
          ),
          backgroundColor: WidgetStateProperty.all(
              isSelected ? Color(0xFFA52424) : Colors.white),
          foregroundColor: WidgetStateProperty.all(
              isSelected ? Colors.white : Color(0xFFA52424)),
        ),
        onPressed: onTap,
        child: Text(text),
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
        numberOfTravelers = 3;
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
      if (input != null && input < 3) {
        numberOfTravelersController.text = '3'; // Lock to 3 if it's less than 3
        numberOfTravelers = 3;
      } else {
        numberOfTravelers = input ?? 3;
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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100),
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
                BackButtonRed(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.6),
                ForwardButtonRed(
                  onPressed: () {
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
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectActivity(
                            selectedMunicipalities: selectedMunicipalities,
                            selectedTripType: selectedTripType,
                            numberOfTravelers: numberOfTravelers,
                          ),
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
