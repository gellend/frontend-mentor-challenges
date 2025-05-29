import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/services/storage/todo_storage_interface.dart';

class LocalTodoService implements TodoStorageInterface {
  static const String _todosKey = 'local_todos';
  final StreamController<List<Todo>> _todosController = StreamController<List<Todo>>.broadcast();
  final Uuid _uuid = const Uuid();
  List<Todo> _todos = [];
  bool _isInitialized = false;

  LocalTodoService() {
    // Emit empty list immediately to prevent loading loop
    _todosController.add([]);
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_todosKey);
      
      if (todosJson != null && todosJson.isNotEmpty) {
        try {
          final List<dynamic> todosList = json.decode(todosJson);
          _todos = todosList.map((todoMap) => Todo.fromJson(todoMap)).toList();
          _todos.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        } catch (e) {
          debugPrint('Error loading local todos: $e');
          _todos = [];
        }
      } else {
        _todos = [];
      }
      
      _isInitialized = true;
      
      // Always emit the loaded todos (or empty list)
      if (!_todosController.isClosed) {
        _todosController.add(_todos);
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _todos = [];
      _isInitialized = true;
      if (!_todosController.isClosed) {
        _todosController.add(_todos);
      }
    }
  }

  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = json.encode(_todos.map((todo) => todo.toJson()).toList());
      await prefs.setString(_todosKey, todosJson);
    } catch (e) {
      debugPrint('Error saving local todos: $e');
    }
  }

  @override
  Stream<List<Todo>> getTodosStream() {
    return _todosController.stream;
  }

  @override
  Future<void> addTodo(String text) async {
    await _initialize();
    
    final newTodo = Todo(
      id: _uuid.v4(),
      userId: 'local_user', // Default user ID for local storage
      text: text,
      createdAt: Timestamp.now(),
      orderIndex: _todos.length,
    );
    
    _todos.add(newTodo);
    await _saveTodos();
    _todosController.add(_todos);
  }

  @override
  Future<void> updateTodoStatus(String id, bool isCompleted) async {
    await _initialize();
    
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(isCompleted: isCompleted);
      await _saveTodos();
      _todosController.add(_todos);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _initialize();
    
    _todos.removeWhere((todo) => todo.id == id);
    
    // Reorder the remaining todos
    for (int i = 0; i < _todos.length; i++) {
      _todos[i] = _todos[i].copyWith(orderIndex: i);
    }
    
    await _saveTodos();
    _todosController.add(_todos);
  }

  @override
  Future<void> clearCompletedTodos() async {
    await _initialize();
    
    _todos.removeWhere((todo) => todo.isCompleted);
    
    // Reorder the remaining todos
    for (int i = 0; i < _todos.length; i++) {
      _todos[i] = _todos[i].copyWith(orderIndex: i);
    }
    
    await _saveTodos();
    _todosController.add(_todos);
  }

  @override
  Future<void> updateTodoOrder(List<Todo> todos) async {
    await _initialize();
    
    // Update the internal list with new order
    _todos = List.from(todos);
    
    // Update orderIndex for each todo
    for (int i = 0; i < _todos.length; i++) {
      _todos[i] = _todos[i].copyWith(orderIndex: i);
    }
    
    await _saveTodos();
    _todosController.add(_todos);
  }

  @override
  Future<void> dispose() async {
    await _todosController.close();
  }

  // Helper method to get all local todos (useful for migration)
  Future<List<Todo>> getAllTodos() async {
    await _initialize();
    return List.from(_todos);
  }

  // Helper method to clear all todos (useful for migration)
  Future<void> clearAllTodos() async {
    await _initialize();
    _todos.clear();
    await _saveTodos();
    _todosController.add(_todos);
  }
} 