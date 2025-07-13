class EntryModel {
  final String id;
  final String diaryId;
  final String content;
  final String createdBy; // User UID
  final String createdByName; // User display name
  final DateTime createdAt;
  final List<String> tags;
  final String? mood;
  final String? voiceTranscript;

  EntryModel({
    required this.id,
    required this.diaryId,
    required this.content,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.tags,
    this.mood,
    this.voiceTranscript,
  });

  factory EntryModel.fromMap(String id, Map<String, dynamic> map) {
    return EntryModel(
      id: id,
      diaryId: map['diaryId'] ?? '',
      content: map['content'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? 'Unknown User',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      tags: List<String>.from(map['tags'] ?? []),
      mood: map['mood'],
      voiceTranscript: map['voiceTranscript'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diaryId': diaryId,
      'content': content,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'tags': tags,
      'mood': mood,
      'voiceTranscript': voiceTranscript,
    };
  }
}
