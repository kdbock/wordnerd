import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/brand_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  bool _dailyNewsletterOn = false;
  bool _breakingNewsOn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Username Field
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Email (Username)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                ),

                const SizedBox(height: 12),

                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 12),

                // Phone Field
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 12),

                // ZIP Field
                TextField(
                  controller: _zipController,
                  decoration: const InputDecoration(
                    hintText: 'ZIP Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),

                // Daily Newsletter Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daily 7:00 AM Newsletter'),
                    Switch(
                      value: _dailyNewsletterOn,
                      onChanged: (value) {
                        setState(() {
                          _dailyNewsletterOn = value;
                        });
                      },
                      activeColor: BrandColors.gold,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Breaking News Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Breaking News Text Alerts'),
                    Switch(
                      value: _breakingNewsOn,
                      onChanged: (value) {
                        setState(() {
                          _breakingNewsOn = value;
                        });
                      },
                      activeColor: BrandColors.gold,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Create Account Button
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Create Account'),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createAccount() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showAlert('Error', 'Please provide a username (email) and password.');
      return;
    }

    try {
      // Show loading indicator
      setState(() {
        // Add a loading state variable if needed
      });

      // Break the process into clear steps
      // Step 1: Create the authentication account
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Verify we have a user before proceeding
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user: No user returned');
      }

      // Step 3: Create the Firestore document
      final userData = {
        'phone': _phoneController.text.trim(),
        'zip': _zipController.text.trim(),
        'dailyNewsletter': _dailyNewsletterOn,
        'breakingNewsAlerts': _breakingNewsOn,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData);

      _showAlert('Success', 'Your account has been created.');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      _showAlert('Registration Failed', errorMessage);
    } catch (e) {
      print('Error creating account: ${e.toString()}');
      _showAlert(
          'Error', 'An unexpected error occurred. Please try again later.');
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
