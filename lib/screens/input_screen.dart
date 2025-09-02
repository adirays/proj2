import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/patient_data.dart';
import '../services/nutrition_calculator.dart';
import 'results_screen.dart';
import '../widgets/section_header.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedSex = 'M';
  String _selectedActivityLevel = 'Sedentary (little or no exercise)';
  String _selectedMedicalCondition = 'None';
  String _selectedWeightGoal = 'Maintain Weight';
  String _selectedDiabetesSubtype = 'Type 1';

  final Map<String, double> _activityLevels = {
    "Sedentary (little or no exercise)": 1.2,
    "Lightly active (light exercise/sports 1-3 days/week)": 1.375,
    "Moderately active (moderate exercise/sports 3-5 days/week)": 1.55,
    "Very active (hard exercise/sports 6-7 days/week)": 1.725,
    "Extra active (very hard exercise/physical job)": 1.9
  };

  final Map<String, String> _medicalConditions = {
    "None": "general",
    "Diabetes": "diabetes",
    "Renal Disease": "renal_disease",
    "Hypertension": "hypertension",
    "Heart Disease": "heart_disease"
  };

  final Map<String, String> _weightGoals = {
    "Maintain Weight": "maintenance",
    "Lose Weight": "loss",
    "Gain Weight": "gain"
  };

  final List<String> _diabetesSubtypes = ["Type 1", "Type 2", "Gestational"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Nutrition Therapy Calculator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: '👤 Personal Information', icon: Icons.person),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _ageController,
                label: 'Age (years)',
                validator: _validateAge,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildSexSelector(),
              const SizedBox(height: 16),

              const SectionHeader(title: '📏 Physical Measurements', icon: Icons.straighten),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                validator: _validateWeight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                validator: _validateHeight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              const SectionHeader(title: '🏃 Activity & Health', icon: Icons.fitness_center),
              const SizedBox(height: 16),

              _buildDropdown(
                value: _selectedActivityLevel,
                items: _activityLevels.keys.toList(),
                label: 'Activity Level',
                onChanged: (value) => setState(() => _selectedActivityLevel = value!),
              ),
              const SizedBox(height: 16),

              _buildDropdown(
                value: _selectedMedicalCondition,
                items: _medicalConditions.keys.toList(),
                label: 'Medical Condition',
                onChanged: (value) => setState(() => _selectedMedicalCondition = value!),
              ),
              const SizedBox(height: 16),

              if (_medicalConditions[_selectedMedicalCondition] == "diabetes") ...[
                _buildDropdown(
                  value: _selectedDiabetesSubtype,
                  items: _diabetesSubtypes,
                  label: '💉 Diabetes Subtype',
                  onChanged: (value) => setState(() => _selectedDiabetesSubtype = value!),
                ),
                const SizedBox(height: 16),
              ],

              const SectionHeader(title: '🎯 Goals', icon: Icons.flag),
              const SizedBox(height: 16),

              _buildDropdown(
                value: _selectedWeightGoal,
                items: _weightGoals.keys.toList(),
                label: 'Weight Goal',
                onChanged: (value) => setState(() => _selectedWeightGoal = value!),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _calculateNutritionPlan,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculate Nutrition Plan'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(_getIconForField(label)),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : keyboardType == const TextInputType.numberWithOptions(decimal: true)
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              : null,
    );
  }

  Widget _buildSexSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sex:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('👨 Male'),
                value: 'M',
                groupValue: _selectedSex,
                onChanged: (value) => setState(() => _selectedSex = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('👩 Female'),
                value: 'F',
                groupValue: _selectedSex,
                onChanged: (value) => setState(() => _selectedSex = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(_getIconForField(label)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  IconData _getIconForField(String label) {
    if (label.contains('Age')) return Icons.cake;
    if (label.contains('Weight')) return Icons.monitor_weight;
    if (label.contains('Height')) return Icons.height;
    if (label.contains('Activity')) return Icons.directions_run;
    if (label.contains('Medical')) return Icons.medical_services;
    if (label.contains('Diabetes')) return Icons.bloodtype;
    if (label.contains('Goal')) return Icons.flag;
    return Icons.info;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age cannot be empty';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number for Age';
    }
    if (age < 1 || age > 120) {
      return 'Please enter a realistic age between 1 and 120 years';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight cannot be empty';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number for Weight';
    }
    if (weight < 20 || weight > 300) {
      return 'Please enter a realistic weight between 20 and 300 kg';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height cannot be empty';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number for Height';
    }
    if (height < 50 || height > 250) {
      return 'Please enter a realistic height between 50 and 250 cm';
    }
    return null;
  }

  void _calculateNutritionPlan() {
    if (_formKey.currentState!.validate()) {
      try {
        final patientData = PatientData(
          age: int.parse(_ageController.text),
          sex: _selectedSex,
          weightKg: double.parse(_weightController.text),
          heightCm: double.parse(_heightController.text),
          activityFactor: _activityLevels[_selectedActivityLevel]!,
          activityLevelDescription: _selectedActivityLevel,
          medicalCondition: _medicalConditions[_selectedMedicalCondition]!,
          medicalConditionDescription: _selectedMedicalCondition,
          weightGoal: _weightGoals[_selectedWeightGoal]!,
          weightGoalDescription: _selectedWeightGoal,
          diabetesSubtype: _medicalConditions[_selectedMedicalCondition] == "diabetes"
              ? _selectedDiabetesSubtype
              : "N/A",
        );

        final result = NutritionCalculator.calculateNutritionPlan(patientData);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              patientData: patientData,
              result: result,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating nutrition plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}


