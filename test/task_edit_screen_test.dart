import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app_ver1/models/task.dart';

void main() {
  group("Task tests", () {
    final emptyTask = Task(id: "1", userId: "1");
    test("Task description default value", () {
      expect(emptyTask.description, "");
    });
    test("Task title default value", () {
      expect(emptyTask.title, "");
    });
    test("Task isDone default value", () {
      expect(emptyTask.isDone, false);
    });
    test("Task title passed through constuctor", () {
      const taskTitle = "someTtile";
      final titledTask = Task(id: "2", userId: "1", title: taskTitle);
      expect(titledTask.title, taskTitle);
    });
  });

  //
  //
}
