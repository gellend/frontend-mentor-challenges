import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/services/storage/todo_storage_interface.dart';

class CloudTodoService implements TodoStorageInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  late final CollectionReference<Todo> _todosRef;

  CloudTodoService({required this.userId}) {
    _todosRef = _firestore.collection('todos').withConverter<Todo>(
          fromFirestore: (snapshots, _) => Todo.fromFirestore(snapshots),
          toFirestore: (todo, _) => todo.toFirestore(),
        );
  }

  @override
  Stream<List<Todo>> getTodosStream() {
    return _todosRef
        .where('userId', isEqualTo: userId)
        .orderBy('orderIndex', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> addTodo(String text) async {
    try {
      // Get the current count of todos for the user to determine the next orderIndex
      final QuerySnapshot<Todo> userTodosSnapshot = await _todosRef
          .where('userId', isEqualTo: userId)
          .get();
      final int nextOrderIndex = userTodosSnapshot.docs.length;

      await _todosRef.add(
        Todo(
          userId: userId,
          text: text,
          createdAt: Timestamp.now(), 
          orderIndex: nextOrderIndex,
        ),
      );
    } catch (e) {
      debugPrint('Error adding todo: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTodoStatus(String todoId, bool isCompleted) async {
    try {
      await _todosRef.doc(todoId).update({'isCompleted': isCompleted});
    } catch (e) {
      debugPrint('Error updating todo status: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    try {
      await _todosRef.doc(todoId).delete();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> clearCompletedTodos() async {
    try {
      final WriteBatch batch = _firestore.batch();
      final QuerySnapshot<Todo> completedTodosSnapshot = await _todosRef
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .get();

      for (final DocumentSnapshot<Todo> doc in completedTodosSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing completed todos: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTodoOrder(List<Todo> todos) async {
    if (todos.isEmpty) return;
    try {
      final WriteBatch batch = _firestore.batch();
      for (int i = 0; i < todos.length; i++) {
        final Todo todo = todos[i];
        if (todo.id != null) {
          final DocumentReference docRef = _todosRef.doc(todo.id);
          batch.update(docRef, {'orderIndex': i});
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error updating todo order: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    // No cleanup needed for cloud service
  }
} 