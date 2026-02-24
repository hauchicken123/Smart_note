import 'dart:convert';

class Note {
  String id;
  String title;
  String content;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static List<Note> listFromJson(String encoded) {
    final list = jsonDecode(encoded) as List<dynamic>;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<Note> notes) {
    final list = notes.map((e) => e.toJson()).toList();
    return jsonEncode(list);
  }
}
