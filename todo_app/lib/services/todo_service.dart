import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Note: Collection name can be stored in a constant file later
  late final CollectionReference<Todo> _todosRef;

  TodoService() {
    _todosRef = _firestore.collection('todos').withConverter<Todo>(
          fromFirestore: (snapshots, _) => Todo.fromFirestore(snapshots),
          toFirestore: (todo, _) => todo.toFirestore(),
        );
  }

  // Get a stream of todos for a specific user
  Stream<QuerySnapshot<Todo>> getTodosStream(String userId) {
    return _todosRef.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots();
  }

  // Add a new todo
  Future<void> addTodo(String userId, String text) async {
    try {
      await _todosRef.add(
        Todo(
          userId: userId,
          text: text,
          createdAt: Timestamp.now(), // Firestore server timestamp can also be used
        ),
      );
    } catch (e) {
      // Handle error (e.g., log it, show a message)
      print('Error adding todo: $e');
      rethrow; // Rethrow to allow UI to handle it if needed
    }
  }

  // Update a todo's completion status
  Future<void> updateTodoStatus(String todoId, bool isCompleted) async {
    try {
      await _todosRef.doc(todoId).update({'isCompleted': isCompleted});
    } catch (e) {
      print('Error updating todo status: $e');
      rethrow;
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String todoId) async {
    try {
      await _todosRef.doc(todoId).delete();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }
  
  // Clear all completed todos for a user
  Future<void> clearCompletedTodos(String userId) async {
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
      print('Error clearing completed todos: $e');
      rethrow;
    }
  }
} 