import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            onPressed: history.isEmpty ? null : _clearHistory,
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
