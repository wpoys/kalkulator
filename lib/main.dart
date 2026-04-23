import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Oy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "0";
  String _equation = "";
  String _currentInput = "";
  double _num1 = 0;
  String _operation = "";
  bool _isCalculated = false;
  final List<String> _history = [];

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _equation = "";
        _currentInput = "";
        _num1 = 0;
        _operation = "";
        _isCalculated = false;
      } else if (buttonText == "⌫") {
        if (_currentInput.isNotEmpty) {
          _currentInput = _currentInput.substring(0, _currentInput.length - 1);
          _output = _currentInput.isEmpty ? "0" : _currentInput;
        }
      } else if (buttonText == "+/-") {
        if (_currentInput.startsWith("-")) {
          _currentInput = _currentInput.substring(1);
        } else if (_currentInput.isNotEmpty && _currentInput != "0") {
          _currentInput = "-$_currentInput";
        }
        _output = _currentInput;
      } else if (buttonText == "%") {
        if (_currentInput.isNotEmpty) {
          double val = double.parse(_currentInput) / 100;
          _currentInput = val.toString();
          _output = _currentInput;
        }
      } else if (buttonText == ".") {
        if (!_currentInput.contains(".")) {
          _currentInput = _currentInput.isEmpty ? "0." : _currentInput + ".";
          _output = _currentInput;
        }
      } else if (["+", "-", "×", "÷"].contains(buttonText)) {
        if (_currentInput.isNotEmpty) {
          _num1 = double.parse(_currentInput);
          _operation = buttonText;
          _equation = "$_num1 $_operation";
          _currentInput = "";
          _isCalculated = false;
        }
      } else if (buttonText == "=") {
        if (_operation.isNotEmpty && _currentInput.isNotEmpty) {
          double num2 = double.parse(_currentInput);
          double result = 0;
          switch (_operation) {
            case "+": result = _num1 + num2; break;
            case "-": result = _num1 - num2; break;
            case "×": result = _num1 * num2; break;
            case "÷": result = num2 != 0 ? _num1 / num2 : 0; break;
          }
          _equation = "$_num1 $_operation $num2 =";
          _output = _formatResult(result);
          _history.insert(0, "$_equation $_output");
          if (_history.length > 10) _history.removeLast();
          _currentInput = _output;
          _operation = "";
          _isCalculated = true;
        }
      } else {
        if (_isCalculated) {
          _currentInput = buttonText;
          _isCalculated = false;
          _equation = "";
        } else {
          _currentInput += buttonText;
        }
        _output = _currentInput;
      }
    });
  }

  String _formatResult(double result) {
    if (result == result.toInt()) return result.toInt().toString();
    return result.toString();
  }

  // Widget tombol kotak dengan ukuran yang lebih mengisi ruang
  Widget _buildButton(String text, {Color? bgColor, Color? txtColor}) {
    return Expanded(
      child: Container(
        height: double.infinity, // Mengikuti tinggi Row yang tersedia
        margin: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? Colors.grey[900],
            foregroundColor: txtColor ?? Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Kotak lebih tegas tapi halus
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _buttonPressed(text),
          child: Text(text, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Calculator Oy", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.orange, size: 28),
            onPressed: () => _showHistory(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Area Layar Hasil (Mengambil ruang sisa yang tersedia)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_equation, style: TextStyle(fontSize: 24, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  FittedBox(
                    child: Text(_output, style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.w200)),
                  ),
                ],
              ),
            ),
          ),
          
          // Area Tombol (Menggunakan flex agar ukurannya pas di layar mana pun)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Expanded(
                    child: Row(children: [
                      _buildButton("C", bgColor: Colors.orange[800], txtColor: Colors.white),
                      _buildButton("+/-", bgColor: Colors.grey[800]),
                      _buildButton("%", bgColor: Colors.grey[800]),
                      _buildButton("÷", bgColor: Colors.orange),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      _buildButton("7"), _buildButton("8"), _buildButton("9"),
                      _buildButton("×", bgColor: Colors.orange),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      _buildButton("4"), _buildButton("5"), _buildButton("6"),
                      _buildButton("-", bgColor: Colors.orange),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      _buildButton("1"), _buildButton("2"), _buildButton("3"),
                      _buildButton("+", bgColor: Colors.orange),
                    ]),
                  ),
                  Expanded(
                    child: Row(children: [
                      _buildButton("0"),
                      _buildButton("."),
                      _buildButton("⌫"),
                      _buildButton("=", bgColor: Colors.orange),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Riwayat", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(_history[i], style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  leading: const Icon(Icons.calculate, color: Colors.orange),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
              onPressed: () { setState(() => _history.clear()); Navigator.pop(context); },
              child: const Text("Bersihkan Semua"),
            )
          ],
        ),
      ),
    );
  }
}