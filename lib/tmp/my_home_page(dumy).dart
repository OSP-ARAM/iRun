// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:irun/navi/navi.dart';
// import 'package:location/location.dart';
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   GoogleMapController? _controller;
//   LocationData? _currentLocation;
//   bool showProperty1Home = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation().then((locationData) {
//       setState(() {
//         _currentLocation = locationData;
//       });
//       _moveToCurrentLocation();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('IRUN'), // 앱 바에 제목 추가
//       ),
//         body: Center(
//             child: GestureDetector(
//               onTap: () { // Start 버튼을 눌렀을 때 할 작업 추가
//                 print('Start 버튼을 눌렀습니다!');
//               },
//             child: Container(
//               width: 150.0,
//               height: 150.0,
//               decoration: BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//               ),
//             child: Center(
//               child: RaisedButton(
//                 onPressed: () { // Start 버튼을 눌렀을 때 할 작업 추가
//                   print('Start 버튼을 눌렀습니다!');
//                 },
//                 child: Text(
//                   'Start',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20.0,
//                   ),
//                 ),
//               ),
//             ),
//             ),
//             ),
//         ),
//       bottomNavigationBar: MenuBottom(currentIndex: 1),
//     );
//   }
//
//   Widget buildMapScreen() {
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 width: 1,
//                 color: Theme.of(context)
//                     .colorScheme
//                     .primary
//                     .withOpacity(0.2),
//               ),
//             ),
//             alignment: Alignment.center,
//             child: _currentLocation == null
//                 ? Text(
//               'No location chosen',
//               textAlign: TextAlign.center,
//               style: Theme.of(context)
//                   .textTheme
//                   .bodyText2!
//                   .copyWith(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .onBackground),
//             )
//                 : GoogleMap(
//               onMapCreated: (controller) {
//                 setState(() {
//                   _controller = controller;
//                 });
//               },
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(
//                   _currentLocation!.latitude!,
//                   _currentLocation!.longitude!,
//                 ),
//                 zoom: 15,
//               ),
//               markers: {
//                 Marker(
//                   markerId: MarkerId('currentLocation'),
//                   position: LatLng(
//                     _currentLocation!.latitude!,
//                     _currentLocation!.longitude!,
//                   ),
//                   infoWindow: InfoWindow(title: 'Current Location'),
//                 ),
//               },
//             ),
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               SizedBox(width: 16.0),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.pushNamedAndRemoveUntil(context, '/r', (route) => false);
//                   },
//                   icon: const Icon(Icons.map),
//                   label: const Text('Start Recording'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Future<LocationData> _getCurrentLocation() async {
//     var location = Location();
//     return await location.getLocation();
//   }
//
//   void _moveToCurrentLocation() {
//     if (_controller != null && _currentLocation != null) {
//       _controller!.animateCamera(
//         CameraUpdate.newLatLng(
//           LatLng(
//             _currentLocation!.latitude!,
//             _currentLocation!.longitude!,
//           ),
//         ),
//       );
//     }
//   }
// }