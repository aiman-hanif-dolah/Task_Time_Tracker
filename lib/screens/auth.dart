import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

import '../../../main.dart';
import '../widgets/button.dart';
import '../widgets/colors.dart';
import '../widgets/dialog.dart';
import '../widgets/input.dart';

final Logger logger = Logger();

enum AuthFormType { signIn, signUp, forgotPassword }

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    await Future.delayed(const Duration(seconds: 3));
    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AuthPage();
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  AuthFormType _authFormType = AuthFormType.signIn;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;

  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _username = '';
  bool _passwordVisible = true;
  late bool isMobileApp;
  late bool isWebOnPhone;

  @override
  void initState() {
    super.initState();
    _passwordVisible = true;
    _checkUserLoggedIn();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void backToLogin() {
    setState(() => _authFormType = AuthFormType.signIn);
  }

  Future<void> _sendPasswordResetEmail() async {
    _formKey.currentState?.save();
    if (_email.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: _email.trim());
        _showSnackBar('Password reset email has been sent to $_email');
      } catch (e) {
        logger.e('Error occurred', error: e);
      }
    } else {
      _showSnackBar('Please enter your email');
    }
  }

  void _checkUserLoggedIn() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _navigateToMyApp();
    }
  }

  void _navigateToMyApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  void togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void switchFormState(String state) {
    _formKey.currentState?.reset();
    setState(() {
      _authFormType = AuthFormType.values.firstWhere(
            (type) => type.toString().split('.').last == state,
        orElse: () => _authFormType,
      );
      _animationController.forward(from: 0.0);
    });
  }

  void _submit(BuildContext context) async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      try {
        if (_authFormType == AuthFormType.signIn) {
          await _handleSignIn();
        } else {
          await _handleSignUp();
        }
      } on Exception catch (e) {
        if (!mounted) return;
        _handleAuthError(e, context);
      }
    }
  }

  Future<void> _handleSignIn() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: _username.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;
        try {
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: userSnapshot.get('email'),
            password: _password.trim(),
          );
          logger.i('Login: ${userCredential.user?.email}');
          if (!mounted) return;
          _navigateToMyApp();
        } on FirebaseAuthException catch (e) {
          logger.e("Sign in failed: $e");
          _showAuthErrorDialog(context, e.message ?? 'An error occurred during sign-in.');
        }
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return CustomDialog(
              title: 'Username Not Found',
              content: 'The username you entered does not exist.',
              backgroundColor: secondaryColor,
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      logger.e("Sign in failed: $e");
    }
  }

  Future<void> _handleSignUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password.trim(),
      );
      logger.i("Registration successful: ${userCredential.user?.email}");

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': _email.trim(),
        'username': _username.trim(),
      });

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CustomDialog(
            title: 'Registration Successful',
            content: 'You have been successfully registered!',
            backgroundColor: secondaryColor,
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 40,
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToMyApp();
                  },
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      logger.e("Registration failed: $e");
    }
  }

  void _handleAuthError(Exception e, BuildContext context) {
    logger.e('Error occurred', error: e);
    String errorMessage = 'An error occurred';
    if (e is FirebaseAuthException) {
      errorMessage = e.message ?? 'An error occurred during authentication.';
    }
    _showAuthErrorDialog(context, errorMessage);
  }

  void _showAuthErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          title: const Text(
            'Authentication Error',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text(
                  'OK',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    isMobileApp = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
    isWebOnPhone = kIsWeb && screenWidth < 600;

    return Scaffold(
      body: isMobileApp
          ? _buildMobileView(screenWidth)
          : (isWebOnPhone ? _buildMobileView(screenWidth) : _buildDesktopView(screenWidth)),
    );
  }

  Widget _buildMobileView(double screenWidth) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedSwitcher(
            duration: _animationController.duration!,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: screenWidth * 0.1),
                  Text("Task Time\nTracker⏱️", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
                  SizedBox(height: screenWidth * 0.05),
                  Image.asset("assets/images/logo.png", height: 200, width: 200,),
                  SizedBox(height: screenWidth * 0.01),
                  _buildTitle(),
                  const SizedBox(height: 10.0),
                  ..._buildFormFields(),
                  ..._buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopView(double screenWidth) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedSwitcher(
            duration: _animationController.duration!,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Task Time Tracker⏱️",
                    style: TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30.0),
                  Image.asset("assets/images/logo.png", height: 200, width: 200),
                  const SizedBox(height: 30.0),
                  _buildTitle(),
                  const SizedBox(height: 10.0),
                  Container(
                    width: 400, // Adjust the width as needed
                    child: Column(
                      children: _buildFormFields(),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  ..._buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      if (_authFormType == AuthFormType.signUp || _authFormType == AuthFormType.forgotPassword)
        CustomInputField(labelText: 'Email', prefixIcon: Icons.email, onSaved: (value) => _email = value, validator: _emailValidator),
      if (_authFormType != AuthFormType.forgotPassword)
        CustomInputField(labelText: 'Username', prefixIcon: Icons.person, onSaved: (value) => _username = value, validator: _usernameValidator),
      if (_authFormType != AuthFormType.forgotPassword)
        CustomInputField(
          labelText: 'Password',
          prefixIcon: Icons.lock,
          suffixIcon: _passwordVisible ? Icons.visibility_off : Icons.visibility,
          obscureText: _passwordVisible,
          suffixIconPressed: togglePasswordVisibility,
          onSaved: (value) => _password = value,
          validator: _passwordValidator,
        ),
    ];
  }

  Widget _buildTitle() {
    String title = _authFormType == AuthFormType.signIn ? 'Login' :
    _authFormType == AuthFormType.signUp ? 'Register' : 'Reset Password';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
    );
  }

  List<Widget> _buildActionButtons() {
    return [
      if (_authFormType == AuthFormType.forgotPassword)
        CustomButton(text: 'Reset', onPressed: _sendPasswordResetEmail),
      if (_authFormType == AuthFormType.forgotPassword)
        CustomButton(text: 'Back to Login?', onPressed: () => switchFormState('signIn')),
      if (_authFormType == AuthFormType.signIn)
        CustomButton(text: 'Login', onPressed: () => _submit(context)),
      if (_authFormType == AuthFormType.signIn)
        CustomButton(text: 'Create an Account', onPressed: () => switchFormState('signUp')),
      if (_authFormType == AuthFormType.signIn)
        CustomButton(text: 'Forgot Password?', onPressed: () => switchFormState('forgotPassword')),
      if (_authFormType == AuthFormType.signUp)
        CustomButton(text: 'Register', onPressed: () => _submit(context)),
      if (_authFormType == AuthFormType.signUp)
        CustomButton(text: 'Already have an account? Login', onPressed: () => switchFormState('signIn')),
    ];
  }

  String? _emailValidator(String? value) {
    if (value!.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _usernameValidator(String? value) {
    if (value!.isEmpty) return 'Please enter your username';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value!.isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return null;
  }
}
