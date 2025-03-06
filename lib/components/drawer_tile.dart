import 'package:flutter/material.dart';
import 'package:notes_app/components/drawer_tile_settings.dart';
import 'package:popover/popover.dart';

class DrawerTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final VoidCallback onTap;
  final TextEditingController controller;
  final Future<void> Function() onEditTap;
  final Future<void> Function() onDeleteTap;

  const DrawerTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
    required this.controller,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: ListTile(
        leading: Icon(leadingIcon),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
        trailing: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => showPopover(
                width: 100,
                height: 100,
                backgroundColor: Theme.of(context).colorScheme.surface,
                context: context,
                bodyBuilder: (context) => DrawerTileSettings(
                  onEditTap: onEditTap,
                  onDeleteTap: onDeleteTap,
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}