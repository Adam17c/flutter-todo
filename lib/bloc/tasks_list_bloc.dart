import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:todo_app_ver1/models/task.dart';

import '../databse.dart';

part 'tasks_list_event.dart';
part 'tasks_list_state.dart';

enum TypeOfTasks { uncompleted, completed }

class TasksListBloc extends Bloc<TasksListEvent, TasksListState> {
  final User user;

  Future<List<Task>> getTasksAfterSecond(TypeOfTasks type) async {
    List<Future> futures = List.empty(growable: true);
    Future<List<Task>> newTasks;

    switch (type) {
      case TypeOfTasks.uncompleted:
        newTasks = Database.getUncomplitedTasksForUser(user);
        break;
      case TypeOfTasks.completed:
        newTasks = Database.getComplitedTasksForUser(user);
        break;
    }

    futures.add(Future.delayed(const Duration(seconds: 1)));
    futures.add(newTasks);
    await Future.wait(futures);

    return newTasks;
  }

  TasksListBloc(this.user) : super(TasksInitialState()) {
    on<TasksListEvent>((event, emit) async {
      if (event is AddUncompletedTasks) {
        emit(TasksLoadingState());
        await getTasksAfterSecond(TypeOfTasks.uncompleted)
            .then((value) => emit(ShowOnlyUncompletedTasks(value)));
      } else if (event is AddCompletedTasks &&
          state is ShowOnlyUncompletedTasks) {
        {
          List<Task> tasks =
              List.from((state as ShowOnlyUncompletedTasks).uncompletedTasks)
                ..removeWhere((task) => task.isDone == true);
          emit(TasksLoadingState());
          await getTasksAfterSecond(TypeOfTasks.completed).then((value) => {
                tasks.addAll(value),
                Task.sortByTimestamp(tasks),
                emit(ShowCompletedTasks(tasks))
              });
        }
      } else if (event is HideCompletedTasks && state is ShowCompletedTasks) {
        if (state is ShowCompletedTasks) {
          List<Task> tasks = List.from(
              (state as ShowCompletedTasks).umcompletedAndCOmpletedTasks)
            ..removeWhere((task) => task.isDone == true);
          emit(ShowOnlyUncompletedTasks(tasks));
        }
      }
    });
  }
}
