import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app_ver1/models/task.dart';
import 'package:todo_app_ver1/models/todo.dart';
import 'models/user_model.dart';

class Database {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static postUserToFirestore(UserModel userModel) async {
    //FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await _firebaseFirestore
        .collection("users")
        .doc(userModel.uid)
        .set(userModel.toMap());
  }

  static postTaskToFirestore(Task task) async {
    //FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await _firebaseFirestore.collection("tasks").doc(task.id).set(task.toMap());
  }

  static postTodoToFirestore(Todo todo) async {
    //FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await _firebaseFirestore.collection("todos").doc(todo.id).set(todo.toMap());
  }

  static updateTask(Task task) async {
    //FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await _firebaseFirestore.collection("tasks").doc(task.id).update({
      "title": task.title,
      "description": task.description,
      "isDone": task.isDone,
      "timestamp": task.timestamp,
    });
  }

  static updateTodo(Todo todo) async {
    //FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    await _firebaseFirestore
        .collection("todos")
        .doc(todo.id)
        .update({"title": todo.title, "isDone": todo.isDone});
  }

  static deleteTask(Task task) async {
    await _firebaseFirestore.collection("tasks").doc(task.id).delete()
        //.catchError((error) => print("Failed to delete user: $error"))
        ;
  }

  static deleteTodo(Todo todo) async {
    await _firebaseFirestore.collection("todos").doc(todo.id).delete()
        //.catchError((error) => print("Failed to delete user: $error"))
        ;
  }

  static Future<List<Task>> getComplitedTasksForUser(
      UserModel userModel) async {
    //FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    List<Task> tasks = List.empty(growable: true);

    QuerySnapshot query = await _firebaseFirestore
        .collection("tasks")
        .where('userId', isEqualTo: userModel.uid)
        .where('isDone', isEqualTo: true)
        //.orderBy('timestamp')
        .get();

    var docs = query.docs;

    for (var doc in docs) {
      Map<String, dynamic> data =
          (doc as DocumentSnapshot<Map>).data() as Map<String, dynamic>;
      tasks.add(Task.fromMap(data));
    }
    //tasks
    //    .sort((a, b) =>  a.timestamp!.toDate().compareTo(b.timestamp!.toDate())
    //    );

    tasks.sort((a, b) {
      int result;
      if (a.timestamp == null) {
        result = 1;
      } else if (b.timestamp == null) {
        result = -1;
      } else {
        // Ascending Order
        result = a.timestamp!.toDate().compareTo(b.timestamp!.toDate());
      }
      return result;
    });
    //Map<String, dynamic> data = res.data as Map<String, dynamic>;
    //return Task.fromMap(data);
    return tasks;
  }

  static Future<List<Task>> getUncomplitedTasksForUser(
      UserModel userModel) async {
    //FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    List<Task> tasks = List.empty(growable: true);

    QuerySnapshot query = await _firebaseFirestore
        .collection("tasks")
        .where('userId', isEqualTo: userModel.uid)
        .where('isDone', isEqualTo: false)
        //.orderBy('timestamp')
        .get();

    var docs = query.docs;

    for (var doc in docs) {
      Map<String, dynamic> data =
          (doc as DocumentSnapshot<Map>).data() as Map<String, dynamic>;
      tasks.add(Task.fromMap(data));
    }
    //tasks
    //    .sort((a, b) =>  a.timestamp!.toDate().compareTo(b.timestamp!.toDate())
    //    );

    tasks.sort((a, b) {
      int result;
      if (a.timestamp == null) {
        result = 1;
      } else if (b.timestamp == null) {
        result = -1;
      } else {
        // Ascending Order
        result = a.timestamp!.toDate().compareTo(b.timestamp!.toDate());
      }
      return result;
    });
    //Map<String, dynamic> data = res.data as Map<String, dynamic>;
    //return Task.fromMap(data);
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
