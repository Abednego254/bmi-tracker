import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
