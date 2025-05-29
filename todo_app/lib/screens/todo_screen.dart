import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/providers/todo_service_provider.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/screens/auth_screen.dart';
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
  final TextEditingController _newTodoController =
      TextEditingController(); // Controller for new todo input

  TodoFilter _activeFilter = TodoFilter.all; // State for active filter
  List<Todo> _allTodos = [];

  // Define header heights
  final double _mobileHeaderHeight = 200.0;
  final double _desktopHeaderHeight = 300.0;
  // final double _inputCardOverlap = 100.0; // Adjusted overlap

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newTodoController.dispose(); // Dispose controller
    super.dispose();
  }

  Future<void> _addTodoItem() async {
    final String text = _newTodoController.text.trim();
    if (text.isEmpty) {
      if (mounted) {
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
      final todoServiceProvider = Provider.of<TodoServiceProvider>(context, listen: false);
      await todoServiceProvider.storage.addTodo(text);
      _newTodoController.clear();
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
  List<Todo> _getFilteredTodos() {
    if (_activeFilter == TodoFilter.active) {
      return _allTodos.where((todo) => !todo.isCompleted).toList();
    }
    if (_activeFilter == TodoFilter.completed) {
      return _allTodos.where((todo) => todo.isCompleted).toList();
    }
    return _allTodos; // TodoFilter.all
  }

  int _getActiveItemsCount() {
    return _allTodos.where((todo) => !todo.isCompleted).length;
  }

  void _onReorder(int oldIndex, int newIndex) {
    List<Todo> currentFilteredList = _getFilteredTodos();

    // Adjust newIndex for items moved downwards
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final Todo movedItem = currentFilteredList.removeAt(oldIndex);
    currentFilteredList.insert(newIndex, movedItem);

    // Create a map of ID to new order for items in the reordered filtered list
    final Map<String, int> filteredOrderMap = {};
    for (int i = 0; i < currentFilteredList.length; i++) {
      filteredOrderMap[currentFilteredList[i].id!] = i;
    }

    // Sort _allTodos: items in the filtered list come first (in their new order),
    // followed by items not in the filtered list (maintaining their relative order).
    _allTodos.sort((a, b) {
      final bool aInFiltered = filteredOrderMap.containsKey(a.id);
      final bool bInFiltered = filteredOrderMap.containsKey(b.id);

      if (aInFiltered && bInFiltered) {
        return filteredOrderMap[a.id]!.compareTo(filteredOrderMap[b.id]!);
      } else if (aInFiltered) {
        return -1; // a comes before b
      } else if (bInFiltered) {
        return 1;  // b comes before a
      } else {
        // Both not in filtered, maintain original relative order by orderIndex
        return a.orderIndex.compareTo(b.orderIndex);
      }
    });

    // Update storage with the new global order of _allTodos
    final todoServiceProvider = Provider.of<TodoServiceProvider>(context, listen: false);
    todoServiceProvider.storage.updateTodoOrder(_allTodos).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order: $e')),
        );
      }
    });
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

  Widget _buildStorageStatusChip(bool isCloudMode, bool isMigrating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isMigrating 
            ? Colors.orange.withValues(alpha: 0.8)
            : isCloudMode 
                ? Colors.green.withValues(alpha: 0.8) 
                : Colors.blue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        isMigrating 
            ? 'Syncing...'
            : isCloudMode 
                ? 'Cloud Sync' 
                : 'Local Only',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAuthOptions() {
    final currentUser = _authService.currentUser;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentUser == null) ...[
              const Text(
                'Sign in to sync your todos across devices',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
                child: const Text('Sign In / Sign Up'),
              ),
            ] else ...[
              Text(
                'Signed in as ${currentUser.email}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _authService.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Sign Out'),
              ),
            ],
            const SizedBox(height: 16),
          ],
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
    
    // Padding from the top of the screen to the start of the "TODO" title row
    final double titleRowTopPadding = isDesktop ? 70.0 : 50.0; 
    // Space between "TODO" title row and the TextField
    final double spaceBetweenTitleAndInput = isDesktop ? 35.0 : 25.0; 
    // Space between TextField and the Todo List card
    final double spaceBetweenInputAndList = 24.0;

    String backgroundImage;
    if (themeProvider.isDarkMode) {
      backgroundImage = isDesktop ? 'assets/images/bg-desktop-dark.jpg' : 'assets/images/bg-mobile-dark.jpg';
    } else {
      backgroundImage = isDesktop ? 'assets/images/bg-desktop-light.jpg' : 'assets/images/bg-mobile-light.jpg';
    }

    return Consumer<TodoServiceProvider>(
      builder: (context, todoServiceProvider, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor, 
          body: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight, // This is for the background image
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),

              // Removed the old Positioned AppBar here

              // This Padding positions the main content column (Title, Input, List)
              Padding(
                padding: EdgeInsets.only(
                  top: titleRowTopPadding,
                  bottom: isDesktop ? 24.0 : 0.0, // Add bottom padding for desktop/tablet
                ), 
                child: Center( 
                  child: ConstrainedBox( 
                    constraints: const BoxConstraints(maxWidth: 550), 
                    child: Column(
                      children: <Widget>[
                        // 1. New Header Row (TODO Title and Theme Icon)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Match horizontal padding of items below
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "TODO",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 40 : 32,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: isDesktop ? 15 : 10,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildStorageStatusChip(
                                    todoServiceProvider.isCloudMode, 
                                    todoServiceProvider.isMigrating,
                                  ),
                                ],
                              ),
                              Row( // Group action icons
                                mainAxisSize: MainAxisSize.min, // So the row doesn't expand unnecessarily
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                      size: isDesktop ? 30 : 26,
                                    ),
                                    onPressed: _showAuthOptions,
                                    tooltip: 'Account Options',
                                  ),
                                  SizedBox(width: isDesktop ? 8 : 4), // Spacing between icons
                                  IconButton(
                                    icon: Icon(
                                      themeProvider.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
                                      color: Colors.white,
                                      size: isDesktop ? 30 : 26,
                                    ),
                                    onPressed: () {
                                      themeProvider.toggleTheme(!themeProvider.isDarkMode);
                                    },
                                    tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        
                        SizedBox(height: spaceBetweenTitleAndInput),

                        // 2. New Todo Input TextField
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Match horizontal padding
                          child: Material(
                            elevation: 6.0,
                            borderRadius: BorderRadius.circular(8.0),
                            color: theme.colorScheme.surface, 
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0), // Main padding for the Row, adjust as needed
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _newTodoController,
                                      decoration: InputDecoration(
                                        hintText: 'Create a new todo...',
                                        hintStyle: bodyTextStyle.copyWith(
                                          fontSize: isDesktop ? 18 : 16, 
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: isDesktop ? 20.0 : 18.0,
                                          horizontal: 20.0 // Added horizontal padding for the text start
                                        ), 
                                      ),
                                      style: bodyTextStyle.copyWith(
                                        fontSize: isDesktop ? 18 : 16, 
                                        color: theme.colorScheme.onSurface
                                      ),
                                      onSubmitted: (value) => _addTodoItem(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: spaceBetweenInputAndList),

                        // 3. Existing Todo List and Filters
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0), // This padding is for the card itself
                            child: Material(
                               elevation: 6.0,
                               borderRadius: BorderRadius.circular(8.0),
                               color: theme.colorScheme.surface,
                               clipBehavior: Clip.antiAlias, 
                               child: StreamBuilder<List<Todo>>(
                                  stream: todoServiceProvider.storage.getTodosStream(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: SelectableText('Error: ${snapshot.error}')));
                                    }
                                    
                                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    
                                    if (snapshot.hasData) {
                                      _allTodos = snapshot.data!;
                                    }
                                    
                                    final filteredTodos = _getFilteredTodos();

                                    if (_allTodos.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'No todos yet. Add some!', 
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant
                                          )
                                        )
                                      );
                                    }
                                    
                                    return Column(
                                      children: [
                                        Expanded(
                                          child: ReorderableListView.builder(
                                            buildDefaultDragHandles: false, 
                                            padding: const EdgeInsets.only(top:8.0),
                                            itemCount: filteredTodos.length,
                                            itemBuilder: (context, index) {
                                              final todo = filteredTodos[index];
                                              final todoId = todo.id!;

                                              return Column(
                                                key: ValueKey(todoId), 
                                                children: [
                                                  TodoItemWidget(
                                                    todo: todo,
                                                    itemIndex: index, 
                                                    onStatusChanged: (isCompleted) {
                                                      if (isCompleted != null) {
                                                        todoServiceProvider.storage.updateTodoStatus(todoId, isCompleted);
                                                      }
                                                    },
                                                    onDelete: () {
                                                      todoServiceProvider.storage.deleteTodo(todoId);
                                                    },
                                                  ),
                                                  if (index < filteredTodos.length - 1) 
                                                    Divider(
                                                      height: 1, 
                                                      thickness: 1, 
                                                      color: theme.dividerColor.withValues(alpha: 0.5),
                                                      indent: 20, 
                                                      endIndent: 20, 
                                                    ),
                                                ],
                                              );
                                            },
                                            onReorder: _onReorder, 
                                          ),
                                        ),
                                        // Filter and Clear Actions Bar (Inside the Material card)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Adjusted padding
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text('${_getActiveItemsCount()} items left', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                              if (isDesktop) // Show row of filters only on desktop
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
                                                  await todoServiceProvider.storage.clearCompletedTodos();
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
                        // Mobile specific filter bar (shown below the main list card if not desktop)
                        if (!isDesktop)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFilterButton(context, TodoFilter.all, 'All'),
                              _buildFilterButton(context, TodoFilter.active, 'Active'),
                              _buildFilterButton(context, TodoFilter.completed, 'Completed'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
