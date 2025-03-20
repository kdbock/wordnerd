import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Comment out this line if you're not using it yet
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
// Add this import

import '../theme/brand_colors.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'screens/rss_feed_screen.dart'
    as rss; // Import the RSSFeedScreen with alias

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Add this method for Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      // Initialize Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // If user cancels the sign-in process
      if (googleUser == null) {
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print("✅ Google login successful for user: ${userCredential.user?.uid}");

      // Navigate to home screen
      _navigateToHome();
    } catch (e) {
      print("❌ Google login error: $e");
      _showAlert('Login Error', 'Google login failed. Please try again.');
    }
  }

  // Add this method for Apple Sign-In
  Future<void> _signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      print("✅ Apple login successful for user: ${userCredential.user?.uid}");

      // Navigate to home screen
      _navigateToHome();
    } catch (e) {
      print("❌ Apple login error: $e");
      _showAlert('Login Error', 'Apple login failed. Please try again.');
    }
  }

  // Generate a nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  // Hash the nonce with SHA-256
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Navigate to home screen
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const rss.RSSFeedScreen(
          feedURL:
              'https://www.neusenews.com/index?format=rss', // Replace with your actual RSS feed URL
          title: 'RSS Feed',
        ),
      ),
    );
  }

  // Show alert dialog
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo image
                  Image.asset(
                    'assets/images/neusenewslogo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  // Login text
                  Text(
                    'Neuse News',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.darkGray,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Please login to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email TextField
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to RSSFeedScreen after login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const rss.RSSFeedScreen(
                              feedURL:
                                  'https://www.neusenews.com/index?format=rss', // Replace with your actual RSS feed URL
                              title: 'RSS Feed',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Forgot Password link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Register link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Don\'t have an account? Register',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Social Login Options
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Text(
                          'Or sign in with',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Login Button
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: _signInWithGoogle,
                                tooltip: 'Sign in with Google',
                              ),
                            ),

                            // Apple Login Button
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.apple,
                                  color: Colors.black,
                                  size: 30,
                                ),
                                onPressed: _signInWithApple,
                                tooltip: 'Sign in with Apple',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Version text
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
