import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bmi_chart.dart';
import 'bmi_history_screen.dart';

class BMICalculatorScreen extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;

  const BMICalculatorScreen({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
  });

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String result = '';
  double? _calculatedBMI;

  void calculateBMI() async {
    final height = double.tryParse(heightController.text);
    final weight = double.tryParse(weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      setState(() {
        result = "Please enter valid positive numbers!";
        _calculatedBMI = null;
      });
      return;
    }

    final bmi = weight / ((height / 100) * (height / 100));
    String status;

    if (bmi < 18.5) {
      status = "Underweight";
    } else if (bmi < 25) {
      status = "Normal";
    } else if (bmi < 30) {
      status = "Overweight";
    } else {
      status = "Obese";
    }

    final dateTime = DateTime.now().toString().split('.')[0];
    final entry = "BMI: ${bmi.toStringAsFixed(1)} ($status) | $dateTime";

    setState(() {
      _calculatedBMI = bmi;
      result = "Your $entry";
    });

    _saveToHistory(entry);
  }

  Future<void> _saveToHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('bmi_history') ?? [];
    history.insert(0, entry);
    await prefs.setStringList('bmi_history', history);
  }

  void clearFields() {
    heightController.clear();
    weightController.clear();
    setState(() {
      result = '';
      _calculatedBMI = null;
    });
  }

  void goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BMIHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
        actions: [
          TextButton.icon(
            onPressed: () => widget.onThemeChanged(!widget.isDarkTheme),
            icon: Icon(
              widget.isDarkTheme
                  ? Icons.wb_sunny_outlined
                  : Icons.nights_stay_outlined,
              color: widget.isDarkTheme ? Colors.yellow : Colors.blueGrey,
              size: 28, // Increased icon size
            ),
            label: Text(
              widget.isDarkTheme ? "Light Mode" : "Dark Mode",
              style: TextStyle(
                color: widget.isDarkTheme ? Colors.white : Colors.black,
                fontSize: 16, // Optional: slightly bigger text
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.history,
              size: 28, // Increased icon size
            ),
            onPressed: goToHistory,
            tooltip: "BMI History",
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                hintText: "Enter height in centimeters",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                hintText: "Enter weight in kilograms",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: calculateBMI,
                    child: const Text("Calculate BMI"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: clearFields,
                    child: const Text("Clear"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              result,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_calculatedBMI != null) BMIChart(bmi: _calculatedBMI!),
            const SizedBox(height: 30),
            _buildBMICategoryGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICategoryGuide() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "📊 BMI Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text("🔵 Underweight: BMI < 18.5"),
            Text("🟢 Normal: 18.5 ≤ BMI < 25"),
            Text("🟠 Overweight: 25 ≤ BMI < 30"),
            Text("🔴 Obese: BMI ≥ 30"),
          ],
        ),
      ),
    );
  }
}
