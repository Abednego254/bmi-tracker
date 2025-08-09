import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const BMICalculatorScreen(),
    );
  }
}

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

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

    final entry = "BMI: ${bmi.toStringAsFixed(1)} ($status)";

    setState(() {
      _calculatedBMI = bmi;
      result = "Your $entry";
    });

    _saveToHistory(entry);
  }

  Future<void> _saveToHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('bmi_history') ?? [];
    history.insert(0, entry); // Add newest first
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
          IconButton(
            icon: const Icon(Icons.history),
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
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
            if (_calculatedBMI != null) BMIChart(bmi: _calculatedBMI!)
          ],
        ),
      ),
    );
  }
}

class BMIChart extends StatelessWidget {
  final double bmi;

  const BMIChart({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: 40,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: bmi,
                  width: 20,
                  borderRadius: BorderRadius.circular(8),
                  color: _getColorForBMI(bmi),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 40,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 10),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => const Text('BMI'),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.center,
        ),
      ),
    );
  }

  Color _getColorForBMI(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}

class BMIHistoryScreen extends StatefulWidget {
  const BMIHistoryScreen({super.key});

  @override
  State<BMIHistoryScreen> createState() => _BMIHistoryScreenState();
}

class _BMIHistoryScreenState extends State<BMIHistoryScreen> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('bmi_history') ?? [];
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bmi_history');
    setState(() {
      history = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Clear History",
            onPressed: history.isEmpty
                ? null
                : () {
              _clearHistory();
            },
          )
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text("No history yet."))
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.monitor_weight),
          title: Text(history[index]),
        ),
      ),
    );
  }
}
