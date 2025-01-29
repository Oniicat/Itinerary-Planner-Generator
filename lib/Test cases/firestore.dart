import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//ignore this part, this is just testing of crud in firestore
void adduser() {
  FirebaseFirestore.instance.collection('Users').add({
    'name': 'Mark',
    'email': 'calitisinmarkgil20@gmail.com',
    'age': 20,
  });
}

void fetchUser() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Users').get();

  for (var doc in querySnapshot.docs) {
    if (kDebugMode) {
      print(doc.data());
    }
  }
}

void createUser(String id, String name, String email, int age) {
  FirebaseFirestore.instance
      .collection('Users')
      .doc(id)
      .set({'name': name, 'email': email, 'age': age});
}

class InsertData extends StatefulWidget {
  const InsertData({super.key});

  @override
  State<InsertData> createState() => _InsertDataState();
}

class _InsertDataState extends State<InsertData> {
  @override
  Widget build(BuildContext context) {
    adduser();
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text('Sample Firestore')),
          body: Center(
            child: Text('Firestore Connected Successful'),
          )),
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Users').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> user = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  trailing: Text('Age: ${user['age']}'),
                );
              }).toList(),
            );
          }),
    );
  }
}
