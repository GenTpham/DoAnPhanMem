import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;
  final Color? textColor; 
  
  const MyDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor, 
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? const Color(0xFF3572EF);

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: color, 
        ),
      ),
      leading: Icon(
        icon,
        color: color, 
      ),
      onTap: onTap,
    );
  }
}

