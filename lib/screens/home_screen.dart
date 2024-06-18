import 'package:flutter/material.dart';
import 'package:location_tag/components/custom_app_bar.dart';
import 'package:location_tag/components/move_button.dart';
import 'package:location_tag/screens/login_screen.dart';
import 'package:location_tag/screens/my_page_screen.dart';

class HomeScreen extends StatelessWidget {

  final bool isLogin;

  const HomeScreen({
    super.key,
    required this.isLogin
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        // 상단 바
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: CustomAppBar(screenTitle: '위치태그'),
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
          
              // 로그인 / 회원가입 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isLogin ? '마이페이지' : '로그인 / 회원가입',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return isLogin ? const MyPageScreen() : const LoginScreen();
                          }
                        ),
                      );
                    },
                    child: const Center(
                      child: Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Colors.blue,
                      )
                    ),
                  ),
                  const SizedBox(width: 10)
                ],
              ),
          
              const SizedBox(height: 10),

              isLogin ? MoveButton(screen: 'add_new_tag', description: '새로운 위치 태그 추가', isLogin: isLogin) : Container(),
          
              const SizedBox(height: 10),

              isLogin ? MoveButton(screen: 'map', description: '지도', isLogin: isLogin) : Container(),
              
            ],
          ),
        )
      ),
    );
  }
}