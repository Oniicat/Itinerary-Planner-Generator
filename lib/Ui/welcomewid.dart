import 'package:firestore_basics/Ui/navbar.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Welcomewidgets extends StatefulWidget {
  @override
  _getstarted createState() => _getstarted();
}

class _getstarted extends State<Welcomewidgets> {
  final PageController _controller = PageController();
  int currentPage = 0; // To track the current page index

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/discover rizal.png',
      'title': 'Discover Rizal',
      'description':
          'Discover the beauty and adventure of Rizal Province with our user-friendly platform. From breathtaking landscapes to hidden gems, plan your perfect getaway with ease.'
    },
    {
      'image': 'assets/itinerary genrator.png',
      'title': 'Itinerary Generator',
      'description':
          'Easily plan your ideal trip to Rizal, tailored to your preferences and featuring top attractions and experiences!'
    },
    {
      'image': 'assets/tour guide.png',
      'title': 'Tour Guide Booking',
      'description':
          'Easily book local tour guides for personalized experiences, offering insights into Rizal’s culture, history, and '
    },
  ];

  @override
  void initState() {
    super.initState();

    // Add listener to track page changes
    _controller.addListener(() {
      int page = _controller.page?.round() ?? 0;
      if (currentPage != page) {
        setState(() {
          currentPage = page;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFAEF),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image in the center
                  Image.asset(
                    pages[index]['image']!,
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  // Title Text
                  Text(
                    pages[index]['title']!, // Use the 'title' property
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                      height: 20), // Spacing between title and description
                  // Description Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      pages[index]
                          ['description']!, // Use the 'description' property
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
          // Dot indicator at the bottom
          Positioned(
            bottom: 50,
            child: SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                spacing: 16,
                activeDotColor: Color(0xFFA52424),
                dotColor: Colors.grey,
              ),
            ),
          ),
          if (currentPage == pages.length - 1)
            Positioned(
              bottom: 100, // Adjust the position of the button
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to HomeScreen when button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NavBar()), //dito login
                  );
                },
                child: const Text('Get Started'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Color(0xFFA52424),
                    foregroundColor: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
