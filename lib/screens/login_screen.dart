import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location_tag/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/custom_app_bar.dart';
import '../components/move_button.dart';

class LoginScreen extends StatefulWidget {
  
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final name = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        // 상단 바
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: CustomAppBar(screenTitle: '로그인 / 회원가입'),
        ),

        body: Column(
          children: [

            // name 입력창
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'name',
              ),
              controller: name,
            ),

            const SizedBox(height: 20),

            // 비밀번호 입력창
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              controller: password,
            ),

            const SizedBox(height: 20),

            // Submit 버튼
            FloatingActionButton.extended(
              onPressed: () async {

                final data = {"name": name.text, "password": password.text};

                const String url = 'http://172.207.208.62/v1/users/login';
                final request = Uri.parse(url);
                final response = await http.post(
                  request,
                  headers: {"Content-Type": "application/json"}, 
                  body: jsonEncode(data)
                );

                if(response.statusCode == 201)
                {
                  // JWT 토큰 저장
                  final responseBody = jsonDecode(response.body);
                  final jwt = responseBody['jwt'];
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('jwt', jwt);

                  // 홈 화면으로 이동
                  if(context.mounted)
                  {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return const HomeScreen(isLogin: true);
                        },
                      ),
                    );
                  }
                }

              },
              label: const Text('Submit'),
              icon: const Center(
                child: Icon(Icons.check)
              ),
            ),

            const SizedBox(height: 50),

            // 돌아가기 버튼
            const MoveButton(screen: 'home', description: '돌아가기', isLogin: false),

          ],
        )
      );
  }
}
