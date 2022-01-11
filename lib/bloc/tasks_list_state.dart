part of 'tasks_list_bloc.dart';

@immutable
abstract class TasksListState {}

class TasksInitialState extends TasksListState {}

class TasksLoadingState extends TasksListState {}

class ShowOnlyUncompletedTasks extends TasksListState {
  final List<Task> tasks;

  ShowOnlyUncompletedTasks(this.tasks);
}

class ShowCompletedTasks extends TasksListState {
  final List<Task> tasks;

  ShowCompletedTasks(this.tasks);
}

class ShowOtherUserTasks extends TasksListState {
  final List<Task> tasks;

  ShowOtherUserTasks(this.tasks);
}

class ShowCompletedAndOtherUserTasks extends TasksListState {
  final List<Task> tasks;

  ShowCompletedAndOtherUserTasks(this.tasks);
}
