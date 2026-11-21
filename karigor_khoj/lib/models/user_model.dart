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
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      token: token ?? json['token'],
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
