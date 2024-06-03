import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location_tag/components/custom_app_bar.dart';
import 'package:location_tag/components/move_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {

  late Future<Map<String, dynamic>?> responseBody;    // 마이페이지 정보 요청에 대한 응답

  @override
  void initState() {
    super.initState();
    responseBody = getMyInfo();   // 마이페이지 정보 가져오기
  }

  // 마이페이지 가져오는 함수
  Future<Map<String, dynamic>?> getMyInfo() async {
    const String url = 'http://172.207.208.62/v1/users/me';
    final request = Uri.parse(url);

    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');

    final response = await http.get(
      request,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      }
    );

    if(response.statusCode == 200)
    {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    else
    {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // 상단 바
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(screenTitle: '마이페이지'),
      ),

      body: Column(
        children: [

          // 마이페이지 데이터
          FutureBuilder<Map<String, dynamic>?>(
            future: responseBody,
            builder: (context, snapshot) {
          
              // 로딩 중 표시
              if (snapshot.connectionState == ConnectionState.waiting)
              {
                return const Center(
                  child: CircularProgressIndicator()
                );
              }
              // 데이터 가져오는 도중 에러 발생
              else if (snapshot.hasError)
              {
                return Center(
                  child: Text('Error: ${snapshot.error}')
                );
              }
              // 데이터가 없을 때
              else if (!snapshot.hasData || snapshot.data == null)
              {
                return const Center(
                  child: Text('No data found')
                );
              }
              // 데이터를 제대로 가져왔을 때
              else
              {
                final data = snapshot.data!;
                return Column(
                  children: [
                    Text(
                      '이름: ${data['user']['name'].toString()}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '계정 생성날짜: ${data['user']['createdAt'].toString()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '계정 수정날짜: ${data['user']['updatedAt'].toString()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 30),

          // 돌아가기 버튼
          const MoveButton(screen: 'home', description: '돌아가기', isLogin: true),

        ],
      ),

    );
  }
}