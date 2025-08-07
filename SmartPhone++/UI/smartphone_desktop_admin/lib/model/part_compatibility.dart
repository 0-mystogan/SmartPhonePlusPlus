class PartCompatibility {
  final int id;
  final String? notes;
  final String? compatibilityNotes;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int partId;
  final int phoneModelId;
  final String? partName;
  final String? phoneModelName;

  PartCompatibility({
    required this.id,
    this.notes,
    this.compatibilityNotes,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt,
    required this.partId,
    required this.phoneModelId,
    this.partName,
    this.phoneModelName,
  });

  factory PartCompatibility.fromJson(Map<String, dynamic> json) {
    return PartCompatibility(
      id: json['id'] ?? 0,
      notes: json['notes'],
      compatibilityNotes: json['compatibilityNotes'] ?? json['notes'],
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      partId: json['partId'] ?? 0,
      phoneModelId: json['phoneModelId'] ?? 0,
      partName: json['partName'],
      phoneModelName: json['phoneModelName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notes': notes,
      'compatibilityNotes': compatibilityNotes,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'partId': partId,
      'phoneModelId': phoneModelId,
      'partName': partName,
      'phoneModelName': phoneModelName,
    };
  }
}