import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:todo_app_ver1/models/task.dart';

import '../databse.dart';

part 'tasks_list_event.dart';
part 'tasks_list_state.dart';

enum TypeOfTasks { uncompleted, completed }

class TasksListBloc extends Bloc<TasksListEvent, TasksListState> {
  final User _user;
  final List<Task> _tasks;

  Future<List<Task>> getTasksAfterSecond(TypeOfTasks type) async {
    List<Future> futures = List.empty(growable: true);
    Future<List<Task>> newTasks;

    switch (type) {
      case TypeOfTasks.uncompleted:
        newTasks = Database.getUncomplitedTasksForUser(_user);
        break;
      case TypeOfTasks.completed:
        newTasks = Database.getComplitedTasksForUser(_user);
        break;
    }

    futures.add(Future.delayed(const Duration(seconds: 1)));
    futures.add(newTasks);
    await Future.wait(futures);

    return newTasks;
  }

  TasksListBloc(this._user, this._tasks) : super(TasksInitialState()) {
    on<TasksListEvent>((event, emit) async {
      if (event is AddUncompletedTasks) {
        emit(TasksLoadingState());
        await getTasksAfterSecond(TypeOfTasks.uncompleted).then((value) =>
            {_tasks.addAll(value), emit(ShowOnlyUncompletedTasks())});
      } else if (event is AddCompletedTasks &&
          state is ShowOnlyUncompletedTasks) {
        {
          emit(TasksLoadingState());
          await getTasksAfterSecond(TypeOfTasks.completed).then((value) => {
                _tasks.addAll(value),
                Task.sortByTimestamp(_tasks),
                emit(ShowCompletedTasks())
              });
        }
      } else if (event is HideCompletedTasks && state is ShowCompletedTasks) {
        _tasks.removeWhere((task) => task.isDone == true);
        emit(ShowOnlyUncompletedTasks());
      }
    });
  }
}
