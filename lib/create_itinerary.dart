import 'package:flutter/material.dart';

class CityButtons extends StatefulWidget {
  @override
  _CityButtonsState createState() => _CityButtonsState();
}

class _CityButtonsState extends State<CityButtons> {
  final List<String> cityNames = [
    'Angono',
    'Antipolo',
    'Baras',
    'Binangonan',
    'Cainta',
    'Cardona',
    'Jala-Jala',
    'Morong',
    'Montalban',
    'Pililla',
    'San Mateo',
    'Tanay',
    'Taytay',
    'Teresa'
  ];
  Set<int> selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, size: 30),
                      color: Color(0xFFA52424),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    child: Image.asset('assets/LOGO.png'),
                  ),
                  SizedBox(height: 40),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 25),
                    child: Text(
                      'Select Municipality',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF7F5EA),
                      border: Border.all(
                        // Border color
                        width: 2, // Border width
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: AspectRatio(
                      aspectRatio: 0.8,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(),
                        child: Scrollbar(
                          thickness: 8.0,
                          radius: Radius.circular(40),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.4,
                            ),
                            itemCount: cityNames.length,
                            itemBuilder: (context, index) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedIndices.contains(index)
                                          ? Color(0xFFA52424)
                                          : Color(0xFFF7F5EA),
                                  foregroundColor:
                                      selectedIndices.contains(index)
                                          ? Colors.white
                                          : Color(0xFFA52424),
                                  elevation: 5,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  textStyle: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (selectedIndices.contains(index)) {
                                      selectedIndices
                                          .remove(index); // Deselect button
                                    } else {
                                      selectedIndices
                                          .add(index); // Select button
                                    }
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    cityNames[index],
                                    style: TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                    alignment: Alignment.center,
                    child: IconButton(
                      color: Color(0xFFA52424),
                      icon: Icon(Icons.arrow_circle_right, size: 50),
                      onPressed: () {
                        // Navigator.of(context).push(
                        //   PageRouteBuilder(
                        //     pageBuilder: (context, animation, secondaryAnimation) => KindofTrip(),
                        //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        //       const begin = Offset(1.0, 0.0); // Slide from the right
                        //       const end = Offset.zero; // End at the center
                        //       const curve = Curves.easeInOut;
                        //       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        //       var offsetAnimation = animation.drive(tween);

                        //       return SlideTransition(
                        //         position: offsetAnimation,
                        //         child: child,
                        //       );
                        //     },
                        //   ),
                        // );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
