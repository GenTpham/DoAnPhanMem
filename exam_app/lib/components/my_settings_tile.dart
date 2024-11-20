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
        color: const Color(0xFF3572EF),  
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(
        left: 25,
        right: 25,
        top: 10,
      ),
      padding: const EdgeInsets.all(25),  
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tile,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,  
            ),
          ),
          IconTheme(
            data: const IconThemeData(
              color: Colors.white, 
            ),
            child: action, 
          ),
        ],
      ),
    );
  }
}
