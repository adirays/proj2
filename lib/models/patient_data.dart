class PatientData {
  final int age;
  final String sex;
  final double weightKg;
  final double heightCm;
  final double activityFactor;
  final String activityLevelDescription;
  final String medicalCondition;
  final String medicalConditionDescription;
  final String weightGoal;
  final String weightGoalDescription;
  final String diabetesSubtype;

  PatientData({
    required this.age,
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.activityFactor,
    required this.activityLevelDescription,
    required this.medicalCondition,
    required this.medicalConditionDescription,
    required this.weightGoal,
    required this.weightGoalDescription,
    required this.diabetesSubtype,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'sex': sex,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'activity_factor': activityFactor,
      'activity_level_description': activityLevelDescription,
      'medical_condition': medicalCondition,
      'medical_condition_description': medicalConditionDescription,
      'weight_goal': weightGoal,
      'weight_goal_description': weightGoalDescription,
      'diabetes_subtype': diabetesSubtype,
    };
  }
}


