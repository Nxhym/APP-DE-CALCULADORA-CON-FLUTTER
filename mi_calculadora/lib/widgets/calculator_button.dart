import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final int flex;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0), // Más espacio entre botones
        child: Semantics(
          button: true,
          label: label,
          child: Material(
            color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28), // Bordes más redondeados
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: textColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}