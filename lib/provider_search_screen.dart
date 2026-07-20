import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dermassist_fyp/services/osm_services.dart';

class HealthcareProviderSearchScreen extends StatefulWidget {
  const HealthcareProviderSearchScreen({super.key});

  @override
  State<HealthcareProviderSearchScreen> createState() =>
      _HealthcareProviderSearchScreenState();
}

class _HealthcareProviderSearchScreenState
    extends State<HealthcareProviderSearchScreen> {

  

  //List<dynamic> _places = [];
   final OSMService _osmService = OSMService();
    List<dynamic> _providers  = [];
    bool _loading = true;
    String _selectedFilter = 'All';
    String? _errorMessage;
    LatLng? _userLocation;
  GoogleMapController? _mapController;

  //final String _apiKey = "AIzaSyACGfaT_64qBtuCVy_gPoYQdnw45B8yQQQ";

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
   
  }

  Future<void> _loadUserLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (data != null && data['location'] != null) {
        final loc = data['location'];

        if(loc['lat'] != null && loc['lng'] != null){
          setState(() {
            _userLocation = LatLng(
              (loc['lat'] as num).toDouble(),
              (loc['lng'] as num).toDouble(),
            );
          });

         // await _loadNearbyPlaces();
         await _loadNearbyProviders();
        }
      }

      setState(() => _loading = false);

    } catch (e) {
      debugPrint("Location error: $e");
      setState(() => _loading = false);
    }
  }
  Future<void> _loadNearbyProviders() async {
  if (_userLocation == null) return;

  setState(() => _loading = true);

  try {
    final results = await _osmService.fetchNearbyProviders(
      _userLocation!.latitude,
      _userLocation!.longitude,
      
    );
    //debugPrint("RAW OSM DATA: ${results.toString()}");
    

    setState(() {
      _providers = results;
      _loading = false;
    });

  } catch (e) {
    setState(() {
      _loading = false;
      _errorMessage = "Failed to load providers: $e";
    } );
  }
}

  /*Future<void> _loadNearbyPlaces() async {
  if (_userLocation == null) return;

  setState(() => _loading = true);

  String type = "hospital";

  if (_selectedFilter == "Pharmacy") type = "pharmacy";
  if (_selectedFilter == "Clinic") type = "hospital";
  if (_selectedFilter == "Dermatologist") type = "hospital"; // FIX

  final url =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
      "?location=${_userLocation!.latitude},${_userLocation!.longitude}"
      "&radius=5000"
     "&type=$type"
      "&key=$_apiKey";

  try {
    final response = await http.get(Uri.parse(url));

    final data = jsonDecode(response.body);

    /*if (data['status'] != "OK") {
            setState(() => _loading = false);
      return;*/
      debugPrint("Places API Status: ${data['status']}");
      debugPrint("Places API Response: ${response.body}");
      if(data['status'] == "REQUEST_DENIED"){
        debugPrint("API key issue");
      }
      if (data['status'] == "ZERO_RESULTS") {
       setState(() {
        _places = [];
        _loading = false;
      });
      return;
}
if(data['status'] != "OK"){
  setState(() {
    _errorMessage = "Places API error: ${data['status']}\n${data['error_message'] ?? ''} ";

  });
   return;
    }
  if ((data['results'] as List).isEmpty) {
  setState(() {
    _places = [];
    _loading = false;
    _errorMessage = "No nearby providers found.";
  });
  return;
}

  } catch (e) {
    
    setState(() {
      _loading = false;
      _errorMessage = e.toString();
    } );
  }
}*/

