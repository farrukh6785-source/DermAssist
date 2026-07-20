import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  String? _address;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
  }

  // PERMISSION CHECK 
  Future<bool> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  //  INIT FLOW 
  Future<void> _initLocationFlow() async {
    try {
      bool allowed = await _checkPermission();
      if (!allowed) {
        setState(() => _loading = false);
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _loading = false);
        return;
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      setState(() {
        _selectedLocation = LatLng(pos.latitude, pos.longitude);
        _loading = false;
      });

      _getAddress(_selectedLocation!);
    } catch (e) {
      debugPrint("LOCATION ERROR: $e");
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ADDRESS 
  Future<void> _getAddress(LatLng pos) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        if (!mounted) return;

        setState(() {
          _address =
              "${place.street}, ${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      debugPrint("ADDRESS ERROR: $e");
    }
  }

  //  SAVE
  Future<void> _saveLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _selectedLocation == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'location': {
          'lat': _selectedLocation!.latitude,
          'lng': _selectedLocation!.longitude,
          'address': _address ?? '',
        }
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint("SAVE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        actions: [
          TextButton(
            onPressed: _selectedLocation == null
                ? null
                : () async {
                    await _saveLocation();

                    if (!mounted) return;

                    Navigator.pop(context, {
                      'lat': _selectedLocation!.latitude,
                      'lng': _selectedLocation!.longitude,
                      'address': _address ?? '',
                    });
                  },
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())

          : (_selectedLocation == null)
              ? const Center(
                  child: Text("Unable to fetch location"),
                )

              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation!,
                        zoom: 16,
                      ),

                      onMapCreated: (controller) {
                        _mapController = controller;
                      },

                      markers: {
                        Marker(
                          markerId: const MarkerId("selected"),
                          position: _selectedLocation!,
                          draggable: true,

                          onDragEnd: (newPos) {
                            if (!mounted) return;

                            setState(() {
                              _selectedLocation = newPos;
                            });

                            _getAddress(newPos);
                          },
                        )
                      },

                      onTap: (pos) {
                        if (!mounted) return;

                        setState(() {
                          _selectedLocation = pos;
                        });

                        _getAddress(pos);
                      },
                    ),

                    // ADDRESS BOX
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black26,
                            )
                          ],
                        ),
                        child: Text(
                          _address ?? "Fetching address...",
                        ),
                      ),
                    ),

                    // CURRENT LOCATION BUTTON
                    Positioned(
                      right: 15,
                      bottom: 100,
                      child: FloatingActionButton(
                        child: const Icon(Icons.my_location),
                        onPressed: () async {
                          try {
                            Position pos =
                                await Geolocator.getCurrentPosition();

                            LatLng newPos =
                                LatLng(pos.latitude, pos.longitude);

                            if (!mounted) return;

                            setState(() {
                              _selectedLocation = newPos;
                            });

                            if (_mapController != null) {
                              _mapController!.animateCamera(
                                CameraUpdate.newLatLng(newPos),
                              );
                            }

                            _getAddress(newPos);
                          } catch (e) {
                            debugPrint("GPS ERROR: $e");
                          }
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
