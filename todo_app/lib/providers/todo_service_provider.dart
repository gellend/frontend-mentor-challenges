import 'package:flutter/widgets.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/services/storage/todo_storage_interface.dart';
import 'package:todo_app/services/storage/local_todo_service.dart';
import 'package:todo_app/services/storage/cloud_todo_service.dart';

class TodoServiceProvider extends ChangeNotifier {
  TodoStorageInterface? _storage;
  bool _isCloudMode = false;
  bool _isInitialized = false;
  bool _isMigrating = false;
  
  // Public getters
  TodoStorageInterface get storage => _storage!;
  bool get isCloudMode => _isCloudMode;
  bool get isInitialized => _isInitialized;
  bool get isMigrating => _isMigrating;
  
  // Initialize with local storage
  Future<void> initializeLocal() async {
    if (_isInitialized) return;
    
    _storage = LocalTodoService();
    _isCloudMode = false;
    _isInitialized = true;
    
    // Defer notifyListeners to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  // Switch to cloud mode with migration
  Future<void> switchToCloud(String userId) async {
    if (_isCloudMode && _storage is CloudTodoService) {
      // Already in cloud mode, just check if user is the same
      return;
    }
    
    _isMigrating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      // Get local todos before switching
      List<Todo> localTodos = [];
      if (_storage is LocalTodoService) {
        localTodos = await (_storage as LocalTodoService).getAllTodos();
      }
      
      // Dispose old storage
      if (_storage != null) {
        await _storage!.dispose();
      }
      
      // Create cloud storage
      _storage = CloudTodoService(userId: userId);
      _isCloudMode = true;
      
      // Migrate local todos to cloud if any exist
      if (localTodos.isNotEmpty) {
        await _migrateLocalToCloud(localTodos, userId);
      }
      
      _isMigrating = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error switching to cloud mode: $e');
      _isMigrating = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }
  
  // Switch back to local mode (for sign out)
  Future<void> switchToLocal() async {
    if (!_isCloudMode) return;
    
    try {
      // Dispose cloud storage
      if (_storage != null) {
        await _storage!.dispose();
      }
      
      // Switch to local storage
      _storage = LocalTodoService();
      _isCloudMode = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error switching to local mode: $e');
      rethrow;
    }
  }
  
  // Migration helper
  Future<void> _migrateLocalToCloud(List<Todo> localTodos, String userId) async {
    try {
      // Add each local todo to cloud storage
      for (final todo in localTodos) {
        // Update the userId for cloud storage
        final cloudTodo = todo.copyWith(userId: userId);
        await _storage!.addTodo(cloudTodo.text);
      }
      
      // Clear local storage after successful migration
      final localService = LocalTodoService();
      await localService.clearAllTodos();
      await localService.dispose();
      
      debugPrint('Successfully migrated ${localTodos.length} todos to cloud');
    } catch (e) {
      debugPrint('Error during migration: $e');
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _storage?.dispose();
    super.dispose();
  }
} 