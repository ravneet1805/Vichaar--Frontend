import 'package:flutter/material.dart';

class SkillsProvider with ChangeNotifier {
  List<String> _selectedSkills = [];

  List<String> get selectedSkills => _selectedSkills;

  void toggleSkill(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      if (_selectedSkills.length < 5) {
        _selectedSkills.add(skill);
      }
    }
    notifyListeners();
  }

  void setSelectedSkills(List<String> skills) {
    _selectedSkills = skills;
    notifyListeners(); // Notify listeners to update the UI
  }

  void clearSkills() {
    _selectedSkills.clear();
    notifyListeners();
  }
}
