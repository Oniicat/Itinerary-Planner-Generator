import 'package:flutter/material.dart';
import 'package:firestore_basics/itinerary%20Planner/showitinerary.dart';

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
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              'Itinerary Basket',
              style: TextStyle(fontSize: 27),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: widget.cartItems.isEmpty
                ? Center(child: Text("No items in the cart"))
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
              IconButton(
                icon: Icon(
                  Icons.arrow_circle_left,
                  size: 50,
                  color: Color(0xFFA52424),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  Icons.arrow_circle_right,
                  size: 50,
                  color: Color(0xFFA52424),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Mapwithitems(cartItems: widget.cartItems),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
