import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location_tag/components/custom_app_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // 상단 바
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(screenTitle: '위치태그 지도'),
      ),

      body: NaverMap(
          options: const NaverMapViewOptions(),
          onMapReady: (controller) {
            print("네이버 맵 로딩됨!");
          },
        ),

    );
  }
}