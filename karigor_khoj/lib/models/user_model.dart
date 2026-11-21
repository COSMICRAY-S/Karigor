class UserModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String role; // 'seeker' or 'karigor'
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? 'seeker',
      token: token ?? json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
      };
}
