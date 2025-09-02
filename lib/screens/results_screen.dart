import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/patient_data.dart';
import '../models/nutrition_result.dart';

class ResultsScreen extends StatelessWidget {
  final PatientData patientData;
  final NutritionResult result;

  const ResultsScreen({
    super.key,
    required this.patientData,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Nutrition Plan Results'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(context),
            tooltip: 'Share Results',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: '👤 Patient Information',
              icon: Icons.person,
              children: [
                _buildInfoRow('Age', '${patientData.age} years'),
                _buildInfoRow('Sex', patientData.sex == 'M' ? 'Male' : 'Female'),
                _buildInfoRow('Weight', '${patientData.weightKg.toStringAsFixed(1)} kg'),
                _buildInfoRow('Height', '${patientData.heightCm.toStringAsFixed(1)} cm'),
                _buildInfoRow('Activity Level', patientData.activityLevelDescription),
                _buildInfoRow('Medical Condition', patientData.medicalConditionDescription),
                if (patientData.medicalCondition == 'diabetes')
                  _buildInfoRow('Diabetes Subtype', patientData.diabetesSubtype),
                _buildInfoRow('Weight Goal', patientData.weightGoalDescription),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: '📈 Health Metrics',
              icon: Icons.analytics,
              children: [
                _buildInfoRow('BMI', '${result.bmi.toStringAsFixed(2)} kg/m²'),
                _buildInfoRow('BMI Classification', result.bmiClassification),
                _buildInfoRow('BMR', '${result.bmr.toStringAsFixed(0)} kcal/day'),
                _buildInfoRow('TDEE', '${result.tdee.toStringAsFixed(0)} kcal/day'),
                _buildInfoRow('Adjusted TDEE', '${result.adjustedTdee.toStringAsFixed(0)} kcal/day'),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: '🥗 Macronutrient Recommendations',
              icon: Icons.restaurant,
              children: [
                _buildInfoRow('Protein', '${result.macros['protein_g']!.toStringAsFixed(1)} g (${(result.macros['protein_pct']! * 100).toStringAsFixed(0)}%)'),
                _buildInfoRow('Carbohydrates', '${result.macros['carb_g']!.toStringAsFixed(1)} g (${(result.macros['carb_pct']! * 100).toStringAsFixed(0)}%)'),
                _buildInfoRow('Fat', '${result.macros['fat_g']!.toStringAsFixed(1)} g (${(result.macros['fat_pct']! * 100).toStringAsFixed(0)}%)'),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              title: '💊 Micronutrient Guidelines',
              icon: Icons.medication,
              children: result.micronutrientGuidelines.entries.map((entry) {
                return _buildInfoRow(entry.key, entry.value);
              }).toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveResults(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Plan'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Calculation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF3498db)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF34495e)),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResults(BuildContext context) {
    final text = _generateShareableText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Results copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveResults(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Save functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _generateShareableText() {
    final buffer = StringBuffer();
    buffer.writeln('📊 NUTRITION THERAPY CALCULATOR RESULTS');
    buffer.writeln('=' * 50);
    buffer.writeln();

    buffer.writeln('👤 PATIENT INFORMATION');
    buffer.writeln('Age: ${patientData.age} years');
    buffer.writeln('Sex: ${patientData.sex == 'M' ? 'Male' : 'Female'}');
    buffer.writeln('Weight: ${patientData.weightKg.toStringAsFixed(1)} kg');
    buffer.writeln('Height: ${patientData.heightCm.toStringAsFixed(1)} cm');
    buffer.writeln('Activity Level: ${patientData.activityLevelDescription}');
    buffer.writeln('Medical Condition: ${patientData.medicalConditionDescription}');
    if (patientData.medicalCondition == 'diabetes') {
      buffer.writeln('Diabetes Subtype: ${patientData.diabetesSubtype}');
    }
    buffer.writeln('Weight Goal: ${patientData.weightGoalDescription}');
    buffer.writeln();

    buffer.writeln('📈 HEALTH METRICS');
    buffer.writeln('BMI: ${result.bmi.toStringAsFixed(2)} kg/m²');
    buffer.writeln('BMI Classification: ${result.bmiClassification}');
    buffer.writeln('BMR: ${result.bmr.toStringAsFixed(0)} kcal/day');
    buffer.writeln('TDEE: ${result.tdee.toStringAsFixed(0)} kcal/day');
    buffer.writeln('Adjusted TDEE: ${result.adjustedTdee.toStringAsFixed(0)} kcal/day');
    buffer.writeln();

    buffer.writeln('🥗 MACRONUTRIENT RECOMMENDATIONS');
    buffer.writeln('Protein: ${result.macros['protein_g']!.toStringAsFixed(1)} g (${(result.macros['protein_pct']! * 100).toStringAsFixed(0)}%)');
    buffer.writeln('Carbohydrates: ${result.macros['carb_g']!.toStringAsFixed(1)} g (${(result.macros['carb_pct']! * 100).toStringAsFixed(0)}%)');
    buffer.writeln('Fat: ${result.macros['fat_g']!.toStringAsFixed(1)} g (${(result.macros['fat_pct']! * 100).toStringAsFixed(0)}%)');
    buffer.writeln();

    buffer.writeln('💊 MICRONUTRIENT GUIDELINES');
    for (final entry in result.micronutrientGuidelines.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }

    return buffer.toString();
  }
}


