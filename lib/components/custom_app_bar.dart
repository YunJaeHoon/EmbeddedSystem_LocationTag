import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {

  final String screenTitle;

  const CustomAppBar({
    required this.screenTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text(
            screenTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue[200],
          elevation: 0.0,
        ),
      ],
    );
  }
}