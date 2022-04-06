import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_ver1/databse.dart';
import 'package:todo_app_ver1/models/task.dart';
import 'package:todo_app_ver1/models/todo.dart';
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
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleTextField = TextField(
      focusNode: _titleFocus,
      onSubmitted: (value) {
        setState(() {
          widget.task.title = value;
          Database.updateTask(widget.task);
        });
        _descriptionFocus.requestFocus();
      },
      controller: _titleController,
      decoration: const InputDecoration(
        hintText: "Enter Task Title",
        border: InputBorder.none,
      ),
      style: const TextStyle(
        fontSize: 26.0,
        fontWeight: FontWeight.bold,
      ),
    );

    final descriptionTextField = TextField(
      focusNode: _descriptionFocus,
      onSubmitted: (value) {
        setState(() {
          widget.task.description = value;
          Database.updateTask(widget.task);
        });
        _newTodoFocus.requestFocus();
      },
      controller: _descriptionController,
      decoration: const InputDecoration(
        hintText: "Enter Task Description",
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(),
      ),
      style: const TextStyle(fontSize: 18),
    );

    final dateTimeButton = GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Material(
          borderRadius: BorderRadius.circular(5),
          elevation: 5.0,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1.0,
                    color:
                        checkIfDarkModeIsOn() ? Colors.white60 : Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
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
                        style: TextStyle(
                            color: widget.task.timestamp != null
                                ? checkIfDarkModeIsOn()
                                    ? Colors.white60
                                    : Colors.black
                                : Colors.grey[700],
                            fontSize: 18)),
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
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2021),
            lastDate: DateTime(2030));
        if (pickedDate != null) {
          setState(() {
            widget.task.timestamp = Timestamp.fromDate(pickedDate);
            Database.updateTask(widget.task);
          });
        }
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Deleting Deadline"),
                content: const Text("Do you want ot delete the Deadline?"),
                actions: [
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      setState(() {
                        widget.task.timestamp = null;
                        Database.updateTask(widget.task);
                      });
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      },
    );

    final newTodo = Row(children: [
      SizedBox(
        height: 24.0,
        width: 24.0,
        child: Checkbox(
          value: false,
          onChanged: (value) {},
        ),
      ),
      const SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: TextField(
            focusNode: _newTodoFocus,
            onSubmitted: (value) async {
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
            )),
      )
    ]);

    void goBackToTaskList() {
      Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                TasksScreen(user: FirebaseAuth.instance.currentUser!),
          ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Task"),
          backgroundColor: Colors.blueAccent,
          leading: BackButton(
            onPressed: () {
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
              goBackToTaskList();
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
                      content: const Text("Do you want to delete the task?"),
                      actions: [
                        TextButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            Database.deleteTask(Task(
                                id: widget.task.id,
                                title: _titleController.text,
                                description: _descriptionController.text,
                                userId:
                                    FirebaseAuth.instance.currentUser!.uid));
                            goBackToTaskList();
                          },
                        ),
                        TextButton(
                          child: const Text("No"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
            },
            child: const Icon(Icons.delete_rounded),
            backgroundColor: Colors.redAccent,
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 24.0,
                top: 20.0,
                right: 24.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: dateTimeButton,
                    ),
                    titleTextField,
                    descriptionTextField,
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
              ),
              sliver: _isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return index < _todos.length
                              ? TodoItem(todo: _todos[index])
                              : newTodo;
                        },
                        childCount: _todos.length + 1,
                      ),
                    ),
            )
          ],
        ));
  }

  bool checkIfDarkModeIsOn() => Theme.of(context).brightness == Brightness.dark;
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
                Database.updateTodo(widget.todo);
              });
            },
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextField(
            onSubmitted: (value) {
              setState(() {
                if (value != "") {
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
