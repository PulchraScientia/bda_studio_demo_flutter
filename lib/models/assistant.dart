class Assistant {
  final String id;
  final String name;
  final String experimentId;
  final String evaluationId;
  final int version;
  final DateTime createdAt;

  Assistant({
    required this.id,
    required this.name,
    required this.experimentId,
    required this.evaluationId,
    required this.version,
    required this.createdAt,
  });

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'],
      name: json['name'],
      experimentId: json['experimentId'],
      evaluationId: json['evaluationId'],
      version: json['version'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'experimentId': experimentId,
      'evaluationId': evaluationId,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
