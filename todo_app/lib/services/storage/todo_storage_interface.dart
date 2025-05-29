import 'package:todo_app/models/todo_model.dart';

abstract class TodoStorageInterface {
  Stream<List<Todo>> getTodosStream();
  Future<void> addTodo(String text);
  Future<void> updateTodoStatus(String id, bool isCompleted);
  Future<void> deleteTodo(String id);
  Future<void> clearCompletedTodos();
  Future<void> updateTodoOrder(List<Todo> todos);
  Future<void> dispose();
} 