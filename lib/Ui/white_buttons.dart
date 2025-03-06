import 'package:firestore_basics/Ui/navbar.dart';
import 'package:flutter/material.dart';

class BackButtonWhite extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonWhite({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ??
          () =>
              Navigator.pop(context), // Default to pop if no onPressed provided
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFDFAEF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            color: const Color.fromARGB(255, 165, 36, 36),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class NextButtonWhite extends StatelessWidget {
  final VoidCallback? onPressed;

  const NextButtonWhite({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ??
          () =>
              Navigator.pop(context), // Default to pop if no onPressed provided
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFDFAEF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_forward_ios,
            color: const Color.fromARGB(255, 165, 36, 36),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class Closedbutton extends StatelessWidget {
  final VoidCallback? onPressed;

  const Closedbutton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onPressed ?? () => _showCancelDialog(context), // Trigger the dialog
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFDFAEF), // Background color
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              blurRadius: 6, // Softness of shadow
              spreadRadius: 2, // How much shadow spreads
              offset: const Offset(2, 2), // Shadow direction
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.close,
            color: Color(0xFFA52424), // Icon color
            size: 18,
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content:
              const Text('Are you sure you want to cancel creating itinerary?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog first
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => NavBar()),
                  (route) => false, // Remove all previous routes
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
