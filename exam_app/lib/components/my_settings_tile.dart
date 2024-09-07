import 'package:flutter/material.dart';

class MySettingsTile extends StatelessWidget {
  final String tile;
  final Widget action;
  const MySettingsTile({
    super.key,
    required this.tile,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(
        left: 25,
        right: 25,
        top: 10,
      ),
      // Padding inside
      padding: const EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tile,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          action,
        ],
      ),
    );
  }
}
