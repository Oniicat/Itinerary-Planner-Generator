import 'package:firestore_basics/itinerary%20Planner/itinerary%20trip%20list.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firestore_basics/itinerary%20Planner/itinerary%20trip%20list.dart';

class CarouselSlide extends StatefulWidget {
  @override
  _CarouselSliderstate createState() => _CarouselSliderstate();
}

class _CarouselSliderstate extends State<CarouselSlide> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust viewportFraction based on screen width
    double viewportFraction = screenWidth > 400 ? 0.30 : 0.45;
    return Scaffold(
      appBar: AppBar(
        title: Text('Carousel'),
      ),
      body: content(viewportFraction),
    );
  }

  Widget content(viewportFraction) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CarouselSlider(
          items: [
            'Tinipak River',
            'Mt. Tagapo',
            'Pililla Windmill',
            'Pililla Windmill',
            'Pililla Windmill',
            'Pililla Windmill',
            'Pililla Windmill'
          ].map((e) {
            return Container(
                width: 200,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    color: Color(0xFFA52424),
                    borderRadius: BorderRadius.circular(20)),
                child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFA52424),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      textStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("$e")));
          }).toList(),
          options: CarouselOptions(
            enlargeCenterPage: false,
            height: 50,
            viewportFraction: viewportFraction,
            enableInfiniteScroll: false,
            scrollPhysics:
                ClampingScrollPhysics(), // Prevent any bouncing effect
            initialPage: 0, // Make sure it starts from the first item
            padEnds: false,
          ),
        )
      ],
    );
  }
}

class appbarprof extends StatefulWidget {
  @override
  _appbarprofstate createState() => _appbarprofstate();
}

class _appbarprofstate extends State<appbarprof> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Text('Profile shi')],
      ),
    );
  }
}

class TripItem {
  final String imagePath;
  final String title;

  TripItem(this.imagePath,
      this.title); //array na magkasama img saka text nung destination
  static final List<TripItem> tripItems = [
    TripItem('assets/dest1.png', 'Destination 1'),
    TripItem('assets/dest2.jpg', 'Destination 2'),
    TripItem('assets/dest3.jpg', 'Destination 3'),
    TripItem('assets/dest4.jpg', 'Destination 4'),
  ];
}

class Landingpage extends StatefulWidget {
  Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  final List<String> Kindoftrip = [
    'Hiking',
    'Beach',
    'Museum',
    'Park',
    'Hiking Trail'
  ];

  int selectedIndex = -1; // -1 means no selection
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [
          SizedBox(
            height: 80,
          ),
          Container(
            width:
                MediaQuery.of(context).size.width * 0.9, // Match button width
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space between children
              children: [
                Row(
                  children: [
                    // ClipOval(
                    //   child: Transform.scale(
                    //     scale: 1.3,
                    //     child: Image.asset(
                    //       'assets/Rae.jpeg',
                    //       width: 50,
                    //       height: 50,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 20),
                    Text(
                      'Welcome Traveler!',
                      style: TextStyle(
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.history),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ItineraryListScreen()),
                        );
                      },
                      iconSize: 30.0,
                      color: Color(0xFFA52424),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {},
                      iconSize: 30.0,
                      color: Color(0xFFA52424),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      'Discover',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(
                      'Top Destinations',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                      margin: EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'See all',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                            color: Colors.grey,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TripItem.tripItems.map((item) {
                return Container(
                  width: 150,
                  height: 250,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        child: Image.asset(
                          item.imagePath,
                          width: 30,
                          height: 10,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        alignment: Alignment.topLeft,
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
