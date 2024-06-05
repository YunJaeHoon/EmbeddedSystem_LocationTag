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

  late Future<Map<String, dynamic>?> responseBody;        // 마이페이지 정보 요청에 대한 응답
  late Future<List<Map<String, dynamic>>?> trackersBody;  // 내 트래커 정보 요청에 대한 응답

  @override
  void initState() {
    super.initState();
    responseBody = getMyInfo();   // 마이페이지 정보 가져오기
    trackersBody = getMyTrackers();
  }

  // 마이페이지 가져오는 함수
  Future<Map<String, dynamic>?> getMyInfo() async {
    String url = 'http://172.207.208.62/v1/users/me';
    var request = Uri.parse(url);

    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString('jwt');

    var response = await http.get(
      request,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      }
    );

    if(response.statusCode == 200)
    {
      print("aaaaaaaaaaaaaaaaaaaaaaa");
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    else
    {
      return null;
    }
  }

  // 내 트래커 정보 가져오는 함수
  Future<List<Map<String, dynamic>>?> getMyTrackers() async {
    String url = 'http://172.207.208.62/v1/trackers';
    var request = Uri.parse(url);

    var prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString('jwt');

    var response = await http.get(
      request,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $jwt',
      }
    );

    if(response.statusCode == 200)
    {
      var decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var trackers = decodedResponse['trackers'] as List<dynamic>;

      return trackers.map((tracker) => tracker as Map<String, dynamic>).toList();
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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
        
            // 내 트래커 데이터
            FutureBuilder<List<Map<String, dynamic>>?>(
              future: trackersBody,
              builder: (context, snapshot) {
        
                print("#################");
                print(snapshot);
                print("#################");
            
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
                      const Text('내 위치태그 정보',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600
                        ),
                      ),
        
                      const SizedBox(height: 15),
        
                      for(Map<String, dynamic> info in data)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '트래커 이름: ${info['id'].toString()}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              'serial number: ${info['serialNumber'].toString()}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              '위치: ${info['location'].toString()}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
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
      ),

    );
  }
}