import 'package:flutter/material.dart';
import 'dart:math';

class ReliabilityCalculatorScreen extends StatefulWidget {
  const ReliabilityCalculatorScreen({super.key});

  @override
  _ReliabilityCalculatorScreenState createState() =>
      _ReliabilityCalculatorScreenState();
}

class _ReliabilityCalculatorScreenState
    extends State<ReliabilityCalculatorScreen> {
  final Map<String, TextEditingController> controllers = {};
  String systemFailureFrequency = "";
  String averageRecoveryTime = "";
  String accidentalDowntime = "";
  String plannedDowntime = "";
  String dualSystemFailureRate = "";
  String finalFailureRate = "";

  final Map<String, ReliabilityParameters> reliabilityData = {
    "Т-110 кВ": ReliabilityParameters(0.015, 100, 1.0, 43),
    "Т-35 кВ": ReliabilityParameters(0.02, 80, 1.0, 28),
    "Т-10 кВ (Кабельна мережа)": ReliabilityParameters(0.005, 60, 0.5, 10),
    "Т-10 кВ (Повітряна мережа)": ReliabilityParameters(0.05, 60, 0.5, 10),
    "В-110 кВ (Газ)": ReliabilityParameters(0.01, 30, 0.1, 30),
    "В-10 кВ (Масляне)": ReliabilityParameters(0.02, 15, 0.33, 15),
    "В-10 кВ (Вакуумне)": ReliabilityParameters(0.05, 15, 0.33, 15),
    "Шинопроводи 10 кВ (на з'єднання)":
        ReliabilityParameters(0.03, 2, 0.33, 15),
    "АВ-0.38 кВ": ReliabilityParameters(0.05, 20, 1.0, 15),
    "ЕД 6,10 кВ": ReliabilityParameters(0.1, 50, 0.5, 0),
    "ЕД 0.38 кВ": ReliabilityParameters(0.1, 50, 0.5, 0),
    "ПЛ-110 кВ": ReliabilityParameters(0.007, 10, 0.167, 35),
    "ПЛ-35 кВ": ReliabilityParameters(0.02, 8, 0.167, 35),
    "ПЛ-10 кВ": ReliabilityParameters(0.02, 10, 0.167, 35),
    "КЛ-10 кВ (Траншея)": ReliabilityParameters(0.03, 44, 1.0, 9),
    "КЛ-10 кВ (Кабельний канал)": ReliabilityParameters(0.005, 18, 1.0, 9)
  };

  @override
  void initState() {
    super.initState();
    for (var key in reliabilityData.keys) {
      controllers[key] = TextEditingController(text: "0");
    }
  }

  void calculateReliability() {
    double totalFailureRate = 0;
    double weightedRecoveryTime = 0;

    for (var key in reliabilityData.keys) {
      int quantity = int.tryParse(controllers[key]!.text) ?? 0;
      var params = reliabilityData[key]!;

      if (quantity > 0) {
        totalFailureRate += quantity * params.failureRate;
        weightedRecoveryTime +=
            quantity * params.failureRate * params.avgRepairTime;
      }
    }

    double avgRecovery = weightedRecoveryTime / max(totalFailureRate, 1);
    double accDowntime = avgRecovery * totalFailureRate / 8760;
    double plannedDowntimeCalc = 1.2 * 43 / 8760;
    double dualFailureRateCalc =
        2 * totalFailureRate * (accDowntime + plannedDowntimeCalc);
    double finalRate = dualFailureRateCalc + 0.02;

    setState(() {
      systemFailureFrequency = totalFailureRate.toStringAsFixed(4);
      averageRecoveryTime = avgRecovery.toStringAsFixed(4);
      accidentalDowntime = accDowntime.toStringAsFixed(4);
      plannedDowntime = plannedDowntimeCalc.toStringAsFixed(4);
      dualSystemFailureRate = dualFailureRateCalc.toStringAsFixed(4);
      finalFailureRate = finalRate.toStringAsFixed(4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reliability Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Введіть кількість елементів для кожного типу:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (var key in reliabilityData.keys)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: controllers[key],
                  decoration: InputDecoration(labelText: key),
                  keyboardType: TextInputType.number,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: calculateReliability,
              child: const Text("Розрахувати"),
            ),
            const SizedBox(height: 16),
            _resultText("Частота відмов системи", systemFailureFrequency),
            _resultText("Середній час відновлення", averageRecoveryTime),
            _resultText("Коефіцієнт аварійного простою", accidentalDowntime),
            _resultText("Коефіцієнт планового простою", plannedDowntime),
            _resultText("Імовірність двійного відмови", dualSystemFailureRate),
            _resultText("Ймовірність відмови з перемиканням", finalFailureRate),
          ],
        ),
      ),
    );
  }

  Widget _resultText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text("$label: $value", style: const TextStyle(fontSize: 16)),
    );
  }
}

class ReliabilityParameters {
  final double failureRate;
  final int avgRepairTime;
  final double frequency;
  final int? avgRecoveryTime;

  ReliabilityParameters(this.failureRate, this.avgRepairTime, this.frequency,
      this.avgRecoveryTime);
}
