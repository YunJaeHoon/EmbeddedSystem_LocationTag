import 'package:flutter/material.dart';
import 'package:location_tag/screens/home_screen.dart';
import 'package:location_tag/screens/login_screen.dart';

class MoveButton extends StatelessWidget {

  final String screen;
  final String description;

  const MoveButton({
    super.key,
    required this.screen,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if(screen == 'home')
              {
                return const HomeScreen();
              }
              else if(screen == 'login')
              {
                return const LoginScreen();
              }
              else
              {
                return Container();
              }
            }
          ),
        );
      },
      child: Center(
        child: Container(
          height: 50,
          width: 200,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white
            )
          ),
        ),
      ),
    );
  }
}
