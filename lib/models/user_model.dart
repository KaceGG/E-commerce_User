class User {
  final String fullName;
  final DateTime? birthday;
  final String email;
  final String phone;
  final String address;

  User({
    required this.fullName,
    this.birthday,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'] ?? '',
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
