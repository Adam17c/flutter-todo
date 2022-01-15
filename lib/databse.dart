import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app_ver1/models/task.dart';
import 'package:todo_app_ver1/models/todo.dart';

class Database {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static postTaskToFirestore(Task task) async {
    await _firebaseFirestore.collection("tasks").doc(task.id).set(task.toMap());
  }

  static postTodoToFirestore(Todo todo) async {
    await _firebaseFirestore.collection("todos").doc(todo.id).set(todo.toMap());
  }

  static updateTask(Task task) async {
    await _firebaseFirestore.collection("tasks").doc(task.id).update({
      "title": task.title,
      "description": task.description,
      "isDone": task.isDone,
      "timestamp": task.timestamp,
    });
  }

  static updateTodo(Todo todo) async {
    await _firebaseFirestore
        .collection("todos")
        .doc(todo.id)
        .update({"title": todo.title, "isDone": todo.isDone});
  }

  static deleteTask(Task task) async {
    await _firebaseFirestore.collection("tasks").doc(task.id).delete();
  }

  static deleteTodo(Todo todo) async {
    await _firebaseFirestore.collection("todos").doc(todo.id).delete();
  }

  static Future<List<Task>> getComplitedTasksForUser(User user) async {
    List<Task> tasks = List.empty(growable: true);

    QuerySnapshot query = await _firebaseFirestore
        .collection("tasks")
        .where('userId', isEqualTo: user.uid)
        .where('isDone', isEqualTo: true)
        .get();

    var docs = query.docs;

    for (var doc in docs) {
      Map<String, dynamic> data =
          (doc as DocumentSnapshot<Map>).data() as Map<String, dynamic>;
      tasks.add(Task.fromMap(data));
    }

    Task.sortByTimestamp(tasks);
    return tasks;
  }

  static Future<List<Task>> getUncomplitedTasksForUser(User user) async {
    List<Task> tasks = List.empty(growable: true);

    QuerySnapshot query = await _firebaseFirestore
        .collection("tasks")
        .where('userId', isEqualTo: user.uid)
        .where('isDone', isEqualTo: false)
        .get();

    var docs = query.docs;

    for (var doc in docs) {
      Map<String, dynamic> data =
          (doc as DocumentSnapshot<Map>).data() as Map<String, dynamic>;
      tasks.add(Task.fromMap(data));
    }

    Task.sortByTimestamp(tasks);
    return tasks;
  }

  static Future<List<Todo>> getTodosForTask(Task task) async {
    List<Todo> todos = List.empty(growable: true);

    QuerySnapshot query = await _firebaseFirestore
        .collection("todos")
        .where('taskId', isEqualTo: task.id)
        .get();

    var docs = query.docs;

    for (var doc in docs) {
      Map<String, dynamic> data =
          (doc as DocumentSnapshot<Map>).data() as Map<String, dynamic>;
      todos.add(Todo.fromMap(data));
    }

    todos.sort((a, b) => a.order.compareTo(b.order));
    return todos;
  }
}
