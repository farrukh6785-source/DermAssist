import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "YOUR_BACKEND_URL";

  Future<Map<String, dynamic>> analyze(
    String base64Image,
    dynamic symptoms,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/analyze"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "image": base64Image,
        "symptoms": symptoms,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("AI analysis failed");
    }
  }
}
