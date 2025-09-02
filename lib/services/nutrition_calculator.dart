import '../models/patient_data.dart';
import '../models/nutrition_result.dart';
import 'config_service.dart';

class NutritionCalculator {
  static final ConfigService _config = ConfigService();

  static double calculateBmi(double weightKg, double heightCm) {
    double heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String classifyBmi(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 24.9) {
      return "Normal weight";
    } else if (bmi < 29.9) {
      return "Overweight";
    } else if (bmi < 34.9) {
      return "Obesity Class I";
    } else if (bmi < 39.9) {
      return "Obesity Class II";
    } else {
      return "Obesity Class III (Morbid Obesity)";
    }
  }

  static double calculateBmr(int age, String sex, double weightKg, double heightCm) {
    if (sex == 'M') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  static double calculateTdee(double bmr, double activityFactor) {
    return bmr * activityFactor;
  }

  static Map<String, double> getMacroRecommendations(
      double calories, Map<String, double> macroPercentages) {
    const Map<String, double> caloriesPerGram = {
      "protein": 4,
      "carb": 4,
      "fat": 9,
    };

    return {
      "protein_g": (calories * macroPercentages["protein"]!) / caloriesPerGram["protein"]!,
      "carb_g": (calories * macroPercentages["carb"]!) / caloriesPerGram["carb"]!,
      "fat_g": (calories * macroPercentages["fat"]!) / caloriesPerGram["fat"]!,
      "protein_pct": macroPercentages["protein"]!,
      "carb_pct": macroPercentages["carb"]!,
      "fat_pct": macroPercentages["fat"]!,
    };
  }

  static NutritionResult calculateNutritionPlan(PatientData patientData) {
    double bmi = calculateBmi(patientData.weightKg, patientData.heightCm);
    String bmiClassification = classifyBmi(bmi);
    double bmr = calculateBmr(patientData.age, patientData.sex, 
                             patientData.weightKg, patientData.heightCm);
    double tdee = calculateTdee(bmr, patientData.activityFactor);

    double adjustedTdee = tdee;
    if (patientData.weightGoal == "loss") {
      adjustedTdee -= _config.getCalorieAdjustment("weight_loss_deficit_kcal");

      double minCal = patientData.sex == "F" 
          ? _config.getMinCalories("female")
          : _config.getMinCalories("male");

      if (adjustedTdee < minCal) {
        adjustedTdee = minCal;
      }
    } else if (patientData.weightGoal == "gain") {
      adjustedTdee += _config.getCalorieAdjustment("weight_gain_surplus_kcal");
    }

    Map<String, double> macroPercentages = _config.getMacroPercentages(patientData.medicalCondition);
    Map<String, double> macros = getMacroRecommendations(adjustedTdee, macroPercentages);

    Map<String, String> micronutrientGuidelines = _config.getMicronutrientGuidelines(patientData.medicalCondition);

    return NutritionResult(
      bmi: bmi,
      bmiClassification: bmiClassification,
      bmr: bmr,
      tdee: tdee,
      adjustedTdee: adjustedTdee,
      macros: macros,
      micronutrientGuidelines: micronutrientGuidelines,
    );
  }
}


