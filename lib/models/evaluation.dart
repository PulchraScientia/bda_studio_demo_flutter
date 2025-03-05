class EvaluationResult {
  final String id;
  final String testItemId;
  final String expectedSql;
  final String generatedSql;
  final bool isCorrect;

  EvaluationResult({
    required this.id,
    required this.testItemId,
    required this.expectedSql,
    required this.generatedSql,
    required this.isCorrect,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      id: json['id'],
      testItemId: json['testItemId'],
      expectedSql: json['expectedSql'],
      generatedSql: json['generatedSql'],
      isCorrect: json['isCorrect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testItemId': testItemId,
      'expectedSql': expectedSql,
      'generatedSql': generatedSql,
      'isCorrect': isCorrect,
    };
  }
}

class Evaluation {
  final String id;
  final String experimentId;
  final String materialId;
  final double accuracy;
  final List<EvaluationResult> results;
  final DateTime createdAt;

  Evaluation({
    required this.id,
    required this.experimentId,
    required this.materialId,
    required this.accuracy,
    required this.results,
    required this.createdAt,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      experimentId: json['experimentId'],
      materialId: json['materialId'],
      accuracy: json['accuracy'],
      results: (json['results'] as List).map((e) => EvaluationResult.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'experimentId': experimentId,
      'materialId': materialId,
      'accuracy': accuracy,
      'results': results.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}