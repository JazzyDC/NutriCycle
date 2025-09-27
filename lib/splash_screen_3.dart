import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'login_screen.dart';
class SplashScreen3 extends StatelessWidget {
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
                      'Smart Monitoring',
                      style: TextStyle(
                        fontFamily: 'Poppins', // Poppins font
                        fontSize: 30, // Increased for boldness
                        fontWeight: FontWeight.w900, // Maximum boldness
                        color: Color(0xFF0B440E), // Updated text color
                        shadows: [
                          
                        ],
                      ),
                    ),
                    SizedBox(height: 60), // Match spacing from SplashScreen1
                    Image.asset(
                      'assets/splash3.png', // Keep the original image
                      width: MediaQuery.of(context).size.width * 0.5,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Track the process with real-time updates and ensure quality results.',
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
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        ); // Add navigation to the main app screen here
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
                        'Get Started',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold, // Bold font weight
                          color: Color(0xFFFEF8C2),
                        ),
                      ),
                    ),
                    SizedBox(height: 40), // Match spacing from SplashScreen1
                    RichText(
                      textAlign: TextAlign.center, // Center align the text
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'By continuing you agree to our ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500, // Medium font weight
                              color: Color(0xFF0B440E),
                            ),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold, // Bold for emphasis
                              color: Color(0xFF0B440E),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Add navigation or action for Terms & Conditions
                                print('Terms & Conditions tapped'); // Placeholder
                              },
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500, // Medium font weight
                              color: Color(0xFF0B440E),
                            ),
                          ),
                          TextSpan(
                            text: 'to ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500, // Medium font weight
                              color: Color(0xFF0B440E),
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Notice',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold, // Bold for emphasis
                              color: Color(0xFF0B440E),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Add navigation or action for Privacy Notice
                                print('Privacy Notice tapped'); // Placeholder
                              },
                          ),
                        ],
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