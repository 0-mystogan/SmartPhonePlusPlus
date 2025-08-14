class PhoneModel {
  final int id;
  final String name;
  final String? brand;
  final String? model;

  PhoneModel({
    required this.id,
    required this.name,
    this.brand,
    this.model,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      model: json['model'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
    };
  }
}
