import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Mapping extends StatefulWidget {
  const Mapping({Key? key}) : super(key: key);

  @override
  State<Mapping> createState() => _MappingState();
}

class _MappingState extends State<Mapping> {
  Position? p;
  String location = 'Null, Press Button';
  String Address = 'search';
  final Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(34.0151, 71.5249));

  final List<Marker> _marker = <Marker>[
    Marker(
      markerId: MarkerId('1'),
      position: LatLng(34.0151, 71.5249),
      infoWindow: InfoWindow(title: 'title of the marker'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          onTap: (latLng) {
            RandomGetAddressFromLatLong(latLng);
            print('${latLng.latitude}, ${latLng.longitude}');
          },
          initialCameraPosition: _cameraPosition,
          markers: Set<Marker>.of(_marker),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getUserCurrentLocation().then((value) async {
            print('my current location');
            print(value.latitude.toString() + " " + value.longitude.toString());
            _marker.add(
              Marker(
                markerId: MarkerId('2'),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: InfoWindow(title: 'My current location'),
              ),
            );

            CameraPosition cameraPosition = CameraPosition(
                zoom: 14, target: LatLng(value.latitude, value.longitude));

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
          Geolocator.getCurrentPosition();

          GetAddressFromLatLong();
        },
        child: Icon(Icons.location_on_outlined),
      ),
    );
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error' + error.toString());
    });
    return Geolocator.getCurrentPosition();
  }

  Future<void> GetAddressFromLatLong() async {
    Position position = await Geolocator.getCurrentPosition();
    print(position.latitude.toString() + "qwertyuiop");
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    print(Address);
  }

  Future<void> RandomGetAddressFromLatLong(latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    print(Address);
  }
}
