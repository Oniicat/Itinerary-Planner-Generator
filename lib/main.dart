import 'package:firestore_basics/Ui/navbar.dart';
import 'package:firestore_basics/itinerary%20Planner/map.dart';
import 'package:firestore_basics/itinerary%20generator/select%20municipality_and_kind_of_trip.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  //only include this if using a web
  // Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         apiKey: "AIzaSyBXZ9G9gMm9dULJR6ufHL0668xcjxEaZuA",
  //         authDomain: "lakbayrizal-73493.firebaseapp.com",
  //         projectId: "lakbayrizal-73493",
  //         storageBucket: "lakbayrizal-73493.firebasestorage.app",
  //         messagingSenderId: "731813576417",
  //         appId: "1:731813576417:web:e42121fb63b119bbf301a0",
  //         measurementId: "G-CCTWDT7L03"));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: SelectMunicipality(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Center(
        child: Text('This is an App'),
      )),
    );
  }
}
