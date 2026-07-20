import 'dart:convert';
import 'package:http/http.dart' as http;

class OSMService {

  Future<List<dynamic>> fetchNearbyProviders(double lat, double lng) async {

  final query = """
  [out:json];
  (
    node["amenity"="hospital"](around:5000,$lat,$lng);
    node["amenity"="pharmacy"](around:5000,$lat,$lng);
    node["amenity"="clinic"](around:5000,$lat,$lng);
    node["healthcare"="doctor"](around:5000,$lat,$lng);
  node["amenity"="doctors"](around:5000,$lat,$lng);
  );
  out;
  """;

  final response = await http.post(
  Uri.parse("https://overpass-api.de/api/interpreter"),
  headers: {
    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
    "Accept": "application/json",
    "User-Agent": "FlutterApp/1.0",
  },
  body: "data=${Uri.encodeComponent(query)}",
);

  if (response.statusCode != 200) {
    throw Exception("Failed to load providers: ${response.statusCode}");
  }

  final data = jsonDecode(response.body);

  return data['elements'] ?? [];
}
}