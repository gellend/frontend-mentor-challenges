import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user ID
import 'package:cloud_firestore/cloud_firestore.dart'; // For QuerySnapshot type
import 'package:provider/provider.dart'; // Import Provider
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/providers/theme_provider.dart'; // Import ThemeProvider
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/services/todo_service.dart';
import 'package:todo_app/widgets/todo_item_widget.dart';
import 'package:todo_app/constants/text_styles.dart';
// Import other necessary packages like TodoService, Todo model, TodoItemWidget later

// Enum for filter states
enum TodoFilter { all, active, completed }

class TodoScreen extends StatefulWidget {
  const TodoScreen({
    super.key,
    required this.title,
  }); // Title might be removed or changed

  final String title; // This might change to reflect the screen's purpose

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final AuthService _authService = AuthService();
  final TodoService _todoService = TodoService(); // Instantiate TodoService
  final TextEditingController _newTodoController =
      TextEditingController(); // Controller for new todo input

  User? _currentUser;
  TodoFilter _activeFilter = TodoFilter.all; // State for active filter
  List<QueryDocumentSnapshot<Todo>> _allTodos = []; // To store all todos for client-side filtering

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  @override
  void dispose() {
    _newTodoController.dispose(); // Dispose controller
    super.dispose();
  }

  Future<void> _addTodoItem() async {
    final String text = _newTodoController.text.trim();
    if (text.isEmpty || _currentUser == null) {
      if (text.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Todo cannot be empty.',
              style: bodyTextStyle.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }
    try {
      await _todoService.addTodo(_currentUser!.uid, text);
      _newTodoController
          .clear(); // This should work. Ensure setState is not needed if widget rebuilds due to stream.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add todo: $e',
              style: bodyTextStyle.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Helper to filter todos based on _activeFilter
  List<QueryDocumentSnapshot<Todo>> _getFilteredTodos() {
    if (_activeFilter == TodoFilter.active) {
      return _allTodos.where((doc) => !doc.data().isCompleted).toList();
    }
    if (_activeFilter == TodoFilter.completed) {
      return _allTodos.where((doc) => doc.data().isCompleted).toList();
    }
    return _allTodos; // TodoFilter.all
  }

  int _getActiveItemsCount() {
    return _allTodos.where((doc) => !doc.data().isCompleted).length;
  }

  Widget _buildFilterButton(BuildContext context, TodoFilter filter, String text) {
    final theme = Theme.of(context);
    final bool isActive = _activeFilter == filter;
    return TextButton(
      onPressed: () {
        setState(() {
          _activeFilter = filter;
        });
      },
      child: Text(
        text,
        style: bodyTextStyle.copyWith(
          fontSize: 14,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Access ThemeProvider for the toggle button icon and action
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // Note: AppBar background might need to be transparent for the background image later
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Use surface or background from theme
        title: Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white, // As per design, title is white
          ),
        ), // Example title
        backgroundColor: Colors.transparent, // To allow background image from Stack to show
        elevation: 0, // No shadow for a cleaner look with background image
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
              color: Colors.white, // As per design, icon is white
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
            tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white /* As per design, icon is white */),
            onPressed: () async {
              await _authService.signOut();
              // Navigation to AuthScreen will be handled by the StreamBuilder in main.dart
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              8.0,
            ), // Adjusted padding
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _newTodoController,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?', // Changed hint text
                      hintStyle: bodyTextStyle.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      filled: true, // To give it a background color
                      fillColor: theme.colorScheme.surface, // Background for the text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none, // No border for a cleaner look to match design
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Adjust padding
                    ),
                    style: bodyTextStyle.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    onSubmitted:
                        (value) =>
                            _addTodoItem(), // Changed to directly call for simplicity
                  ),
                ),
                // SizedBox and IconButton for add are removed as per one common design pattern (add on submit)
                // If a dedicated add button is still desired, it can be styled differently or placed elsewhere.
                // For now, focusing on main list and later styling input to match design more closely.
              ],
            ),
          ),
          Expanded(
            child:
                _currentUser == null
                    ? const Center(
                      child: Text('User not logged in.'),
                    ) // Should not happen if navigation is correct
                    : StreamBuilder<QuerySnapshot<Todo>>(
                      stream: _todoService.getTodosStream(_currentUser!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                16.0,
                              ), // Tambahkan padding agar mudah dibaca
                              child: SelectableText('Error: ${snapshot.error}'),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }

                        if (snapshot.hasData) {
                          _allTodos = snapshot.data!.docs;
                        } else {
                          _allTodos = []; // Ensure _allTodos is empty if no data
                        }

                        final filteredTodos = _getFilteredTodos();

                        if (filteredTodos.isEmpty && _allTodos.isNotEmpty && _activeFilter != TodoFilter.all) {
                          return Center(
                            child: Text(
                              'No todos match this filter.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        } else if (_allTodos.isEmpty) {
                          return Center(
                            child: Text(
                              'No todos yet. Add some!',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 16.0,
                          ), // Padding for the list
                          itemCount: filteredTodos.length,
                          itemBuilder: (context, index) {
                            final todo = filteredTodos[index].data();
                            final todoId = filteredTodos[index].id;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding to list items
                              child: TodoItemWidget(
                                todo: todo,
                                onStatusChanged: (isCompleted) {
                                  if (isCompleted != null) {
                                    _todoService.updateTodoStatus(
                                      todoId,
                                      isCompleted,
                                    );
                                  }
                                },
                                onDelete: () {
                                  // Optional: Add a confirmation dialog before deleting
                                  _todoService.deleteTodo(todoId);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
          // Filter and Clear Actions Bar
          if (_currentUser != null) // Only show if user is logged in
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // Or theme.cardColor
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2), // Shadow on top
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${_getActiveItemsCount()} items left',
                    style: bodyTextStyle.copyWith(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Row(
                    children: <Widget>[
                      _buildFilterButton(context, TodoFilter.all, 'All'),
                      _buildFilterButton(context, TodoFilter.active, 'Active'),
                      _buildFilterButton(context, TodoFilter.completed, 'Completed'),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      // Optional: Add confirmation dialog
                      await _todoService.clearCompletedTodos(_currentUser!.uid);
                    },
                    child: Text(
                      'Clear Completed',
                      style: bodyTextStyle.copyWith(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      // floatingActionButton: FloatingActionButton( // Consider if FAB is still the best UX for adding todos
      //   onPressed: () { /* TODO: Show dialog or dedicated screen to add todo */ },
      //   tooltip: 'Add Todo',
      //   backgroundColor: Theme.of(context).colorScheme.primary,
      //   child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      // ),
    );
  }
}
