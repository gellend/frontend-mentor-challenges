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

  // Define header heights
  final double _mobileHeaderHeight = 200.0;
  final double _desktopHeaderHeight = 300.0;
  final double _inputCardOverlap = 50.0; // How much the input card should visually overlap the header bottom

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
          .clear();
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

  void _onReorder(int oldIndex, int newIndex) {
    // This logic handles reordering within the _filtered_ list and
    // then reconstructs _allTodos to reflect this new global order.
    // It prioritizes the order of items visible in the filter.

    List<QueryDocumentSnapshot<Todo>> currentFilteredList = _getFilteredTodos();

    // Adjust newIndex for items moved downwards
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final QueryDocumentSnapshot<Todo> movedItem = currentFilteredList.removeAt(oldIndex);
    currentFilteredList.insert(newIndex, movedItem);

    // Create a map of ID to new order for items in the reordered filtered list
    final Map<String, int> filteredOrderMap = {};
    for (int i = 0; i < currentFilteredList.length; i++) {
      filteredOrderMap[currentFilteredList[i].id] = i;
    }

    // Sort _allTodos: items in the filtered list come first (in their new order),
    // followed by items not in the filtered list (maintaining their relative order).
    _allTodos.sort((aDoc, bDoc) {
      final bool aInFiltered = filteredOrderMap.containsKey(aDoc.id);
      final bool bInFiltered = filteredOrderMap.containsKey(bDoc.id);

      if (aInFiltered && bInFiltered) {
        return filteredOrderMap[aDoc.id]!.compareTo(filteredOrderMap[bDoc.id]!);
      } else if (aInFiltered) {
        return -1; // a comes before b
      } else if (bInFiltered) {
        return 1;  // b comes before a
      } else {
        // Both not in filtered, maintain original relative order by orderIndex
        return aDoc.data().orderIndex.compareTo(bDoc.data().orderIndex);
      }
    });

    // Update Firestore with the new global order of _allTodos
    if (_currentUser != null) {
      _todoService.updateTodoOrder(_allTodos).catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating order: $e')),
          );
        }
      });
    }
    setState(() {}); // Rebuild UI to reflect the new order locally immediately
  }

  Widget _buildFilterButton(BuildContext context, TodoFilter filter, String text) {
    final theme = Theme.of(context);
    final bool isActive = _activeFilter == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Add some spacing between filter buttons
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Reduce padding for smaller buttons
          minimumSize: Size.zero, // Allow button to be smaller
        ),
        onPressed: () {
          setState(() {
            _activeFilter = filter;
          });
        },
        child: Text(
          text,
          style: bodyTextStyle.copyWith(
            fontSize: 14,
            color: isActive ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 700; // Adjusted breakpoint for more distinct desktop view

    final double headerHeight = isDesktop ? _desktopHeaderHeight : _mobileHeaderHeight;
    // Calculate padding for the main content area to position input field correctly
    final double mainContentPaddingTop = headerHeight - _inputCardOverlap;

    String backgroundImage;
    if (themeProvider.isDarkMode) {
      backgroundImage = isDesktop ? 'assets/images/bg-desktop-dark.jpg' : 'assets/images/bg-mobile-dark.jpg';
    } else {
      backgroundImage = isDesktop ? 'assets/images/bg-desktop-light.jpg' : 'assets/images/bg-mobile-light.jpg';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Text(widget.title, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, letterSpacing: isDesktop ? 8 : 4)), // Added letter spacing for TODO title
              backgroundColor: Colors.transparent, 
              elevation: 0, 
              actions: [
                IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
                    color: Colors.white, 
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme(!themeProvider.isDarkMode);
                  },
                  tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: mainContentPaddingTop > 0 ? mainContentPaddingTop : 0), 
            child: Column(
              children: <Widget>[
                Padding(
                  // Horizontal padding for the input card and list items
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Material(
                    elevation: 6.0, // Slightly increased elevation for more depth
                    borderRadius: BorderRadius.circular(8.0),
                    color: theme.colorScheme.surface, // Background for the input field card area
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Padding inside the card for the textfield
                      child: TextField(
                        controller: _newTodoController,
                        decoration: InputDecoration(
                          hintText: 'Create a new todo...', // Updated hint
                          hintStyle: bodyTextStyle.copyWith(fontSize: 16, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
                          border: InputBorder.none, // No border inside the card
                        ),
                        style: bodyTextStyle.copyWith(fontSize: 16, color: theme.colorScheme.onSurface),
                        onSubmitted: (value) => _addTodoItem(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Space between input card and list/filter card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Material(
                       elevation: 6.0,
                       borderRadius: BorderRadius.circular(8.0),
                       color: theme.colorScheme.surface,
                       clipBehavior: Clip.antiAlias, // Ensures ListView respects border radius
                       child: _currentUser == null
                          ? const Center(child: Text('User not logged in.')) 
                          : StreamBuilder<QuerySnapshot<Todo>>(
                              stream: _todoService.getTodosStream(_currentUser!.uid),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: SelectableText('Error: ${snapshot.error}')));
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                     return const Center(child: CircularProgressIndicator());
                                  }
                                }
                                if (snapshot.hasData) {
                                  _allTodos = snapshot.data!.docs;
                                } else {
                                  _allTodos = [];
                                }
                                final filteredTodos = _getFilteredTodos();
                                if (_allTodos.isEmpty) { // Simplified condition for empty list
                                  return Center(child: Text('No todos yet. Add some!', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)));
                                }
                                // If filter results in empty but there are todos, show different message or just empty list
                                // For now, ListView will handle empty filteredTodos by showing nothing if itemCount is 0.

                                return Column(
                                  children: [
                                    Expanded(
                                      child: ReorderableListView.builder(
                                        buildDefaultDragHandles: false,
                                        padding: const EdgeInsets.only(top:8.0),
                                        itemCount: filteredTodos.length,
                                        itemBuilder: (context, index) {
                                          final todoDoc = filteredTodos[index];
                                          final todo = todoDoc.data();
                                          final todoId = todoDoc.id;
                                          return Column(
                                            key: ValueKey(todoId), // Important for ReorderableListView
                                            children: [
                                              TodoItemWidget(
                                                todo: todo,
                                                itemIndex: index,
                                                onStatusChanged: (isCompleted) {
                                                  if (isCompleted != null) {
                                                    _todoService.updateTodoStatus(todoId, isCompleted);
                                                  }
                                                },
                                                onDelete: () {_todoService.deleteTodo(todoId);},
                                              ),
                                              if (index < filteredTodos.length - 1) // Add divider except for the last item
                                                Divider(
                                                  height: 1, 
                                                  thickness: 1, 
                                                  color: theme.dividerColor.withOpacity(0.5),
                                                  indent: 20, // Match TodoItemWidget horizontal padding
                                                  endIndent: 20, // Match TodoItemWidget horizontal padding
                                                ),
                                            ],
                                          );
                                        },
                                        onReorder: _onReorder,
                                      ),
                                    ),
                                    // Filter and Clear Actions Bar (Now inside the Material card)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('${_getActiveItemsCount()} items left', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                          // Responsive filter buttons for Desktop
                                          if (isDesktop)
                                            Row(
                                              children: <Widget>[
                                                _buildFilterButton(context, TodoFilter.all, 'All'),
                                                _buildFilterButton(context, TodoFilter.active, 'Active'),
                                                _buildFilterButton(context, TodoFilter.completed, 'Completed'),
                                              ],
                                            ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                              minimumSize: Size.zero,
                                            ),
                                            onPressed: () async { 
                                              if (_currentUser != null) {
                                                await _todoService.clearCompletedTodos(_currentUser!.uid);
                                              }
                                            },
                                            child: Text('Clear Completed', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                    ),
                  ),
                ),
                // Mobile specific filter bar (shown below the main list card)
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0), // Add padding: top 16, bottom 0
                    child: Material(
                      elevation: 6.0,
                      borderRadius: BorderRadius.circular(8.0),
                      color: theme.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding inside the mobile filter card
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _buildFilterButton(context, TodoFilter.all, 'All'),
                            _buildFilterButton(context, TodoFilter.active, 'Active'),
                            _buildFilterButton(context, TodoFilter.completed, 'Completed'),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Drag and drop hint text
                if (_allTodos.isNotEmpty) // Show hint only if there are todos
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: Text(
                      'Drag and drop to reorder list',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                 const SizedBox(height: 20), // Adjusted bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }
}
