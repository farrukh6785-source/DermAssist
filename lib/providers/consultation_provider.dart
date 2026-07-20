import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dermassist_fyp/models/consultation_model.dart';
import 'package:dermassist_fyp/constants.dart';
import 'package:dermassist_fyp/api_service.dart';
import 'package:http/http.dart' as http;


/// Manages the state for creating and viewing consultations
class ConsultationProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Consultation> _consultations = [];

  String? _consultationId;
  String? get consultationId => _consultationId;
  final ApiService _apiService = ApiService();

  Future<Map<String, String>> processImageAndCreateConsultation(String userId) async {
  try {
    _setLoading(true);

    if (_currentImage == null) {
      throw Exception("No image selected");
    }
    try {
      final result = await InternetAddress.lookup('api.cloudinary.com');
      
    } catch (e) {
      throw Exception("No internet connection or DNS issue");
    }
  
    
    final imageUrl = await uploadImageToCloudinary(_currentImage!);
        
    final docRef = FirebaseFirestore.instance.collection('consultations').doc();

    await docRef.set({
      'consultationId': docRef.id,
      'userId': userId,
      'imageUrl': imageUrl,
      'symptoms': _currentSymptoms?.toJson(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _consultationId = docRef.id;
    notifyListeners();

    return {
      'consultationId': docRef.id,
      'imageUrl': imageUrl,
    };
    } catch (e) {
    
    _error = e.toString();
    rethrow;
  } finally {
    _setLoading(false);
  }
}

  
  // Current active consultation flow
  File? _currentImage;
  SymptomData? _currentSymptoms;
  ConsultationResult? _currentResult;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Consultation> get consultations => _consultations;
  File? get currentImage => _currentImage;
  SymptomData? get currentSymptoms => _currentSymptoms;
  ConsultationResult? get currentResult => _currentResult;

  // Set current image from camera/gallery
  void setImage(File image) {
    _currentImage = image;
    notifyListeners();
  }

  // Set symptom data
  void setSymptoms(SymptomData data) {
    _currentSymptoms = data;
    notifyListeners();
  }

  // Process image quality validation
  Future<bool> validateImageQuality() async {
    _setLoading(true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    _setLoading(false);
    return true; 
  }
  // Progress indicator for upload
    double _uploadProgress = 0.0;
    bool _isUploading = false;
    double get uploadProgress => _uploadProgress;
    bool get isUploading => _isUploading;

  // Store image to Firebase Storage
  /*Future<String> uploadImageToFireStorage(File imageFile) async{
    
    try{
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();
      final fileName = 'consultations/${DateTime.now().microsecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = ref.putFile(imageFile,SettableMetadata(contentType: 'image/jpeg'),
      );
      UploadTask.snapshotEvents.listen((TaskSnapshot snapshopt){
        _uploadProgress = snapshopt.bytesTransferred/snapshopt.totalBytes;
        notifyListeners();
      });
      //final snapshopt =
       await uploadTask;
      //if(snapshopt.state == TaskState.success)
      //{
        final downloadUrl = await ref.getDownloadURL();
        _isUploading = false;
        _uploadProgress = 1.0;
        notifyListeners();
        return downloadUrl;
      //} else{
       // throw Exception("Upload failed");
      //}
       
      
    } catch(e){
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      throw Exception("Firebase storage upload failed: $e");
    }
     
    
  }*/

  // Store image to cloudinary
  Future<String> uploadImageToCloudinary(File imageFile) async {
  try {
    // 1. Reset state
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    final cloudName = "daxt6ffml";
    final uploadPreset = "consultation_preset";
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    // 2. Use MultipartRequest directly from path (saves memory)
    var request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', 
        imageFile.path,
      ),
    );

    // 3. Send and handle response
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _isUploading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return data['secure_url'];
    } else {
      throw Exception("Cloudinary upload failed: ${response.body}");
    }
  } catch (e) {
    _isUploading = false;
    _uploadProgress = 0.0;
    notifyListeners();
    // Log the error to see if it's still a SocketException
    print("Upload Error: $e");
    throw Exception("Cloudinary upload error: $e");
  }
}

  // Perform AI analysis via backend nodejs/MedGemma

  
  Future<ConsultationResult> analyzeLesion() async {
  _setLoading(true);

  try {
    if (_currentImage == null) {
      throw Exception("No image selected");
    }

    final bytes = await _currentImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await _apiService.analyze(
      base64Image,
      _currentSymptoms,
    );
    if(response == null || response is! Map<String, dynamic>){
      throw Exception("Invalid API response format");
    }

    _currentResult = ConsultationResult.fromJson(response);

    // UPDATE FIRESTORE WITH RESULT
    if (_consultationId != null) {
      await FirebaseFirestore.instance
          .collection('consultations')
          .doc(_consultationId)
          .set({
        'result': _currentResult!.toJson(),
        'status': 'completed',
      }, SetOptions(merge: true));
    }

    return _currentResult!;
  } catch (e) {
    _error = e.toString();
    throw Exception('Analysis failed: $_error');
  } finally {
    _setLoading(false);
  }
}


  // Load history from Firestore
  Future<void> loadHistory() async {
  _setLoading(true);
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('consultations')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    _consultations = snapshot.docs.map((doc) {
      return Consultation.fromJson(doc.id, doc.data());
    }).toList();

    
    notifyListeners();

  } catch (e) {
    debugPrint("LOAD HISTORY ERROR: $e");
  } finally {
    _setLoading(false);
  }
}


  // Reset the flow after completion
  void resetCurrentConsultation() {
    _currentImage = null;
    _currentSymptoms = null;
    _currentResult = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
