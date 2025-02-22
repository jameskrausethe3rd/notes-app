import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/models/database_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          // Dark Mode
          Text(
            "Dark Mode",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
        
          // Switch
          CupertinoSwitch(
            value: Provider.of<DatabaseService>(context, listen: false).isDarkModeEnabled, 
            onChanged: (value) => Provider.of<DatabaseService>(context, listen: false).toggleDarkMode(),
            )
        ],),
      )
    );
  }
}