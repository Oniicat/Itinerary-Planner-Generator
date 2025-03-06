import 'package:firestore_basics/Ui/top_icon.dart';
import 'package:firestore_basics/Ui/white_buttons.dart';
import 'package:flutter/material.dart';
import 'package:firestore_basics/itinerary%20Planner/plan_itinerary.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({required this.cartItems});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  void _removeFromCart(Map<String, dynamic> destination) async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      widget.cartItems.remove(destination);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('${destination['name']} has been removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = widget.cartItems.removeAt(oldIndex);
      widget.cartItems.insert(newIndex, item);
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 320),
            child: Text(
              '2 of 3',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'Itinerary Basket',
              style: TextStyle(fontSize: 27),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: widget.cartItems.isEmpty
                ? Center(child: Text("No destinations added yet"))
                : ReorderableListView.builder(
                    itemCount: widget.cartItems.length,
                    onReorder: _reorderItems,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return ListTile(
                        key: ValueKey(item), // Unique key for each item
                        title: Text(item['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['address'] ?? "No address provided"),
                            Text("Pricing: ${item['pricing']}")
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeFromCart(item),
                        ),
                      );
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: BackButtonWhite(),
              ),
              SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: NextButtonWhite(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Mapwithitems(cartItems: widget.cartItems),
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
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
