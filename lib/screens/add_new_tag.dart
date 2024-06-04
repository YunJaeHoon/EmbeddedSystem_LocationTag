import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:location_tag/components/custom_app_bar.dart';
import 'package:location_tag/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewTag extends StatefulWidget {
  const AddNewTag({super.key});

  @override
  State<AddNewTag> createState() => _AddNewTagState();
}

class _AddNewTagState extends State<AddNewTag> {

  bool isScanning = false;
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
    }

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        startScan();
      } else {
        print("error!!!!!!!");
      }
    });
  }

  void startScan() async {

    print('try connection');

    setState(() {
      isScanning = true;
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15));

    FlutterBluePlus.scanResults.listen((results) {

      if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');

          setState(() {
            scanResults = results;
          });
      }
      else
      {
        print('nothing...');
      }

    });

  }

  Future<void> stopScan() async {

    setState(() {
      isScanning = false;
    });

    print('scanResults : $scanResults');

    await FlutterBluePlus.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: CustomAppBar(screenTitle: '새로운 위치 태그 연결'),
      ),

      body: scanningDevices(),
    );
  }

  Widget scanningDevices() {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: isScanning ? null : startScan,
              child: Text(isScanning ? 'Scanning...' : 'Scan'),
            ),
            ElevatedButton(
              onPressed: stopScan,
              child: const Text('Stop!'),
            ),
          ],
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Scanning Devices',
            style: TextStyle(
                color: Colors.blue[300], fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
          
            itemCount: scanResults.length,
            itemBuilder: (BuildContext context, int index) {
          
              var scanResult = scanResults[index];
          
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 5.0, vertical: 5.0),
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[200],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bluetooth),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          scanResult.device.advName.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID : [${scanResult.device.remoteId.toString()}]',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Colors.lightBlue[50]),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.black)),

                      onPressed: () async {

                        scanResult.device.connect();

                        String url = 'http://172.207.208.62/v1/trackers/serial-number';
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
                          var responseBody = jsonDecode(response.body) as Map<String, dynamic>;
                          var serialNumber = responseBody['serialNumber'];

                          print(serialNumber);

                          /*LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                            if (permission == LocationPermission.denied) {
                              return Future.error('permissions are denied');
                            }
                          }

                          Position position = await Geolocator.getCurrentPosition();*/

                          final data = {"serialNumber": serialNumber ,"name": "test", "location": "test"};

                          url = 'http://172.207.208.62/v1/trackers';
                          request = Uri.parse(url);
                          response = await http.post(
                            request,
                            headers: {
                              'Content-Type': 'application/json',
                              'Accept': 'application/json',
                              'Authorization': 'Bearer $jwt',
                            }, 
                            body: jsonEncode(data)
                          );

                          if(response.statusCode == 201)
                          {
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
                        }
                      },
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}