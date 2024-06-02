import 'package:flutter/material.dart';
import 'package:location_tag/components/custom_app_bar.dart';
import 'package:location_tag/components/move_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(

        // 상단 바
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: CustomAppBar(screenTitle: '위치태그'),
        ),

        body: Column(
          children: [

            SizedBox(height: 20),

            // 로그인 / 회원가입 버튼
            MoveButton(screen: 'login', description: '로그인 / 회원가입'),
            
          ],
        )
      ),
    );
  }
}