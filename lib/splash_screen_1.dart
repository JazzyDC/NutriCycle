import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer
import 'splash_screen_2.dart';

class SplashScreen1 extends StatelessWidget {
  const SplashScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFEF8C2), // Background color from spec
        child: Center(
          child: SingleChildScrollView( // For responsiveness
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600), // Limit max width for responsiveness
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10), // Reduced from 20 to 10 to move text upward
                    Text(
                      'Transform Waste',
                      style: TextStyle(
                        fontFamily: 'Poppins', // Poppins font
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0B440E), // Updated text color
                      ),
                    ),
                    SizedBox(height: 60),
                    Image.asset(
                      'assets/splash1.png', 
                      width: MediaQuery.of(context).size.width * 100.0,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Convert cabbage waste into useful products through AI & IoT.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w800, 
                          color: Color(0xFF0B440E), 
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SplashScreen2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B440E), // Button color from spec
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        fixedSize: Size(303, 53), // Set button width to 283
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Radius set to 15
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold, // Bold font weight
                         color: Color(0xFFFEF8C2),
                        ),
                      ),
                    ),
                   
                         
                          
                          
                         
                            
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}