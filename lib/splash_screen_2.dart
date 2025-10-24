import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'splash_screen_3.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFFEF8C2), // Background color from SplashScreen1
        child: Center(
          child: SingleChildScrollView( // For responsiveness
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600), // Limit max width for responsiveness
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10), // Match upward positioning from SplashScreen1
                    Text(
                      'Sustainable Farming',
                      style: TextStyle(
                        fontFamily: 'Poppins', // Poppins font
                        fontSize: 30, // Increased for boldness
                        fontWeight: FontWeight.w900, // Maximum boldness
                        color: Color(0xFF0B440E), // Updated text color
                        shadows: [
                         
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/splash2.png', // Keep the original image
                      width: MediaQuery.of(context).size.width * 0.5, // Adjusted to match original intent
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Support farmers with animal feed and compost made from discarded vegetables.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w800, // Medium weight
                          color: Color(0xFF0B440E), // Updated text color
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SplashScreen3()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B440E), // Updated button color
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        fixedSize: Size(303, 53), // Match button width and height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Match radius
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