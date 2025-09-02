class NutritionResult {
  final double bmi;
  final String bmiClassification;
  final double bmr;
  final double tdee;
  final double adjustedTdee;
  final Map<String, double> macros;
  final Map<String, String> micronutrientGuidelines;

  NutritionResult({
    required this.bmi,
    required this.bmiClassification,
    required this.bmr,
    required this.tdee,
    required this.adjustedTdee,
    required this.macros,
    required this.micronutrientGuidelines,
  });
}


