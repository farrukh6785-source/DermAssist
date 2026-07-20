import 'package:flutter/material.dart';

class User{
  final String id;
  final String fullName;
  final String email;
  final DateTime dateOfBirth;
  final String? profilePhotoUrl;
  final String phoneNumber;
  final String location;
  final double? latitude;
  final double? longitude;
  final int age;
  
  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    this.profilePhotoUrl,
    this.location = '',
    this.phoneNumber = '',
    required this.age,
    this.latitude,
    this.longitude
  });

  // copyWith method
  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profilePhotoUrl,
    String? phoneNumber,
    String? location,
    double? latitude,
    double? longitude,

  }){
    return User(
      id: id?? this.id, 
      fullName: fullName ?? this.fullName, 
      email: email ?? this.email, 
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      );
  }

  factory User.fromJson(Map<String, dynamic>json, String documentId){
    return User(
      id: documentId,
      fullName: json['fullName']?? '',
      email: json['email'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      profilePhotoUrl: json['profilePhotoUrl'],
      location: json['location'] ?? '',
      phoneNumber: json['phoneNumber']?? '',
      age: json['age']?? 0,
      );
    }

    Map<String, dynamic> toJson(){
      return{
        'fullName': fullName,
        'email': email,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'profilePhotoUrl': profilePhotoUrl,
        'location': location,
        'phoneNumber': phoneNumber,
        'age': age,
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }
  }
