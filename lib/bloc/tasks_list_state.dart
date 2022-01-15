part of 'tasks_list_bloc.dart';

@immutable
abstract class TasksListState {}

class TasksInitialState extends TasksListState {}

class TasksLoadingState extends TasksListState {}

class ShowOnlyUncompletedTasks extends TasksListState {
  final List<Task> uncompletedTasks;

  ShowOnlyUncompletedTasks(this.uncompletedTasks);
}

class ShowCompletedTasks extends TasksListState {
  final List<Task> umcompletedAndCOmpletedTasks;

  ShowCompletedTasks(this.umcompletedAndCOmpletedTasks);
}
