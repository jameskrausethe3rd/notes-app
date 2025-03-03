import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String labelText;
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final FocusNode _focusNode = FocusNode();

  CustomAlertDialog({
    super.key,
    required this.title,
    required this.labelText,
    required this.controller,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // Request focus when the dialog is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        focusNode: _focusNode,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).colorScheme.inversePrimary,
        decoration: InputDecoration(
          labelText: labelText,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.inversePrimary,
              width: 2.0,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 2.0,
            ),
          ),
        ),
        onSubmitted: (_) => onSubmit(), // Trigger submit action on Enter key
      ),
      actions: [
        MaterialButton(
          onPressed: onCancel,
          child: const Text("Cancel"),
        ),
        MaterialButton(
          onPressed: onSubmit,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
