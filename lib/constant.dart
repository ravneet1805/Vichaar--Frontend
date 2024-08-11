import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';





//--------------------C O L O R S--------------------

const Color kBgcolor = Colors.black;
const Color kPrimarycolor = Color(0xffFF6600);
const Color kContainercolor = Color(0xff444648);
const Color kGreyHeadTextcolor = Color(0xffEEEEEE);
const Color kGreenTextcolor = Color(0xffff1EA5A1);
const Color kGreyColor = Color.fromARGB(255, 20, 20, 20);
const Color kPurpleColor = Color(0xff3533cd);

//--------------------S T Y L E S--------------------

TextStyle kErrorStyle = GoogleFonts.spaceMono(
  color: Colors.white,
  fontSize: 16,
);
TextStyle kCounterStyle = GoogleFonts.spaceMono(
  color: Colors.white,
  fontSize: 40,
);

TextStyle kOnBoardTitleStyle = GoogleFonts.spaceMono(
    color: Colors.white, fontSize: 40, fontWeight: FontWeight.w500);

TextStyle kHintStyle = GoogleFonts.spaceMono(
  color: Colors.grey,
  fontSize: 16,
);

//--------------------G R A D I E N T S--------------------

const Gradient kBgGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xff000000), kGreyColor]);

const Gradient kButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xff7CCBBA), Color(0xff1EA5A1)]);

    const Gradient kPurpleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xff090979), Color(0xff3533cd)]);




   // constants.dart
final List<String> hardSkillsGroup1 = [
  'JavaScript',
  'Python',
  'Java',
  'C++',
  'Flutter',
  'Dart',
  'React',
  'Node.js',
  'Angular',
  'HTML',
  'CSS',
];
final List<String> hardSkillsGroup2 = [
  'Frontend Development',
  'SQL',
  'Backend Development',
  'MongoDB',
  'Git',
  'Docker',
  'Mobile Development',
  'AWS',
  'Firebase',
  'Machine Learning',
];
final List<String> hardSkillsGroup3 = [
  'DevOps',
  'Data Science',
  'UI/UX Design',
  'Full Stack Development',
  'Swift',
  'Kotlin',
  'PHP',
  'Ruby',
  'Go',
  'Rust',
];
final List<String> hardSkillsGroup4 = [
  'Objective-C',
  'Blockchain',
  'Scala',
  'Haskell',
  'Elixir',
  'Vue.js',
  'Svelte',
  'Bootstrap',
  'Tailwind CSS',
  'GraphQL',
];
final List<String> hardSkillsGroup5 = [
  'REST',
  'TensorFlow',
  'PyTorch',
  'Scikit-Learn',
  'Pandas',
  'NumPy',
  'Matplotlib',
  'Seaborn',
  'Tableau',
  'Power BI',
];
final List<String> hardSkillsGroup6 = [
  'Figma',
  'Adobe XD',
  'Sketch',
  'Illustrator',
  'Photoshop',
  'InDesign',
  'After Effects',
  'Premiere Pro',
  'Final Cut Pro',
  '3D Modeling',
];
final List<String> hardSkillsGroup7 = [
  'Blender',
  'AutoCAD',
  'SolidWorks',
  'Embedded Systems',
  'Microcontrollers',
  'Arduino',
];
final List<String> hardSkillsGroup8 = [
  'Raspberry Pi',
  'IoT',
  'Computer Vision',
  'Natural Language Processing',
  'Cybersecurity',
  'Cryptocurrency',
  'Jenkins',
  'Terraform',
];



final List<String> softSkillsGroup1 = [
  'Communication',
  'Leadership',
  'Problem Solving',
  'Teamwork',
  'Adaptability',
  'Creativity',
  'Critical Thinking',
  'Emotional Intelligence',
  'Time Management',
  'Decision Making',
];
final List<String> softSkillsGroup2 = [
  'Stress Management',
  'Conflict Resolution',
  'Interpersonal Skills',
  'Negotiation',
  'Networking',
  'Collaboration',
  'Empathy',
  'Self-Motivation',
  'Accountability',
  'Positive Attitude',
];
final List<String> softSkillsGroup3 = [
  'Goal Setting',
  'Flexibility',
  'Innovation',
  'Resilience',
];
