import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_ver1/databse.dart';
import 'package:todo_app_ver1/models/task.dart';
import 'package:todo_app_ver1/models/todo.dart';
import 'package:todo_app_ver1/models/user_model.dart';
import 'package:todo_app_ver1/screens/tasks_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;
  const TaskEditScreen({required this.task, Key? key}) : super(key: key);

  @override
  _TaskEditScreenState createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  bool _isLoading = true;

  final List<Todo> _todos = List.empty(growable: true);

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _newTodoFocus = FocusNode();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<List<Todo>> getTodosAfterSecond() async {
    List<Future> futures = List.empty(growable: true);

    Future<List<Todo>> todosForTask = Database.getTodosForTask(widget.task);

    futures.add(Future.delayed(const Duration(seconds: 1)));
    futures.add(todosForTask);
    await Future.wait(futures);

    return todosForTask;
  }

  @override
  void initState() {
    _titleController.text = widget.task.title;
    _descriptionController.text = widget.task.description;

    getTodosAfterSecond().then((value) {
      setState(() {
        _isLoading = false;
        _todos.addAll(value);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _newTodoFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleTextField = TextField(
      focusNode: _titleFocus,
      onSubmitted: (value) {
        setState(() {
          _titleController.text = value;
        });
        _descriptionFocus.requestFocus();
      },
      controller: _titleController,
      decoration: const InputDecoration(
        hintText: "Enter Task Title",
        border: InputBorder.none,
        //contentPadding:
        //    EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0)
      ),
      style: const TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF211551),
      ),
    );

    final descriptionTextField = TextField(
      focusNode: _descriptionFocus,
      onSubmitted: (value) {
        setState(() {
          _descriptionController.text = value;
        });
        _newTodoFocus.requestFocus();
      },
      controller: _descriptionController,
      decoration: const InputDecoration(
        hintText: "Enter Description for the task...",
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
            //horizontal: 24.0,
            ),
      ),
    );

    final dateTimeButton = GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.black),
                left: BorderSide(width: 1.0, color: Colors.black),
                right: BorderSide(width: 1.0, color: Colors.black),
                bottom: BorderSide(width: 1.0, color: Colors.black),
              ),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: <Widget>[
                  Text(
                      "Deadline:    " +
                          (widget.task.timestamp != null
                              ? DateFormat('dd-MM-yyyy')
                                  .format(widget.task.timestamp!.toDate())
                              : "Pick your deadline"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF000000))),
                  Expanded(
                    child: Container(),
                  ),
                  const Icon(Icons.calendar_today)
                ],
              ),
            ),
          ),
        ),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2021),
            lastDate: DateTime(2030));
        if (pickedDate != null) {
          widget.task.timestamp = Timestamp.fromDate(pickedDate);
          setState(() {
            Database.updateTask(widget.task);
          });
          //Database.updateTask(wi
          //))
        }
      },
      onLongPress: () {
        Tooltip(message: "Delete deadline");
      },
    );

    final dateTimeFiled = Row(
      children: [
        const Text("Datetime:"),
        GestureDetector(
          child: Text(widget.task.timestamp.toString()),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2021),
                lastDate: DateTime(2030));
            if (pickedDate != null) {
              widget.task.timestamp = Timestamp.fromDate(pickedDate);
              setState(() {
                Database.updateTask(widget.task);
              });
              //Database.updateTask(wi
              //))
            }
          },
        )
      ],
    );
    final newTodo = Row(children: [
      SizedBox(
        height: 24.0,
        width: 24.0,
        child: Checkbox(
          value: false,
          onChanged: (value) {},
          //),
        ),
      ),
      const SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: TextField(
            focusNode: _newTodoFocus,
            //controller: TextEditingController()..text = "",
            onSubmitted: (value) async {
              // Check if the field is not empty
              if (value != "") {
                Todo newTodo = Todo(
                    id: const Uuid().v4(),
                    taskId: widget.task.id,
                    title: value,
                    order: _todos.isEmpty ? 0 : _todos.last.order + 1);
                _newTodoFocus.requestFocus();
                setState(() {
                  _todos.add(newTodo);
                });
                Database.postTodoToFirestore(newTodo);
              }
            },
            decoration: const InputDecoration(
              hintText: "Enter Todo item",
              border: InputBorder.none,
              //contentPadding: EdgeInsets.symmetric(horizontal: 24.0)),
            )),
      )
    ]);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Task"),
          backgroundColor: Colors.blueAccent,
          leading: BackButton(
            onPressed: () {
              //addTaskToDatabse();
              if (_titleController.text != "" ||
                  _descriptionController.text != "" ||
                  _todos.isNotEmpty) {
                Database.updateTask(Task(
                    id: widget.task.id,
                    userId: widget.task.userId,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    timestamp: widget.task.timestamp,
                    isDone: widget.task.isDone));
              } else {
                Database.deleteTask(widget.task);
              }
              //Navigator.pop(context);
              Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => TasksScreen(
                        user: UserModel(
                            uid: FirebaseAuth.instance.currentUser!.uid,
                            email: FirebaseAuth.instance.currentUser!.email,
                            name: FirebaseAuth
                                .instance.currentUser!.displayName)),
                  ));
            },
          ),
        ),
        floatingActionButton: Tooltip(
          message: 'Delete task',
          child: FloatingActionButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Deleting task"),
                      content: const Text(
                          "Are you sure you want to delete the task?"),
                      actions: [
                        TextButton(
                          child: const Text("No"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            removeTaskFormDatabase();
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => TasksScreen(
                                    user: UserModel(
                                        uid: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        email: FirebaseAuth
                                            .instance.currentUser!.email,
                                        name: FirebaseAuth.instance.currentUser!
                                            .displayName)),
                              ),
                            );
                          },
                        )
                      ],
                    );
                  });
            },
            child: const Icon(Icons.delete_rounded),
            backgroundColor: Colors.redAccent,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding:
                    const EdgeInsets.only(left: 24.0, top: 20.0, right: 24.0),
                itemCount: 4 + _todos.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) return titleTextField;
                  if (index == 1) return descriptionTextField;
                  if (index == 2)
                    return /*dateTimeFiled*/ Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: dateTimeButton,
                    );
                  if (index == 3 + _todos.length) {
                    return newTodo;
                  } else {
                    return TodoItem(todo: _todos[index - 3]);
                  }
                }));
  }

  addTaskToDatabse() {
    Database.postTaskToFirestore(Task(
        id: widget.task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        userId: FirebaseAuth.instance.currentUser!.uid));
  }

  removeTaskFormDatabase() {
    Database.deleteTask(Task(
        id: widget.task.id,
        title: _titleController.text,
        description: _descriptionController.text,
        userId: FirebaseAuth.instance.currentUser!.uid));
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  const TodoItem({required this.todo, Key? key}) : super(key: key);

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24.0,
          width: 24.0,
          child: Checkbox(
            value: widget.todo.isDone,
            onChanged: (value) {
              setState(() {
                widget.todo.isDone = value;
              });
              Database.updateTodo(widget.todo);
            },
            //),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextField(
            onSubmitted: (value) {
              setState(() {
                if (value == "") {
                } else {
                  widget.todo.title = value;
                  Database.updateTodo(widget.todo);
                }
              });
            },
            controller: TextEditingController()..text = widget.todo.title,
            decoration: const InputDecoration(
              hintText: "Enter Todo Title",
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }
}
