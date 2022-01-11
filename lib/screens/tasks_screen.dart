import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_ver1/auth_service.dart';
import 'package:todo_app_ver1/bloc/tasks_list_bloc.dart';
import 'package:todo_app_ver1/databse.dart';
import 'package:todo_app_ver1/models/task.dart';
import 'package:todo_app_ver1/models/todo.dart';
import 'package:todo_app_ver1/models/user_model.dart';
import 'package:todo_app_ver1/screens/login_screen.dart';
import 'package:todo_app_ver1/screens/task_edit_screen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class TasksScreen extends StatefulWidget {
  final UserModel user;
  const TasksScreen({required this.user, Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _tasks = List.empty(growable: true);
  bool _isLoading = true;
  bool _showCompletedTasks = false;

  Future<List<Task>> getTasksAfterSecond() async {
    List<Future> futures = List.empty(growable: true);

    Future<List<Task>> tasksForUser =
        Database.getUncomplitedTasksForUser(widget.user);

    futures.add(Future.delayed(const Duration(seconds: 1)));
    futures.add(tasksForUser);
    await Future.wait(futures);

    return tasksForUser;
  }

  @override
  void initState() {
    getTasksAfterSecond().then((value) => {
          setState(() {
            _isLoading = false;
            _tasks.addAll(value);
          })
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasksListBloc(widget.user),
      child: ChangeNotifierProvider(
        create: (context) => TaskListController(_tasks),
        child: BlocBuilder<TasksListBloc, TasksListState>(
          builder: (context, state) {
            return Scaffold(
                floatingActionButton: Tooltip(
                  message: 'Add new task',
                  child: FloatingActionButton(
                    onPressed: () {
                      Task newTask = Task(
                          id: const Uuid().v4(),
                          userId: FirebaseAuth.instance.currentUser!.uid);
                      Database.postTaskToFirestore(newTask);
                      Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  TaskEditScreen(task: newTask)));
                    },
                    child: const Icon(Icons.add),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text("Todo List"),
                  backgroundColor: Colors.blueAccent,
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (String value) async {
                        switch (value) {
                          case 'Logout':
                            AuthService authService = AuthService(
                                firebaseAuth: FirebaseAuth.instance);
                            authService.signOut();
                            Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      LoginScreen(),
                                ));
                            break;
                          case 'Show also completed tasks':
                            context
                                .read<TasksListBloc>()
                                .add(AddCompletedTasks());
                          /*_tasks.addAll(
                                await Database.getComplitedTasksForUser(
                                    widget.user));
                            _tasks.sort((a, b) {
                              int result;
                              if (a.timestamp == null) {
                                result = 1;
                              } else if (b.timestamp == null) {
                                result = -1;
                              } else {
                                // Ascending Order
                                result = a.timestamp!
                                    .toDate()
                                    .compareTo(b.timestamp!.toDate());
                              }
                              return result;
                            });
                            setState(() {});
                            break;*/
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Logout', 'Show also completed tasks'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                // jeśli initial state to kręcioł + pobieramy neiukończone zadania (event)
                // jeśli loading state to kręcioł
                // jeślli inny state to lista
                // i gdzieś trzeba dać że tasks = state.tasks
                body: state is TasksLoadingState
                    ? const Center(child: CircularProgressIndicator())
                    : Consumer<TaskListController>(
                        builder: (context, controller, _) {
                        return ListView.builder(
                            padding: const EdgeInsetsDirectional.only(top: 20),
                            itemCount: _tasks.length,
                            itemBuilder: (BuildContext context, int index) {
                              ListItem listItem = ListItem(
                                  key: ValueKey(_tasks[index]),
                                  task: _tasks[index],
                                  unfinishedTasks: controller);
                              return listItem;
                            });
                      }));
          },
        ),
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final Task task;
  final TaskListController unfinishedTasks;

  const ListItem({Key? key, required this.task, required this.unfinishedTasks})
      : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool _isFadingOut = false;
  final int _fadingOutTime = 500;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: _fadingOutTime),
      opacity: _isFadingOut ? 0.0 : 1.0,
      onEnd: () {
        if (_isFadingOut) {
          widget.unfinishedTasks.remove(widget.task);
        }
      },
      child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: const EdgeInsets.only(right: 12.0),
            decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(width: 1.0, color: Colors.white24))),
            child: Checkbox(
              value: widget.task.isDone,
              onChanged: (value) async {
                setState(() {
                  widget.task.isDone = value;
                  Database.updateTask(widget.task);
                  if (value == true) {
                    _isFadingOut = true;
                  }
                });
              },
            ),
          ),
          title: GestureDetector(
            child: Text(
              widget.task.title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
            onTap: () {
              Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          TaskEditScreen(task: widget.task)));
            },
          ),
          subtitle: GestureDetector(
            child: Text(
              "Deadline: " +
                  (widget.task.timestamp != null
                      ? DateFormat('dd-MM-yyyy')
                          .format(widget.task.timestamp!.toDate())
                      : "No deadline"),
            ),
            onTap: () {
              Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          TaskEditScreen(task: widget.task)));
            },
          ),
          trailing: GestureDetector(
            child: const Icon(Icons.keyboard_arrow_right,
                color: Colors.black, size: 30.0),
            onTap: () {
              Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          TaskEditScreen(task: widget.task)));
            },
          )),
    );
  }
}

class TaskListController extends ChangeNotifier {
  List<Task> tasks;

  TaskListController(this.tasks);

  void remove(Task task) {
    tasks.remove(task);
    notifyListeners();
  }
}
