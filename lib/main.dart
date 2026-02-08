import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  LatLng userLocation = LatLng(0, 0);
  double accuracy = 0;
  bool isTopoMap = false;

  MapController mapController = MapController();
  //get user location
  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Position position = await Geolocator.getCurrentPosition();
    print(
      'User location: ${position.latitude}, ${position.longitude}, ${position.accuracy}',
    );
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      accuracy = position.accuracy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Location Application')),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(17.80316, 102.74811),
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: isTopoMap
                ? "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"//เน้นภูเขาเส้นชั้นความสูง
                : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            //วงกลมพื้นที่
            CircleLayer(
              circles: [
                if (accuracy > 0)
                  CircleMarker(
                    point: userLocation,
                    radius: accuracy, 
                    useRadiusInMeter: true,
                    color: const Color.fromARGB(255, 60, 177, 235).withOpacity(0.2),
                    borderColor: const Color.fromARGB(255, 15, 50, 78),
                    borderStrokeWidth: 2,
                  ),
              ],
            ),

            MarkerLayer(
              markers: [
                userLocation.latitude == 0 && userLocation.longitude == 00
                ? Marker(point: LatLng(0, 0), child: Container())
                : Marker(
                  width: 40.0,
                  height: 40.0,
                  point: userLocation,
                  child: const Icon(
                    Icons.person_pin,
                    color: Color.fromARGB(255, 6, 42, 103),
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            //ปุ่มหาตำแหน่ง
            FloatingActionButton(
              heroTag: "loc",
              onPressed: getUserLocation,
              child: const Icon(Icons.my_location),
            ),

            const SizedBox(height: 10),

            //อันนี้ปุ่มเปลี่ยนแผนที่
            FloatingActionButton(
              heroTag: "map",
              onPressed: () {
                setState(() {
                  isTopoMap = !isTopoMap;
                });
              },
              child: const Icon(Icons.layers),
            ),
          ],
        ),

      ),
    );
  }
}
