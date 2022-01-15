part of 'tasks_list_bloc.dart';

@immutable
abstract class TasksListEvent {}

class AddUncompletedTasks extends TasksListEvent {}

class AddCompletedTasks extends TasksListEvent {}

class HideCompletedTasks extends TasksListEvent {}
