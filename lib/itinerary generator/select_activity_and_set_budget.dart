import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/Ui/forward_button_red.dart';
import 'package:firestore_basics/Ui/textfield.dart';
import 'package:firestore_basics/Ui/top_icon.dart';
import 'package:firestore_basics/itinerary%20generator/select_destinations.dart';
import 'package:flutter/material.dart';

class SelectActivity extends StatefulWidget {
  final int numberOfTravelers;
  final List<String> selectedMunicipalities;
  final String? selectedTripType;

  const SelectActivity({
    super.key,
    required this.selectedMunicipalities,
    required this.selectedTripType,
    required this.numberOfTravelers,
  });

  @override
  State<SelectActivity> createState() => _SelectActivityState();
}

class _SelectActivityState extends State<SelectActivity> {
  int numberOfTravelers = 1;
  List<String> selectedMunicipalities = [];
  String? selectedTripType;
  List<String> activityType = [];
  Set<String> selectedActivities =
      {}; // Set to store multiple selected activities

  Future<void> fetchTripTypes() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('typeofactivity').get();
    setState(() {
      activityType = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchTripTypes();
    numberOfTravelers = widget.numberOfTravelers;
    selectedMunicipalities = widget.selectedMunicipalities;
    selectedTripType = widget.selectedTripType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(10.0), // Set the height here
        child: AppBar(
          automaticallyImplyLeading: false,
        ),
      ),
      body: Column(
        children: [
          TopIcon(
            text: '3 of 6',
          ),
          SizedBox(height: 20),
          Text(
            'Type of Activity',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA52424)),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.82,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 8.0, // Spacing between columns
                  mainAxisSpacing: 8.0, // Spacing between rows
                  childAspectRatio:
                      2.5, // Width-to-height ratio for buttons in short sizing ng button
                ),
                itemCount: activityType.length,
                itemBuilder: (context, index) {
                  String activity = activityType[index];
                  return ActivityButton(
                    text: activity,
                    isSelected: selectedActivities.contains(activity),
                    onTap: () {
                      setState(() {
                        if (selectedActivities.contains(activity)) {
                          selectedActivities.remove(activity);
                        } else {
                          selectedActivities.add(activity);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20),
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
                  if (selectedActivities.isNotEmpty) {
                    print('Selected Activities: $selectedActivities');
                    print('Selected Municipalities: $selectedMunicipalities');
                    print('Selected Trip Type: $selectedTripType');
                    print('Number of Travelers: $numberOfTravelers');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetBudgetandDays(
                          selectedActivities: selectedActivities,
                          selectedMunicipalities: selectedMunicipalities,
                          selectedTripType: selectedTripType,
                          numberOfTravelers: numberOfTravelers,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select at least one activity')),
                    );
                  }
                },
              )
            ],
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

class ActivityButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFFA52424) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFFA52424),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}

class SetBudgetandDays extends StatefulWidget {
  final int numberOfTravelers;
  final List<String> selectedMunicipalities;
  final String? selectedTripType;
  final Set<String> selectedActivities;
  const SetBudgetandDays({
    super.key,
    required this.selectedActivities,
    required this.selectedMunicipalities,
    required this.selectedTripType,
    required this.numberOfTravelers,
  });

  @override
  State<SetBudgetandDays> createState() => _SetBudgetandDaysState();
}

class _SetBudgetandDaysState extends State<SetBudgetandDays> {
  TextEditingController minBudgetController = TextEditingController();
  TextEditingController maxBudgetController = TextEditingController();

  int numberOfTravelers = 1;
  List<String> selectedMunicipalities = [];
  String? selectedTripType;
  List<String> activityType = [];
  Set<String> selectedActivities = {};

  int? minBudget;
  int? maxBudget;

  int numberOfDays = 0;
  int days = 0;

  Widget _buildDayDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: (numberOfDays >= 1 && numberOfDays <= 7) ? numberOfDays : 1,
          items: List.generate(7, (index) => index + 1)
              .map((day) => DropdownMenuItem(
                    value: day,
                    child: Text('$day'),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                numberOfDays = value; // Update the number of days
              });
            }
          },
        ),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(10.0), // Set the height here
        child: AppBar(
          automaticallyImplyLeading: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            TopIcon(text: '4 of 6'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA52424)),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 40),
                          Text(
                            'Minimum',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 25),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: MyTextField(
                              keyboardType: TextInputType.number,
                              controller: minBudgetController,
                              hintText: 'Minimum Budget',
                              obscureText: false,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(width: 40),
                          Text(
                            'Maximum',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 25),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: MyTextField(
                              keyboardType: TextInputType.number,
                              controller: maxBudgetController,
                              hintText: 'Maximum Budget',
                              obscureText: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Number of Days',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA52424)),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                    ),
                    Text(
                      'How many?',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 60,
                    ),
                    _buildDayDropdown()
                  ],
                ),
              ],
            ),
            const Spacer(), // Push buttons to the bottom
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
                    // Parse budget input
                    int? min = int.tryParse(minBudgetController.text);
                    int? max = int.tryParse(maxBudgetController.text);

                    if (min == null || max == null || min > max) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(
                                  'Your minimum and maximum budget is not valid'),
                            );
                          });
                      return;
                    }

                    setState(() {
                      minBudget = min;
                      maxBudget = max;
                      numberOfDays = numberOfDays;
                      numberOfTravelers = widget.numberOfTravelers;
                      selectedMunicipalities = widget.selectedMunicipalities;
                      selectedTripType = widget.selectedTripType;
                      selectedActivities = widget.selectedActivities;
                    });
                    print('Minimum: $minBudget');
                    print('Maximum: $maxBudget');
                    print('Number of days: $numberOfDays');
                    print('Selected Activities: $selectedActivities');
                    print('Selected Municipalities: $selectedMunicipalities');
                    print('Selected Trip Type: $selectedTripType');
                    print('Number of Travelers: $numberOfTravelers');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectDestinations(
                                selectedActivities: selectedActivities,
                                selectedMunicipalities: selectedMunicipalities,
                                selectedTripType: selectedTripType,
                                numberOfTravelers: numberOfTravelers,
                                minBudget: minBudget,
                                maxBudget: maxBudget,
                                numberOfDays: numberOfDays)));
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
