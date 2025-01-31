import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_basics/Ui/back_button_red.dart';
import 'package:firestore_basics/Ui/forward_button_red.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
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
              padding: const EdgeInsets.all(30.0),
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
                      2.1, // Width-to-height ratio for buttons in short sizing ng button
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
                    Navigator.pop(context, {
                      'selectedActivities': selectedActivities.toList(),
                      'numberOfTravelers': numberOfTravelers,
                      'selectedMunicipalities': selectedMunicipalities,
                      'selectedTripType': selectedTripType,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select at least one activity')),
                    );
                  }
                },
              ),
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
