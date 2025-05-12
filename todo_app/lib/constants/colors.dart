import 'package:flutter/material.dart';

// Light Theme Colors
const Color lightVeryLightGray = Color(0xFFFAFAFA); // hsl(0, 0%, 98%)
const Color lightVeryLightGrayishBlue = Color(0xFFE4E5F1); // hsl(236, 33%, 92%)
const Color lightLightGrayishBlue = Color(0xFFD2D3DB); // hsl(233, 11%, 84%)
const Color lightDarkGrayishBlue = Color(0xFF9394A5); // hsl(236, 9%, 61%)
const Color lightVeryDarkGrayishBlue = Color(0xFF484B6A); // hsl(235, 19%, 35%)

// Dark Theme Colors
const Color darkVeryDarkBlue = Color(0xFF161722); // hsl(235, 21%, 11%)
const Color darkVeryDarkDesaturatedBlue = Color(0xFF25273C); // hsl(235, 24%, 19%)
const Color darkLightGrayishBlue = Color(0xFFCACDE8); // hsl(234, 39%, 85%)
const Color darkLightGrayishBlueHover = Color(0xFFE4E5F1); // hsl(236, 33%, 92%) - Note: Hover might need stateful handling
const Color darkDarkGrayishBlue = Color(0xFF777A92); // hsl(234, 11%, 52%)
const Color darkVeryDarkGrayishBlue = Color(0xFF4D5067); // hsl(233, 14%, 35%) - Name collision, check usage
// const Color darkVeryDarkGrayishBlue2 = Color(0xFF393A4C); // hsl(237, 14%, 26%) - Alternative for name collision

// Primary Colors
const Color primaryBrightBlue = Color(0xFF3A7BFD); // hsl(220, 98%, 61%)
// For Check Background: linear-gradient hsl(192, 100%, 67%) to hsl(280, 87%, 65%)
// This will be handled by a LinearGradient widget, not a single color.
const Color gradientStart = Color(0xFF57DDFF); // hsl(192, 100%, 67%)
const Color gradientEnd = Color(0xFFC058F3);   // hsl(280, 87%, 65%) 