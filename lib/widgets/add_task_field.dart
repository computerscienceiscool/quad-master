import 'package:flutter/material.dart';

class AddTaskField extends StatefulWidget {
  final Function(String) onAdd;
  final VoidCallback? onTemplateTap;

  const AddTaskField({
    super.key,
    required this.onAdd,
    this.onTemplateTap,
  });

  @override
  State<AddTaskField> createState() => _AddTaskFieldState();
}

class _AddTaskFieldState extends State<AddTaskField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: _isExpanded
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Enter task name...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: _submitTask,
                  ),
                ),
                if (widget.onTemplateTap != null)
                  IconButton(
                    icon: const Icon(Icons.library_books, size: 20),
                    onPressed: () {
                      _collapse();
                      widget.onTemplateTap!();
                    },
                    tooltip: 'Templates',
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _collapse,
                  tooltip: 'Cancel',
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _submitTask(_controller.text),
                  tooltip: 'Add',
                ),
              ],
            )
          : GestureDetector(
              onTap: _expand,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'add new',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  if (widget.onTemplateTap != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onTemplateTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.library_books,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'templates',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  void _expand() {
    setState(() => _isExpanded = true);
    _focusNode.requestFocus();
  }

  void _collapse() {
    setState(() => _isExpanded = false);
    _controller.clear();
    _focusNode.unfocus();
  }

  void _submitTask(String value) {
    final name = value.trim();
    if (name.isNotEmpty) {
      widget.onAdd(name);
      _controller.clear();
      // Keep expanded for adding more tasks
      _focusNode.requestFocus();
    }
  }
}
