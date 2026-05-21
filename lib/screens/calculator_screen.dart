import 'package:flutter/material.dart';

import '../models/history_model.dart';
import '../widgets/calc_button.dart';

class CalculatorScreen extends StatefulWidget {
  final Future<HistoryModel> Function(String expression, String result)
  onCalculated;

  const CalculatorScreen({
    super.key,
    required this.onCalculated,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  String? _leftValue;
  String _operator = '';
  bool _hasRightOperandInput = false;
  bool _isResultShown = false;
  bool _isError = false;

  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == '×' || value == '÷';
  }

  void _onKeyTap(String value) {
    setState(() {
      if (_isError && value != 'C') {
        _clearAll();
      }

      if (value == 'C') {
        _clearAll();
        return;
      }

      if (value == '⌫') {
        _handleBackspace();
        return;
      }

      if (_isOperator(value)) {
        _handleOperator(value);
        return;
      }

      if (value == '=') {
        _calculateResult();
        return;
      }

      _handleNumber(value);
    });
  }

  void _clearAll() {
    _display = '0';
    _expression = '';
    _leftValue = null;
    _operator = '';
    _hasRightOperandInput = false;
    _isResultShown = false;
    _isError = false;
  }

  void _handleBackspace() {
    if (_isResultShown || _display == '0' || _display.isEmpty) {
      return;
    }

    final updated = _display.substring(0, _display.length - 1);
    _display = updated.isEmpty ? '0' : updated;
    _expression = _buildExpressionPreview();
  }

  void _handleNumber(String value) {
    if (_isResultShown) {
      _display = '0';
      _isResultShown = false;
    }

    if (value == '.') {
      if (_display.contains('.')) {
        return;
      }
      _display = _display == '0' ? '0.' : '$_display.';
    } else {
      _display = _display == '0' ? value : '$_display$value';
    }

    if (_leftValue != null && _operator.isNotEmpty) {
      _hasRightOperandInput = true;
    }

    _expression = _buildExpressionPreview();
  }

  void _handleOperator(String nextOperator) {
    if (_isResultShown) {
      _leftValue = _display;
      _operator = nextOperator;
      _display = '0';
      _hasRightOperandInput = false;
      _isResultShown = false;
      _expression = '${_formatNumber(_leftValue!)} $_operator';
      return;
    }

    if (_leftValue == null) {
      _leftValue = _display;
      _operator = nextOperator;
      _display = '0';
      _hasRightOperandInput = false;
      _isResultShown = false;
      _expression = '${_formatNumber(_leftValue!)} $_operator';
      return;
    }

    if (!_hasRightOperandInput) {
      _operator = nextOperator;
      _expression = '${_formatNumber(_leftValue!)} $_operator';
      return;
    }

    final result = _operate(_leftValue!, _display, _operator);
    if (result == null) {
      _setDivisionByZeroError();
      return;
    }

    _leftValue = result;
    _operator = nextOperator;
    _display = '0';
    _hasRightOperandInput = false;
    _expression = '${_formatNumber(_leftValue!)} $_operator';
  }

  Future<void> _calculateResult() async {
    if (_leftValue == null || _operator.isEmpty || !_hasRightOperandInput) {
      return;
    }

    final rightValue = _display;
    final result = _operate(_leftValue!, rightValue, _operator);
    if (result == null) {
      _setDivisionByZeroError();
      return;
    }

    final expression =
        '${_formatNumber(_leftValue!)} $_operator ${_formatNumber(rightValue)}';
    final shownResult = _formatNumber(result);

    _display = shownResult;
    _expression = '$expression =';
    _leftValue = result;
    _operator = '';
    _hasRightOperandInput = false;
    _isResultShown = true;

    await widget.onCalculated(expression, shownResult);
  }

  String? _operate(String left, String right, String operatorValue) {
    final leftNumber = double.tryParse(left);
    final rightNumber = double.tryParse(right);
    if (leftNumber == null || rightNumber == null) {
      return null;
    }

    switch (operatorValue) {
      case '+':
        return (leftNumber + rightNumber).toString();
      case '-':
        return (leftNumber - rightNumber).toString();
      case '×':
        return (leftNumber * rightNumber).toString();
      case '÷':
        if (rightNumber == 0) {
          return null;
        }
        return (leftNumber / rightNumber).toString();
      default:
        return null;
    }
  }

  void _setDivisionByZeroError() {
    _display = 'Error';
    _expression = 'Tidak bisa membagi dengan nol';
    _leftValue = null;
    _operator = '';
    _hasRightOperandInput = false;
    _isError = true;
    _isResultShown = false;
  }

  String _formatNumber(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return value;
    }

    if (parsed == parsed.truncateToDouble()) {
      return parsed.toInt().toString();
    }

    return parsed.toString();
  }

  String _buildExpressionPreview() {
    if (_leftValue == null || _operator.isEmpty) {
      return '';
    }

    return '${_formatNumber(_leftValue!)} $_operator ${_formatNumber(_display)}';
  }

  Color _buttonColor(String label) {
    if (label == 'C') {
      return const Color(0xFFE65100);
    }
    if (label == '=') {
      return const Color(0xFF2E7D32);
    }
    if (label == '⌫' || _isOperator(label)) {
      return Theme.of(context).colorScheme.primary;
    }
    return const Color(0xFF1F2937);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonFont = (size.width * 0.06).clamp(18.0, 28.0);
    final displayFont = (size.width * 0.12).clamp(34.0, 56.0);
    final exprFont = (size.width * 0.05).clamp(16.0, 24.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 480,
          minWidth: 280,
          maxHeight: double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Card(
                elevation: 1,
                color: Colors.white,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _expression,
                          style: TextStyle(
                            fontSize: exprFont,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _display,
                          style: TextStyle(
                            fontSize: displayFont,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonHeight = (constraints.maxHeight / 5).clamp(
                      52.0,
                      94.0,
                    );

                    Widget buildRow(List<Widget> children) {
                      return SizedBox(
                        height: buttonHeight,
                        child: Row(children: children),
                      );
                    }

                    Widget buildExpandedButton(String label) {
                      return Expanded(
                        child: CalcButton(
                          label: label,
                          backgroundColor: _buttonColor(label),
                          foregroundColor: Colors.white,
                          fontSize: buttonFont,
                          onTap: () => _onKeyTap(label),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          buildRow([
                            buildExpandedButton('C'),
                            buildExpandedButton('⌫'),
                            buildExpandedButton('÷'),
                            buildExpandedButton('×'),
                          ]),
                          buildRow([
                            buildExpandedButton('7'),
                            buildExpandedButton('8'),
                            buildExpandedButton('9'),
                            buildExpandedButton('-'),
                          ]),
                          buildRow([
                            buildExpandedButton('4'),
                            buildExpandedButton('5'),
                            buildExpandedButton('6'),
                            buildExpandedButton('+'),
                          ]),
                          buildRow([
                            buildExpandedButton('1'),
                            buildExpandedButton('2'),
                            buildExpandedButton('3'),
                            buildExpandedButton('='),
                          ]),
                          buildRow([
                            buildExpandedButton('0'),
                            buildExpandedButton('.'),
                            const Expanded(child: SizedBox()),
                            const Expanded(child: SizedBox()),
                          ]),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
