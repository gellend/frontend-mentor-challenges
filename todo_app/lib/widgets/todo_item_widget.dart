import 'package:flutter/material.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/constants/colors.dart'; // Import custom colors
import 'package:todo_app/constants/text_styles.dart'; // Import custom text styles

class TodoItemWidget extends StatefulWidget {
  final Todo todo;
  final Function(bool?) onStatusChanged; // Callback for checkbox change
  final Function() onDelete; // Callback for delete action
  final int itemIndex; // Index of the item in the list for ReorderableDragStartListener

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onStatusChanged,
    required this.onDelete,
    required this.itemIndex,
  });

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 700; // Consistent breakpoint with TodoScreen

    // Define colors based on theme and todo status
    Color textColor = widget.todo.isCompleted
        ? (isDarkMode ? darkDarkGrayishBlue : lightDarkGrayishBlue)
        : (isDarkMode ? darkLightGrayishBlue : theme.colorScheme.onSurface);
    
    Color circleColor = widget.todo.isCompleted 
        ? Colors.transparent // No fill when completed, gradient border will show
        : (isDarkMode ? darkVeryDarkDesaturatedBlue : lightVeryLightGrayishBlue); // inner circle color when not completed

    bool showInteractiveElements = !isDesktop || (isDesktop && _isHovered);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => widget.onStatusChanged(!widget.todo.isCompleted), // Toggle status on tap of the whole item
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Reduced vertical padding slightly
          child: Row(
            children: <Widget>[
              // Custom Checkbox
              GestureDetector(
                onTap: () => widget.onStatusChanged(!widget.todo.isCompleted),
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.todo.isCompleted 
                      ? const LinearGradient(
                          colors: [gradientStart, gradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ) 
                      : null, // No gradient if not completed
                    color: circleColor, // Inner circle color when not completed or transparent for gradient
                    border: Border.all(
                      color: widget.todo.isCompleted 
                        ? Colors.transparent // No border when gradient is shown
                        : (isDarkMode ? darkVeryDarkGrayishBlue : lightLightGrayishBlue),
                      width: 1.5,
                    ),
                  ),
                  child: widget.todo.isCompleted
                      ? const Icon(Icons.check, size: 16.0, color: Colors.white)
                      : null, // No icon if not completed
                ),
              ),
              const SizedBox(width: 16.0), // Spacing between checkbox and text
              // Todo Text
              Expanded(
                child: Text(
                  widget.todo.text,
                  style: bodyTextStyle.copyWith(
                    color: textColor,
                    decoration: widget.todo.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: textColor, // Match line-through color with text color
                  ),
                ),
              ),
              const SizedBox(width: 8.0), // Spacing between text and interactive icons
              // Interactive icons (Delete and Drag Handle)
              if (showInteractiveElements)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: isDarkMode ? darkDarkGrayishBlue : lightDarkGrayishBlue, size: 20),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete Todo',
                      padding: const EdgeInsets.all(4), // Adjust padding
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4), // Space between delete and drag handle
                    ReorderableDragStartListener(
                      index: widget.itemIndex,
                      child: Icon(Icons.drag_handle, color: isDarkMode ? darkDarkGrayishBlue : lightDarkGrayishBlue, size: 22),
                    ),
                  ],
                )
              else
                // Placeholder to maintain layout when icons are hidden on desktop (no hover)
                // Width should roughly match the combined width of the two icons and spacing
                const SizedBox(width: 48 + 4 + 22), // Approx: IconButton(48) + SizedBox(4) + Icon(22)
            ],
          ),
        ),
      ),
    );
  }
} 