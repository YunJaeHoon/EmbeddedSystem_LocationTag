import 'package:flutter/material.dart';
import 'package:location_tag/screens/home_screen.dart';

// run application
void main() {
  runApp(const App());
}

// App widget
class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
