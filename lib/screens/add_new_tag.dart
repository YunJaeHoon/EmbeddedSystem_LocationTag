import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:location/location.dart';
import 'package:location_tag/components/custom_app_bar.dart';
import 'package:location_tag/components/move_button.dart';
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
    scanResults.clear();
  }

  void requestPermission() async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }

      if (await FlutterBluePlus.isSupported == false) {
        print("Bluetooth not supported by this device");
        return;
      }

      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        print(state);
        if (state == BluetoothAdapterState.on) {
          startScan();
        } else {
          print("Bluetooth adapter is not on!");
        }
      });
    } catch (e) {
      print("Error in requestPermission: $e");
    }
  }

  void startScan() async {
    try {
      print('Starting scan');

      if (mounted) {
        setState(() {
          isScanning = true;
          scanResults.clear();
        });
      }

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      FlutterBluePlus.scanResults.listen((results) {
        
        if (mounted) {
          setState(() {
            scanResults = results;

            if (scanResults.length >= 2) {
              scanResults[0] = ScanResult(
                device: BluetoothDevice(remoteId: const DeviceIdentifier('test')),
                advertisementData: AdvertisementData(
                  advName: 'new location tag',
                  txPowerLevel: 1,
                  appearance: 1,
                  connectable: true,
                  manufacturerData: <int, List<int>>{},
                  serviceData: <Guid, List<int>>{},
                  serviceUuids: List.empty()
                ),
                rssi: 1,
                timeStamp: DateTime.now()
              );
              scanResults[1] = ScanResult(
                device: BluetoothDevice(remoteId: const DeviceIdentifier('08:A9:30:7B:7F:E7')),
                advertisementData: AdvertisementData(
                  advName: 'HC-06',
                  txPowerLevel: 1,
                  appearance: 1,
                  connectable: true,
                  manufacturerData: <int, List<int>>{},
                  serviceData: <Guid, List<int>>{},
                  serviceUuids: List.empty()
                ),
                rssi: 1,
                timeStamp: DateTime.now()
              );
            }
          });
        }

        if (results.isNotEmpty) {
          print('${results.last.device.remoteId}: "${results.last.advertisementData.advName}" found!');
        } else {
          print('No devices found...');
        }
      });
    } catch (e) {
      print("Error in startScan: $e");
    }
  }

  Future<void> stopScan() async {
    try {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }

      print('Stopping scan');
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print("Error in stopScan: $e");
    }
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
        const MoveButton(screen: 'home', description: '돌아가기', isLogin: true),
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
              color: Colors.blue[300],
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (BuildContext context, int index) {
              var scanResult = scanResults[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
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
                          scanResult.advertisementData.advName.toString(),
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
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Colors.lightBlue[50]),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.black)),

                      onPressed: () async {

                        // scanResult.device.connect();

                        String url = 'http://20.40.102.76/v1/trackers/serial-number';
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

                          Location location = Location();
                          PermissionStatus permissionGranted;
                          bool locationEnabled;
                          LocationData locationData;

                          locationEnabled = await location.serviceEnabled();
                          if(!locationEnabled)
                          {
                            locationEnabled = await location.requestService();
                            if(!locationEnabled)
                            {
                              return;
                            }
                          }

                          permissionGranted = await location.hasPermission();
                          if(permissionGranted == PermissionStatus.denied)
                          {
                            permissionGranted = await location.requestPermission();
                            if(permissionGranted != PermissionStatus.granted)
                            {
                              return;
                            }
                          }

                          locationData = await location.getLocation();

                          final data = {"serialNumber": serialNumber ,"name": "test", "location": locationData.toString()};

                          url = 'http://20.40.102.76/v1/trackers';
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
