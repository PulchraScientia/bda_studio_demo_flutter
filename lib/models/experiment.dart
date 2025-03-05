class Dataset {
  final String id;
  final String name;
  final List<String> tables;
  final bool isOutOfSync;

  Dataset({
    required this.id,
    required this.name,
    required this.tables,
    this.isOutOfSync = false,
  });

  factory Dataset.fromJson(Map<String, dynamic> json) {
    return Dataset(
      id: json['id'],
      name: json['name'],
      tables: List<String>.from(json['tables']),
      isOutOfSync: json['isOutOfSync'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tables': tables,
      'isOutOfSync': isOutOfSync,
    };
  }
}

class Experiment {
  final String id;
  final String workspaceId;
  final String name;
  final String description;
  final Dataset dataset;
  final DateTime createdAt;

  Experiment({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.description,
    required this.dataset,
    required this.createdAt,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      id: json['id'],
      workspaceId: json['workspaceId'],
      name: json['name'],
      description: json['description'],
      dataset: Dataset.fromJson(json['dataset']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'description': description,
      'dataset': dataset.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}