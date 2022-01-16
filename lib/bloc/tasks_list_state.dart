part of 'tasks_list_bloc.dart';

@immutable
abstract class TasksListState {}

class TasksInitialState extends TasksListState {}

class TasksLoadingState extends TasksListState {}

class ShowOnlyUncompletedTasks extends TasksListState {}

class ShowCompletedTasks extends TasksListState {}
