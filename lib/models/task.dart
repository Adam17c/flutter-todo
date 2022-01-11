import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  String title;
  String description;
  final String userId;
  bool? isDone;
  Timestamp? timestamp;

  Task({
    required this.id,
    required this.userId,
    this.title = "",
    this.description = "",
    this.isDone = false,
    this.timestamp,
  });

  factory Task.fromMap(map) {
    return Task(
      id: map['id'],
      title: map['title'],
      timestamp: map['timestamp'],
      description: map['description'],
      userId: map['userId'],
      isDone: map['isDone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp,
      'description': description,
      'userId': userId,
      'isDone': isDone
    };
  }
}