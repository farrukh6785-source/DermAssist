class HealthcareProvider{
  final String id;
  final String name;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final double rating;
  final double distance;

  HealthcareProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.rating,
    required this.distance,
  });

  factory HealthcareProvider.fromJson(Map<String, dynamic> json){
    return HealthcareProvider(
      id: json['id']?.toString()?? '',
      name: json['name']?? 'Unknown Clinic',
      type: json['type']?? 'Clinic',
      address: json['address']?? 'No Address Provided',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phoneNumber: json['phoneNumber'] ?? 'N/A',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
    );
  }
}