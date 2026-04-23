import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "0";
  String _currentInput = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operation = "";
  bool _isCalculated = false;
  final List<String> _history = []; 

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _currentInput = "";
        _num1 = 0;
        _num2 = 0;
        _operation = "";
        _isCalculated = false;
      } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
        if (_currentInput.isNotEmpty) {
          _num1 = double.parse(_currentInput);
          _operation = buttonText;
          _currentInput = "";
          _output = "$_num1 $_operation"; 
        }
      } else if (buttonText == "=") {
        if (_operation.isNotEmpty && _currentInput.isNotEmpty) {
          _num2 = double.parse(_currentInput);
          double result = 0;
          switch (_operation) {
            case "+":
              result = _num1 + _num2;
              break;
            case "-":
              result = _num1 - _num2;
              break;
            case "×":
              result = _num1 * _num2;
              break;
            case "÷":
              result = _num1 / _num2;
              break;
          }

          String historyItem = "$_num1 $_operation $_num2 = $result";
          _history.insert(0, historyItem);

          // Batasi history maksimal 10 
          if (_history.length > 10) {
            _history.removeLast();
          }

          _output = result.toString();
          _currentInput = result.toString();
          _operation = "";
          _isCalculated = true;
        }
      } else if (buttonText == "⌫") {
        if (_currentInput.isNotEmpty) {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
          _output = _currentInput.isEmpty ? "0" : _currentInput;
        }
      } else {
        if (_isCalculated) {
          _currentInput = buttonText;
          _isCalculated = false;
        } else {
          _currentInput += buttonText;
        }
        _output = _currentInput;
      }
    });
  }

  Widget _buildButton(String buttonText, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[300],
            foregroundColor: textColor ?? Colors.black,
            padding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('History Perhitungan'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_history[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _history.clear();
                });
                Navigator.pop(context);
              },
              child: const Text('Hapus History'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryDialog(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Text(
              _output,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: Divider()),
          Column(
            children: [
              Row(
                children: [
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton("÷", color: Colors.orange, textColor: Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton("×", color: Colors.orange, textColor: Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton("-", color: Colors.orange, textColor: Colors.white),
                ],
              ),
              Row(
                children: [
                  _buildButton("C", color: Colors.red, textColor: Colors.white),
                  _buildButton("0"),
                  _buildButton("=", color: Colors.blue, textColor: Colors.white),
                  _buildButton("+", color: Colors.orange, textColor: Colors.white),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}