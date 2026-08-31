import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class CalculatorState {
  final String display;
  final String buffer;
  final String operator;
  final bool shouldClear;
  final List<HistoryItem> history;

  CalculatorState({
    this.display = '0',
    this.buffer = '',
    this.operator = '',
    this.shouldClear = false,
    this.history = const [],
  });

  CalculatorState copyWith({
    String? display,
    String? buffer,
    String? operator,
    bool? shouldClear,
    List<HistoryItem>? history,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      buffer: buffer ?? this.buffer,
      operator: operator ?? this.operator,
      shouldClear: shouldClear ?? this.shouldClear,
      history: history ?? this.history,
    );
  }
}

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier();
});

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(CalculatorState()) {
    _loadHistory();
  }

  // --- Persistencia ---
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('calc_history');
    if (historyString != null) {
      final List<dynamic> decoded = jsonDecode(historyString);
      final history = decoded.map((e) => HistoryItem.fromJson(e)).toList();
      state = state.copyWith(history: history);
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(state.history.map((e) => e.toJson()).toList());
    await prefs.setString('calc_history', historyJson);
  }

  void clearHistory() async {
    state = state.copyWith(history: []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('calc_history');
  }

  // --- Lógica de la Calculadora ---

  void addNumber(String number) {
    if (state.display == 'Error') {
      state = state.copyWith(display: number, buffer: '', operator: '', shouldClear: false);
      return;
    }

    if (state.shouldClear) {
      // Si debía limpiar (ej: después de un operador o resultado), reemplaza el número
      state = state.copyWith(display: number, shouldClear: false);
    } else {
      if (state.display == '0' && number != '.') {
        state = state.copyWith(display: number);
      } else {
        if (state.display.length < 15) {
          state = state.copyWith(display: state.display + number);
        }
      }
    }
  }

  void addDecimal() {
    if (state.shouldClear || state.display == 'Error') {
      state = state.copyWith(display: '0.', shouldClear: false);
    } else if (!state.display.contains('.')) {
      state = state.copyWith(display: '${state.display}.');
    }
  }

  void toggleSign() {
    if (state.display == 'Error' || state.display == '0') return;
    if (state.display.startsWith('-')) {
      state = state.copyWith(display: state.display.substring(1));
    } else {
      state = state.copyWith(display: '-${state.display}');
    }
  }

  // Lógica de Porcentaje corregida profesionalmente según requerimiento
  void applyPercent() {
    if (state.display == 'Error') return;

    try {
      final double currentValue = double.parse(state.display);
      double result;

      // Verificamos si hay una operación en curso (ej: 700 x ... o 50 / ...)
      if (state.buffer.isNotEmpty && state.operator.isNotEmpty) {

        // UNIFICACIÓN DE LÓGICA:
        // Tanto para (+, -) como para (x, /), el usuario requiere que el porcentaje
        // se calcule relativo al número anterior (buffer).
        // Ej: 700 x 50% -> El 50% de 700 es 350. (Luego se hará 700 x 350)
        // Ej: 50 / 20% -> El 20% de 50 es 10. (Luego se hará 50 / 10)

        final double bufferValue = double.parse(state.buffer);
        result = bufferValue * (currentValue / 100);

      } else {
        // Si NO hay operación pendiente (solo se escribió un número y se dio %),
        // simplemente convertimos a decimal. Ej: 50% -> 0.5
        result = currentValue / 100;
      }

      state = state.copyWith(
          display: _formatResult(result),
          // IMPORTANTE: Mantenemos shouldClear true para permitir corrección inmediata
          // si el usuario se equivocó, pero el valor ya está listo para usarse con '='
          shouldClear: true
      );
    } catch (e) {
      state = state.copyWith(display: 'Error', shouldClear: true);
    }
  }

  void setOperator(String op) {
    if (state.display == 'Error') return;

    // Calcular operación pendiente si existe (encadenamiento: 5+5+...)
    if (state.operator.isNotEmpty && !state.shouldClear) {
      calculate();
      if (state.display == 'Error') return;
    }

    state = state.copyWith(
      buffer: state.display,
      operator: op,
      shouldClear: true,
    );
  }

  void calculate() {
    if (state.operator.isEmpty) return;

    double num1;
    double num2;

    try {
      // Si el buffer está vacío (raro), usamos el display
      num1 = state.buffer.isNotEmpty ? double.parse(state.buffer) : double.parse(state.display);
      num2 = double.parse(state.display);
    } catch (e) {
      state = state.copyWith(display: 'Error', shouldClear: true);
      return;
    }

    double result = 0.0;
    bool isError = false;

    switch (state.operator) {
      case '+': result = num1 + num2; break;
      case '-': result = num1 - num2; break;
      case 'x': result = num1 * num2; break;
      case '/':
        if (num2 == 0) {
          isError = true;
        } else {
          result = num1 / num2;
        }
        break;
    }

    if (isError) {
      state = state.copyWith(display: 'Error', buffer: '', operator: '', shouldClear: true);
      return;
    }

    final String resultString = _formatResult(result);

    // Guardar historial
    final newItem = HistoryItem(
      operation: '${_formatResult(num1)} ${state.operator} ${_formatResult(num2)} =',
      result: resultString,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      display: resultString,
      operator: '',
      buffer: '', // Limpiamos buffer tras calcular
      shouldClear: true,
      history: [newItem, ...state.history],
    );
    _saveHistory();
  }

  String _formatResult(double result) {
    if (result.isInfinite || result.isNaN) return 'Error';

    // Si es entero, mostrar sin decimales
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    // Si tiene decimales, limitar y limpiar ceros a la derecha
    return result.toStringAsFixed(8).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  void clear() {
    state = state.copyWith(
      display: '0',
      buffer: '',
      operator: '',
      shouldClear: false,
    );
  }

  void deleteDigit() {
    if (state.display == 'Error' || state.shouldClear) {
      clear();
      return;
    }
    if (state.display.length > 1) {
      // Manejar borrado de números negativos (ej: -5 -> borras 5 -> queda 0, no solo -)
      if (state.display.length == 2 && state.display.startsWith('-')) {
        state = state.copyWith(display: '0');
      } else {
        state = state.copyWith(display: state.display.substring(0, state.display.length - 1));
      }
    } else {
      state = state.copyWith(display: '0');
    }
  }
}