Widget _getProviderIcon(dynamic p) {
  final type = _getProviderType(p);

  IconData icon;
  Color color;

  switch (type) {
    case "Hospital":
      icon = Icons.local_hospital;
      color = Colors.red;
      break;

    case "Pharmacy":
      icon = Icons.local_pharmacy;
      color = Colors.green;
      break;

    case "Clinic":
      icon = Icons.medical_services;
      color = Colors.orange;
      break;

    case "Dermatologist":
      icon = Icons.person;
      color = Colors.blue;
      break;

    default:
      icon = Icons.local_hospital;
      color = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: color),
  );
}
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    const c = cos;

    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) *
            c(lat2 * p) *
            (1 - c((lon2 - lon1) * p)) /
            2;

    return 12742 * asin(sqrt(a));
  }

  List<dynamic> get _filteredProviders {
    //List<dynamic> list = _places;
    List<dynamic> list = List.from(_providers);
    if (_selectedFilter == "All") {
  return list;
}

if (_selectedFilter == "Pharmacy") {
  return list.where((p) =>
    _getProviderType(p) == "Pharmacy"
  ).toList();
}

if (_selectedFilter == "Clinic") {
  return list.where((p) =>
    _getProviderType(p) == "Clinic"
  ).toList();
}

if (_selectedFilter == "Dermatologist") {
  return list.where((p) =>
    _getProviderType(p) == "Dermatologist"
  ).toList();
}


    list.sort((a, b) {
      return _getDistance(a).compareTo(_getDistance(b));
    });

    return list;
  }

  double _getDistance(dynamic place) {
    if (_userLocation == null) return 0;

    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];

    return _calculateDistance(
      _userLocation!.latitude,
      _userLocation!.longitude,
      lat,
      lng,
    );
  }
  String _getProviderType(dynamic p) {

  final tags = p['tags'] ?? {};

  final name =
      (tags['name'] ?? "").toString().toLowerCase();

  final amenity =
      (tags['amenity'] ?? "").toString().toLowerCase();

  final shop =
      (tags['shop'] ?? "").toString().toLowerCase();

  final healthcare =
      (tags['healthcare'] ?? "").toString().toLowerCase();

  final speciality =
      (tags['healthcare:speciality'] ?? "")
          .toString()
          .toLowerCase();

  // =====================================================
  // PRIORITY 1 → DERMATOLOGIST
  // =====================================================

  if (
      healthcare == "doctor" ||
      amenity == "doctors" ||

      speciality.contains("derma") ||
      speciality.contains("skin") ||

      name.contains("derma") ||
      name.contains("skin") ||
      name.contains("dermatology")
  ) {
    return "Dermatologist";
  }

  // =====================================================
  // PRIORITY 2 → PHARMACY
  // =====================================================

  if (
      shop == "pharmacy" ||
      amenity == "pharmacy" ||
      name.contains("pharmacy") ||
      name.contains("medical store")
  ) {
    return "Pharmacy";
  }

  // =====================================================
  // PRIORITY 3 → CLINIC
  // =====================================================

  if (
      amenity == "clinic" ||
      healthcare == "clinic" ||
      name.contains("clinic")
  ) {
    return "Clinic";
  }

  // =====================================================
  // PRIORITY 4 → HOSPITAL
  // =====================================================

  if (
      amenity == "hospital" ||
      healthcare == "hospital" ||
      name.contains("hospital") ||
      name.contains("medicare")
  ) {
    return "Hospital";
  }

  return "Healthcare Provider";
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Providers"),
      ),
      body: Column(
        children: [

          Container(
            height: 200,
            width: double.infinity,
            child: _userLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _userLocation!,
                      zoom: 14,
                    ),
                    markers: _buildMarkers(),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(
              AppConstants.paddingMedium
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ["All", "Dermatologist", "Clinic", "Pharmacy"]
                  .map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (_) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    //_loadNearbyPlaces();
                    //_loadNearbyProviders();
                  },
                );
                }).toList(),
              
            
              
              
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : 
                /*ListView.builder(
                    itemCount: _filteredProviders.length,
                    itemBuilder: (context, index) {
                      final place = _filteredProviders[index];
                      return ListTile(
                        title: Text(place['name'] ?? ''),
                        subtitle: Text(place['vicinity'] ?? ''),
                      );
                    },
                  ),*/
                  ListView.builder(
  itemCount: _filteredProviders.length,
  itemBuilder: (context, index) {

    final p = _filteredProviders[index];

    return GestureDetector(

      onTap: () async {

        final lat = (p['lat'] as num).toDouble();
        final lon = (p['lon'] as num).toDouble();

        // Move camera to selected provider
        await _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(lat, lon),
              zoom: 17,
            ),
          ),
        );

        // Optional snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              p['tags']?['name'] ?? "Provider Selected",
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: Colors.grey.shade300,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [

            // Provider Icon
            _getProviderIcon(p),

            const SizedBox(width: 12),

            // Name + Type
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    p['tags']?['name'] ??
                        "Unknown Provider",

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _getProviderType(p),

                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ],
        ),
      ),
    );
  },
)
          ),
        ],
      ),
    );
  }

  /*Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("user"),
          position: _userLocation!,
        ),
      );
    }

    for (var place in _places) {
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];

      markers.add(
        Marker(
          markerId: MarkerId(place['place_id']),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: place['name']),
        ),
      );
    }

    return markers;
  }*/
  Set<Marker> _buildMarkers() {
  final markers = <Marker>{};

  if (_userLocation != null) {
    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: _userLocation!,
      ),
    );
  }

  for (var p in _filteredProviders) {
    markers.add(
      Marker(
        markerId: MarkerId(p['id'].toString()),
        position: LatLng(p['lat'], p['lon']),
        infoWindow: InfoWindow(
          title: p['tags']?['name'] ?? "Unknown",
        ),
      ),
    );
  }

  return markers;
}
}
