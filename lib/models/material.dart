class MaterialItem {
  final String id;
  final String type; // 'train', 'test', 'knowledge'
  final String naturalLanguage;
  final String sql;

  MaterialItem({
    required this.id,
    required this.type,
    required this.naturalLanguage,
    required this.sql,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      type: json['type'],
      naturalLanguage: json['naturalLanguage'],
      sql: json['sql'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'naturalLanguage': naturalLanguage,
      'sql': sql,
    };
  }
}

class Material {
  final String id;
  final String experimentId;
  final List<MaterialItem> trainSet;
  final List<MaterialItem> testSet;
  final List<MaterialItem> knowledgeSet;
  final DateTime createdAt;

  Material({
    required this.id,
    required this.experimentId,
    required this.trainSet,
    required this.testSet,
    required this.knowledgeSet,
    required this.createdAt,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      experimentId: json['experimentId'],
      trainSet: (json['trainSet'] as List).map((e) => MaterialItem.fromJson(e)).toList(),
      testSet: (json['testSet'] as List).map((e) => MaterialItem.fromJson(e)).toList(),
      knowledgeSet: (json['knowledgeSet'] as List).map((e) => MaterialItem.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experimentId': experimentId,
      'trainSet': trainSet.map((e) => e.toJson()).toList(),
      'testSet': testSet.map((e) => e.toJson()).toList(),
      'knowledgeSet': knowledgeSet.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
