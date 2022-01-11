import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo_app_ver1/models/task.dart';
import 'package:todo_app_ver1/models/user_model.dart';

import '../databse.dart';

part 'tasks_list_event.dart';
part 'tasks_list_state.dart';

enum TypeOfTasks { uncompleted, completed, otherUser }

class TasksListBloc extends Bloc<TasksListEvent, TasksListState> {
  final UserModel user;

  TasksListBloc(this.user) : super(TasksInitialState()) {
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
        //case TypeOfTasks.otherUser:
        // TODO: Handle this case.
        //break;
        default:
          newTasks = Database.getUncomplitedTasksForUser(user);
          break;
      }

      futures.add(Future.delayed(const Duration(seconds: 1)));
      futures.add(newTasks);
      await Future.wait(futures);

      return newTasks;
    }

    on<TasksListEvent>((event, emit) {
      if (event is AddUncompletedTasks) {
        getTasksAfterSecond(TypeOfTasks.uncompleted)
            .then((value) => emit(ShowOnlyUncompletedTasks(value)));
      }

      if (event is AddCompletedTasks) {
        if (state is ShowOnlyUncompletedTasks) {
          emit(TasksLoadingState());
          List<Task> tasks = List.empty(growable: true)
            ..addAll((state as ShowOnlyUncompletedTasks).tasks);
          getTasksAfterSecond(TypeOfTasks.completed)
              .then((value) => emit(ShowCompletedTasks(tasks)));
        }
        if (state is ShowOtherUserTasks) {
          emit(TasksLoadingState());

          List<Task> tasks = List.empty(growable: true)
            ..addAll((state as ShowOtherUserTasks).tasks);
          getTasksAfterSecond(TypeOfTasks.completed)
              .then((value) => emit(ShowCompletedAndOtherUserTasks(tasks)));
        }
      }

      if (event is AddOtherUserTasks) {
        if (state is ShowOnlyUncompletedTasks) {
          emit(TasksLoadingState());
          List<Task> tasks = List.empty(growable: true)
            ..addAll((state as ShowOnlyUncompletedTasks).tasks);
          getTasksAfterSecond(TypeOfTasks.otherUser)
              .then((value) => emit(ShowOtherUserTasks(tasks)));
        }
        if (state is ShowCompletedTasks) {
          emit(TasksLoadingState());
          List<Task> tasks = List.empty(growable: true)
            ..addAll((state as ShowCompletedTasks).tasks);
          getTasksAfterSecond(TypeOfTasks.otherUser)
              .then((value) => emit(ShowCompletedAndOtherUserTasks(tasks)));
        }
      }
    });
  }
}
