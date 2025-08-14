class ServiceUser {
  final int id;
  final String name;
  final String email;

  ServiceUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ServiceUser.fromJson(Map<String, dynamic> json) {
    return ServiceUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
