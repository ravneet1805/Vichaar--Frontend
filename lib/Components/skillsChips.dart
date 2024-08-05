import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vichaar/SnackBar/errorSnackBar.dart';
import '../Provider/skillsProvider.dart';
import '../constant.dart';
// Import your provider

class SkillsChips extends StatelessWidget {
  final List<String> availableSkills;

  SkillsChips({required this.availableSkills});

  @override
  Widget build(BuildContext context) {
    final selectedSkills = context.watch<SkillsProvider>().selectedSkills;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSkills.map((skill) {
            final isSelected = selectedSkills.contains(skill);
            return ChoiceChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selectedSkills.length <= 5 || isSelected )
                  ? (_) {
                    if (!isSelected && selectedSkills.length >= 5) {
                        ErrorSnackbar.show(context, 'You can select up to 5 skills only');
                      } else {
                        context.read<SkillsProvider>().toggleSkill(skill);
                      }
                    }
                  : null,
              selectedColor: kPurpleColor,
              backgroundColor: kGreyColor,
              showCheckmark: false,
              shape: StadiumBorder(
                side: BorderSide(color: isSelected? kPurpleColor : Colors.white),
              ),
              labelStyle: TextStyle(
                color:  Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
