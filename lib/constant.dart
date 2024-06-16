import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//--------------------C O L O R S--------------------

const Color kBgcolor = Colors.black;
const Color kPrimarycolor = Color(0xffFF6600);
const Color kContainercolor = Color(0xff444648);

const Color kGreyColor = Color.fromARGB(255, 20, 20, 20);

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