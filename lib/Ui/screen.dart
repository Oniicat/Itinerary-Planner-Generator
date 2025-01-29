import 'package:flutter/material.dart';

class ScrollableDraggable extends StatefulWidget {
  const ScrollableDraggable({super.key});

  @override
  State<ScrollableDraggable> createState() => _ScrollableDraggableState();
}

class _ScrollableDraggableState extends State<ScrollableDraggable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggableScrollableSheet(
        builder: (BuildContext context, ScrollController scrollcontroller) {
          return Container(
            // color: Colors.purple,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 1.5)),

            child: ListView.builder(
              controller: scrollcontroller,
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('Sample $index'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
