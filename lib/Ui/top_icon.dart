import 'package:firestore_basics/Ui/navbar.dart';
import 'package:flutter/material.dart';

class TopIcon extends StatelessWidget {
  final String text; // New customizable text property
  final VoidCallback? onPressed;

  const TopIcon({Key? key, this.text = '1 of 6', this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 70,
          ),
          Center(
            child: Image.asset(
              'assets/LOGO.png',
              width: 100,
              height: 100,
            ),
          ),
          SizedBox(
            width: 60,
          ),
          GestureDetector(
            onTap: onPressed ??
                () => Navigator.pushReplacement(
                      // Ensure correct navigation
                      context,
                      MaterialPageRoute(builder: (context) => NavBar()),
                    ), // Default to pop if no onPressed provided
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFA52424),
                shape: BoxShape.circle,
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.3),
                //     spreadRadius: 2,
                //     blurRadius: 6,
                //     offset: Offset(0, 3),
                //   ),
                // ],
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
