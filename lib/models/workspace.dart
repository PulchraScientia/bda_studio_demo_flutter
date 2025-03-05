class Workspace {
  final String id;
  final String name;
  final String description;
  final List<String> members;
  final DateTime createdAt;

  Workspace({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.createdAt,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      members: List<String>.from(json['members']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
