class ProviderModel {
  final int id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final bool isVerified;
  final String phone;
  final String bio;
  final double distance;
  final double? latitude;
  final double? longitude;

  ProviderModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.isOnline,
    required this.isVerified,
    required this.phone,
    required this.bio,
    required this.distance,
    this.latitude,
    this.longitude,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      category: json['service_category'] ?? json['category'] ?? '',
      rating: double.tryParse('${json['rating']}') ?? 0.0,
      reviewCount: json['review_count'] is int
          ? json['review_count']
          : int.tryParse('${json['review_count']}') ?? 0,
      isOnline: json['is_online'] == true || json['is_online'] == 'true',
      isVerified: json['is_verified'] == true || json['is_verified'] == 'true',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      distance: double.tryParse('${json['distance']}') ?? 0.0,
      latitude: json['latitude'] != null
          ? double.tryParse('${json['latitude']}')
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse('${json['longitude']}')
          : null,
    );
  }
}