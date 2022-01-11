class Todo {
  final String id;
  final String taskId;
  String title;
  bool? isDone;
  int order;

  Todo(
      {required this.id,
      required this.taskId,
      required this.order,
      this.title = "",
      this.isDone = false});

  factory Todo.fromMap(map) {
    return Todo(
      id: map['id'],
      taskId: map['taskId'],
      order: map['order'],
      title: map['title'],
      isDone: map['isDone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'order': order,
      'title': title,
      'isDone': isDone
    };
  }
}
