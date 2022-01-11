part of 'tasks_list_bloc.dart';

@immutable
abstract class TasksListEvent {}

class AddUncompletedTasks extends TasksListEvent {}

class AddCompletedTasks extends TasksListEvent {}

class AddOtherUserTasks extends TasksListEvent {}

class RemoveCompletedTasks extends TasksListEvent {}

class RemoveOtherUserTasks extends TasksListEvent {}
