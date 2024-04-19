import 'dart:convert';

class DocumentModel {
  final String title;
  final List content;
  final String uid;
  final DateTime createdAt;
  final String id;

  DocumentModel(
      {required this.title,
      required this.content,
      required this.uid,
      required this.createdAt,
      required this.id});

  factory DocumentModel.fromMap(Map<String, dynamic> map) => DocumentModel(
    title: map["title"] ?? '',
    content: List.from(map["content"]) ,
    uid: map["uid"] ?? '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(map["createdAt"]),
    id: map["_id"] ?? '',
  );

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "content": content,
      "uid": uid,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "id" : id,
    };
  }

  String toJson() => json.encode(toMap());
  factory DocumentModel.fromJson(String source) => DocumentModel.fromMap(jsonDecode(source));

}
