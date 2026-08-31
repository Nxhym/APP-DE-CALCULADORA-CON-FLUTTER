import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_button.dart';
import '../widgets/responsive_layout.dart';
import 'history_screen.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobileBody: const _CalculatorLayout(),
      tabletBody: Row(
        children: const [
          Expanded(flex: 3, child: _CalculatorLayout()),
          VerticalDivider(width: 1),
          Expanded(flex: 2, child: HistoryScreen()),
        ],
      ),
    );
  }
}

class _CalculatorLayout extends ConsumerWidget {
  const _CalculatorLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final theme = Theme.of(context);

    // Definición de colores
    final opColor = theme.colorScheme.secondaryContainer;
    final opTextColor = theme.colorScheme.onSecondaryContainer;
    final actionColor = theme.colorScheme.tertiaryContainer;
    final actionTextColor = theme.colorScheme.onTertiaryContainer;
    final errorColor = theme.colorScheme.errorContainer;
    final errorTextColor = theme.colorScheme.onErrorContainer;

    return Column(
      children: [
        // --- PANTALLA ---
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Texto pequeño de operación en curso
                Text(
                  (state.buffer.isNotEmpty && state.operator.isNotEmpty)
                      ? '${state.buffer} ${state.operator}'
                      : '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                // Resultado principal
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    state.display,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: state.display == 'Error' ? theme.colorScheme.error : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        // --- TECLADO ---
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Fila 1
                Expanded(
                  child: Row(
                    children: [
                      CalculatorButton(
                        label: 'C',
                        onTap: notifier.clear,
                        backgroundColor: errorColor,
                        textColor: errorTextColor,
                      ),
                      CalculatorButton(
                        label: '+/-',
                        onTap: notifier.toggleSign, // Cambio de signo
                        backgroundColor: actionColor,
                        textColor: actionTextColor,
                      ),
                      CalculatorButton(
                        label: '%',
                        onTap: notifier.applyPercent,
                        backgroundColor: actionColor,
                        textColor: actionTextColor,
                      ),
                      CalculatorButton(
                        label: '/',
                        onTap: () => notifier.setOperator('/'),
                        backgroundColor: opColor,
                        textColor: opTextColor,
                      ),
                    ],
                  ),
                ),
                // Fila 2
                Expanded(
                  child: Row(
                    children: [
                      CalculatorButton(label: '7', onTap: () => notifier.addNumber('7')),
                      CalculatorButton(label: '8', onTap: () => notifier.addNumber('8')),
                      CalculatorButton(label: '9', onTap: () => notifier.addNumber('9')),
                      CalculatorButton(
                        label: 'x',
                        onTap: () => notifier.setOperator('x'),
                        backgroundColor: opColor,
                        textColor: opTextColor,
                      ),
                    ],
                  ),
                ),
                // Fila 3
                Expanded(
                  child: Row(
                    children: [
                      CalculatorButton(label: '4', onTap: () => notifier.addNumber('4')),
                      CalculatorButton(label: '5', onTap: () => notifier.addNumber('5')),
                      CalculatorButton(label: '6', onTap: () => notifier.addNumber('6')),
                      CalculatorButton(
                        label: '-',
                        onTap: () => notifier.setOperator('-'),
                        backgroundColor: opColor,
                        textColor: opTextColor,
                      ),
                    ],
                  ),
                ),
                // Fila 4
                Expanded(
                  child: Row(
                    children: [
                      CalculatorButton(label: '1', onTap: () => notifier.addNumber('1')),
                      CalculatorButton(label: '2', onTap: () => notifier.addNumber('2')),
                      CalculatorButton(label: '3', onTap: () => notifier.addNumber('3')),
                      CalculatorButton(
                        label: '+',
                        onTap: () => notifier.setOperator('+'),
                        backgroundColor: opColor,
                        textColor: opTextColor,
                      ),
                    ],
                  ),
                ),
                // Fila 5
                Expanded(
                  child: Row(
                    children: [
                      CalculatorButton(label: '0', onTap: () => notifier.addNumber('0')),
                      CalculatorButton(label: '.', onTap: notifier.addDecimal),
                      // Botón de borrar carácter (Backspace)
                      CalculatorButton(
                        label: '⌫',
                        onTap: notifier.deleteDigit,
                        backgroundColor: actionColor,
                        textColor: actionTextColor,
                      ),
                      CalculatorButton(
                        label: '=',
                        onTap: notifier.calculate,
                        backgroundColor: theme.colorScheme.primary,
                        textColor: theme.colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}