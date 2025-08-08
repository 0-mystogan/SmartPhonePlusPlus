class ServicePart {
  final int id;
  final int quantity;
  final double unitPrice;
  final double? discountAmount;
  final double totalPrice;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int serviceId;
  final int partId;
  final String? serviceName;
  final String? partName;

  ServicePart({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.serviceId,
    required this.partId,
    this.discountAmount,
    this.notes,
    this.updatedAt,
    this.serviceName,
    this.partName,
  });

  factory ServicePart.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v == null) return 0.0;
      if (v is int) return v.toDouble();
      if (v is double) return v;
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return ServicePart(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: parseNum(json['unitPrice']),
      discountAmount: json['discountAmount'] != null ? parseNum(json['discountAmount']) : null,
      totalPrice: parseNum(json['totalPrice']),
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      serviceId: json['serviceId'] ?? 0,
      partId: json['partId'] ?? 0,
      serviceName: json['serviceName'],
      partName: json['partName'],
    );
  }
}


