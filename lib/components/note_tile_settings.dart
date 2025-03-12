import 'package:flutter/material.dart';

class NoteTileSettings extends StatelessWidget {
  final void Function()? onEditTap;
  final void Function()? onDeleteTap;
  final void Function()? onHiddenTap;

  const NoteTileSettings({super.key, required this.onEditTap, required this.onDeleteTap, required this.onHiddenTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Edit
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onEditTap!();
          },
          child: Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                "Edit", 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
          )
        ),

        // Hide
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onHiddenTap!();
          },
          child: Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                "Hide", 
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
          )
        ),

        // Delete
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            onDeleteTap!();
          },
          child: Container(
            height: 50,
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Text(
                "Delete", 
                style: TextStyle(
                  color: Colors.red, 
                  fontWeight: FontWeight.bold
                )
              )
            ),
          )
        ),
      ],
    );
  }
}