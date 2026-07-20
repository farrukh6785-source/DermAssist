import 'package:cloud_firestore/cloud_firestore.dart';
class Consultation{
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime timestamp;
  final SymptomData symptoms;
  final ConsultationResult result;

  Consultation({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.timestamp,
    required this.symptoms,
    required this.result,
  });

  factory Consultation.fromJson(String id, Map<String, dynamic> json){
    return Consultation(
      id: id,
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      timestamp: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      symptoms: SymptomData.fromJson(json['symptoms'] ?? {}),
      result: ConsultationResult.fromJson(json['result']??{}),
    );
}
Map<String, dynamic> toJson(){
  return{
    'userId': userId,
    'imageUrl':imageUrl,
    'createdAt': Timestamp.fromDate(timestamp),
    'symptoms': symptoms.toJson(),
    'result': result.toJson(),
    };
  }
}
class SymptomData{
  final String description;
  final String duration;
  final String bodyLocation;
  final List<String> characteristics;
  Map<String, dynamic> toMap() {
  return {
    'description': description,
    'duration': duration,
    'bodyLocation': bodyLocation,
    'characteristics': characteristics,
  };
}

  
  SymptomData({
    required this.description,
    required this.duration,
    required this.bodyLocation,
    required this.characteristics,
  });

  factory SymptomData.fromJson(Map<String, dynamic> json){
    return SymptomData(
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      bodyLocation: json['bodyLocation'] ?? '',
      characteristics: List<String>.from(json['characteristics']?? []),
    );
  }
  Map<String, dynamic> toJson(){
    return{
      'description': description,
      'duration': duration,
      'bodyLocation': bodyLocation,
      'characteristics': characteristics,
    };
  }
}

class ConsultationResult{
  final String riskLevel;
  final List<Diagnosis> differentialDiagnoses;
  final String aiReasoning;

  ConsultationResult({
    required this.riskLevel,
    required this.differentialDiagnoses,
    required this.aiReasoning,
  });

  factory ConsultationResult.fromJson(Map<String, dynamic>json){
    return ConsultationResult(
      riskLevel: json['riskLevel'] ?? 'Low', 
      differentialDiagnoses: (json['differentialDiagnoses'] as List? ?? [])
      .map((d) => Diagnosis.fromJson(d))
      .toList(),
       aiReasoning: json['aiReasoning'] ?? '',
       );
  }
  Map<String, dynamic> toJson(){
    return{
      'riskLevel': riskLevel,
      'differentialDiagnoses':differentialDiagnoses.map((d)=>d.toJson()).toList(),
      'aiReasoning': aiReasoning,
    };
  }
}

class Diagnosis{
  final String conditionName;
  final double confidencePercentage;
  final String clinicalReasoning;

  Diagnosis({
    required this.conditionName,
    required this.confidencePercentage,
    required this.clinicalReasoning,
  });
  factory Diagnosis.fromJson(Map<String, dynamic> json){
    return Diagnosis(
      conditionName: json['conditionName'] ?? 'Unknown', 
      confidencePercentage: (json['confidencePercentage']?? 0.0).toDouble(), 
      clinicalReasoning: json['clinicalReasoning'] ?? '',
      );
  }
  Map<String, dynamic> toJson(){
    return{
      'conditionName': conditionName,
      'confidencePercentage': confidencePercentage,
      'clinicalReasoning' : clinicalReasoning,
    };
  }
}