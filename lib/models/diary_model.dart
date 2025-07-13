class DiaryModel {
  final String id;
  final String title;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;
  final String? description;

  DiaryModel({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    this.description,
  });

  factory DiaryModel.fromMap(String id, Map<String, dynamic> map) {
    return DiaryModel(
      id: id,
      title: map['title'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdBy': createdBy,
      'members': members,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'description': description,
    };
  }
}
