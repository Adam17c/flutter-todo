import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_ver1/auth_service.dart';
import 'package:todo_app_ver1/bloc/tasks_list_bloc.dart';
import 'package:todo_app_ver1/databse.dart';
import 'package:todo_app_ver1/main.dart';
import 'package:todo_app_ver1/models/task.dart';
import 'package:todo_app_ver1/screens/login_screen.dart';
import 'package:todo_app_ver1/screens/task_edit_screen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:animations/animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasksScreen extends StatefulWidget {
  final User user;
  const TasksScreen({required this.user, Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _tasks = List.empty(growable: true);

  String menuText = 'Show completed tasks';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => TasksListBloc(widget.user),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskListController(_tasks),
        ),
      ],
      child: BlocBuilder<TasksListBloc, TasksListState>(
        builder: (context, state) {
          if (state is TasksInitialState) {
            context.read<TasksListBloc>().add(AddUncompletedTasks());
          }
          if (state is ShowOnlyUncompletedTasks) {
            _tasks.clear();
            _tasks.addAll(state.uncompletedTasks);
            menuText = 'Show completed tasks';
          }
          if (state is ShowCompletedTasks) {
            _tasks.clear();
            _tasks.addAll(state.umcompletedAndCOmpletedTasks);
            menuText = 'Hide completed tasks';
          }
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
                title: Text("Todo List - " + widget.user.displayName!),
                backgroundColor: Colors.blueAccent,
                actions: [
                  Tooltip(
                    child: Switch(
                        value:
                            Provider.of<ThemeController>(context, listen: false)
                                .isDarkMode(),
                        onChanged: (value) {
                          Provider.of<ThemeController>(context, listen: false)
                              .changeTheme(value);
                        }),
                    message: 'Change color theme',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) async {
                      if (value == 'Logout') {
                        AuthService authService =
                            AuthService(firebaseAuth: FirebaseAuth.instance);
                        authService.signOut();
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const LoginScreen(),
                            ));
                      } else if (value == menuText) {
                        if (state is ShowOnlyUncompletedTasks) {
                          context
                              .read<TasksListBloc>()
                              .add(AddCompletedTasks());
                        } else if (state is ShowCompletedTasks) {
                          context
                              .read<TasksListBloc>()
                              .add(HideCompletedTasks());
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Logout', menuText}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
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
                              tasksController: controller,
                              fadeOutOnCheck: state is ShowOnlyUncompletedTasks,
                            );
                            return listItem;
                          });
                    }));
        },
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final Task task;
  final TaskListController tasksController;
  final bool fadeOutOnCheck;

  const ListItem({
    Key? key,
    required this.task,
    required this.tasksController,
    required this.fadeOutOnCheck,
  }) : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool _isFadingOut = false;
  final int _fadingOutTime = 500;
  bool _expired = false;

  @override
  void initState() {
    if (widget.task.timestamp != null &&
        DateTime.now().toUtc().isAfter(DateTime.fromMillisecondsSinceEpoch(
              widget.task.timestamp!.millisecondsSinceEpoch,
              isUtc: false,
            ).toUtc())) {
      _expired = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: _fadingOutTime),
      opacity: _isFadingOut ? 0.0 : 1.0,
      onEnd: () {
        if (_isFadingOut) {
          widget.tasksController.remove(widget.task);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                    if (widget.fadeOutOnCheck && value == true) {
                      _isFadingOut = true;
                    }
                  });
                },
              ),
            ),
            title: GestureDetector(
              child: Text(
                widget.task.title,
                style: TextStyle(
                    color:
                        checkIfDarkModeIsOn() ? Colors.white54 : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              onTap: () {
                goToTaskPage(widget.task);
              },
            ),
            subtitle: GestureDetector(
              child: Text(
                (widget.task.timestamp != null
                    ? DateFormat('dd-MM-yyyy')
                        .format(widget.task.timestamp!.toDate())
                    : "No deadline"),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _expired ? Colors.redAccent : Colors.blueAccent),
              ),
              onTap: () {
                goToTaskPage(widget.task);
              },
            ),
            trailing: OpenContainer(
              closedBuilder:
                  (BuildContext context, VoidCallback openContainer) {
                return GestureDetector(
                    child: Container(
                      color: _expired ? Colors.redAccent : Colors.blueAccent,
                      child: const Icon(Icons.keyboard_arrow_right,
                          color: Colors.black, size: 30.0),
                    ),
                    onTap: openContainer);
              },
              openBuilder: (BuildContext context, VoidCallback openContainer) {
                return TaskEditScreen(task: widget.task);
              },
              transitionDuration: const Duration(seconds: 1),
            )),
      ),
    );
  }

  void goToTaskPage(Task task) {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => TaskEditScreen(task: task)));
  }

  bool checkIfDarkModeIsOn() {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

class TaskListController extends ChangeNotifier {
  List<Task> tasks;

  TaskListController(this.tasks);

  void remove(Task removedTask) {
    tasks.remove(removedTask);
    notifyListeners();
  }
}
