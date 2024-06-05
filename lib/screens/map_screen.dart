import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location_tag/components/custom_app_bar.dart';
import 'package:location_tag/components/move_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  late Future<List<Map<String, dynamic>>?> trackersBody;  // 내 트래커 정보 요청에 대한 응답

  @override
  void initState() {
    super.initState();
    trackersBody = getMyTrackers();
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
        child: CustomAppBar(screenTitle: '위치태그 지도'),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: trackersBody,
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

            if(data.isEmpty)
            {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 550,
                    child: NaverMap(
                      options: const NaverMapViewOptions(),
                      onMapReady: (controller) {
                      },
                    ),
                  ),
              
                  const SizedBox(height: 30),
              
                  const MoveButton(screen: 'home', description: '돌아가기', isLogin: true),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 550,
                  child: NaverMap(
                    options: const NaverMapViewOptions(
                      initialCameraPosition: NCameraPosition(
                        target: NLatLng(37.584791, 127.0267115),
                        zoom: 15.0
                      )
                    ),
                    onMapReady: (controller) {
                      for(Map<String, dynamic> info in data)
                      {
            
                        RegExp regExp = RegExp(r'lat:\s*([\d.]+),\s*long:\s*([\d.]+)');
                        Match? match = regExp.firstMatch(info['location'].toString())!;
            
                        var marker = NMarker(
                          id: info['id'].toString(),
                          position: NLatLng(
                            double.parse(match.group(1)!),
                            double.parse(match.group(2)!)
                          )
                        );

                        controller.addOverlay(marker);

                        var onMarkerInfoWindow = NInfoWindow.onMarker(
                          id: marker.info.id, text: marker.info.id
                        );
                        
                        marker.openInfoWindow(onMarkerInfoWindow);
                      }
                    },
                  ),
                ),
            
                const SizedBox(height: 30),
            
                const MoveButton(screen: 'home', description: '돌아가기', isLogin: true),
              ],
            );
          }
        }
      ),

    );
  }
}