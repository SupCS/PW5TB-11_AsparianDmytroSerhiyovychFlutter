import 'package:flutter/material.dart';

class LossCalculatorScreen extends StatefulWidget {
  const LossCalculatorScreen({super.key});

  @override
  _LossCalculatorScreenState createState() => _LossCalculatorScreenState();
}

class _LossCalculatorScreenState extends State<LossCalculatorScreen> {
  final TextEditingController omegaController = TextEditingController();
  final TextEditingController tbController = TextEditingController();
  final TextEditingController pNomController = TextEditingController();
  final TextEditingController tmController = TextEditingController();
  final TextEditingController kpController = TextEditingController();
  final TextEditingController zPer0Controller = TextEditingController();
  final TextEditingController zPlanController = TextEditingController();

  String mwAvar = '';
  String mwPlan = '';
  String totalLosses = '';

  void calculateLosses() {
    double omega = double.tryParse(omegaController.text) ?? 0;
    double tb = double.tryParse(tbController.text) ?? 0;
    double pNom = double.tryParse(pNomController.text) ?? 0;
    double tm = double.tryParse(tmController.text) ?? 0;
    double kp = double.tryParse(kpController.text) ?? 0;
    double zPer0 = double.tryParse(zPer0Controller.text) ?? 0;
    double zPlan = double.tryParse(zPlanController.text) ?? 0;

    double mwAvarCalc = omega * pNom * tb * tm;
    double mwPlanCalc = kp * pNom * tm;
    double totalCalc = zPer0 + (mwAvarCalc * zPer0) + (mwPlanCalc * zPlan);

    setState(() {
      mwAvar = mwAvarCalc.toStringAsFixed(4);
      mwPlan = mwPlanCalc.toStringAsFixed(4);
      totalLosses = totalCalc.toStringAsFixed(4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Калькулятор втрат")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _inputField(omegaController, "Частота відмов (ω)"),
            _inputField(tbController, "Середній час відновлення (t_b)"),
            _inputField(pNomController, "Номінальна потужність (P_nom)"),
            _inputField(tmController, "Тариф (T_m)"),
            _inputField(kpController, "Коефіцієнт планового простою (k_p)"),
            _inputField(zPer0Controller,
                "Прямі збитки від аварійного відключення (Z_пер(0))"),
            _inputField(zPlanController,
                "Прямі збитки від планового відключення (Z_пер(план))"),
            ElevatedButton(
                onPressed: calculateLosses, child: const Text("Розрахувати")),
            _resultText("Очікувані втрати від аварій (M(W_нед.авар.))", mwAvar),
            _resultText(
                "Очікувані втрати від планових відключень (M(W_нед.план.))",
                mwPlan),
            _resultText("Загальні втрати (Z_пер.)", totalLosses),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label)),
    );
  }

  Widget _resultText(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text("$label: $value"));
  }
}
