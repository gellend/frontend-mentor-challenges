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
  // bool _isLoadingInitialTodos = true; // To handle initial loading state more explicitly if needed

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    // if (_currentUser != null) {
    //   _todoService.getTodosStream(_currentUser!.uid).first.then((_) {
    //     if (mounted) {
    //       setState(() {
    //         _isLoadingInitialTodos = false;
    //       });
    //     }
    //   });
    // }
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
                        // Handle initial loading explicitly if stream is slow to emit first value
                        // if (_isLoadingInitialTodos && snapshot.connectionState == ConnectionState.waiting) {
                        //   return const Center(child: CircularProgressIndicator());
                        // }

                        if (snapshot.hasError) {
                          // if (_isLoadingInitialTodos && mounted) setState(() => _isLoadingInitialTodos = false);
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                16.0,
                              ), // Tambahkan padding agar mudah dibaca
                              child: SelectableText('Error: ${snapshot.error}'),
                            ),
                          );
                        }

                        // Important: Check for ConnectionState.waiting AFTER checking for error
                        // This ensures that an error state is shown even if waiting for new data.
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Only show loading if there's no data yet (first load)
                          // or if specifically desired during re-fetches (less common for Firestore streams)
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            // Check if _isLoadingInitialTodos is true if you use that flag
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          // If we have data already, just show the list while waiting for update
                        }

                        // if (_isLoadingInitialTodos && mounted) setState(() => _isLoadingInitialTodos = false);

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No todos yet. Add some!',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        final todos = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 16.0,
                          ), // Padding for the list
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index].data();
                            final todoId = todos[index].id;
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
          // TODO: Add filter and clear completed buttons area if needed based on design
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
