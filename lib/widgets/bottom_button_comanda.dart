import 'package:flutter/material.dart';
import 'div.dart';

class BottomButtonComanda extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  const BottomButtonComanda(this.icon, this.text, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Div(
            circular: true,
            background: isDisabled
                ? Colors.grey.shade700 // color apagado si está desactivado
                : Theme.of(context).primaryColor,
            width: 55,
            height: 55,
            child: Icon(
              icon,
              size: 32,
              color: isDisabled ? Colors.grey.shade400 : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            color: isDisabled ? Colors.grey.shade400 : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
