import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
);
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
);


class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme;
  bool _isDarkMode;
  
  ThemeProvider({bool isDarkMode = true})
      : _isDarkMode = isDarkMode,
        _selectedTheme = isDarkMode ? darkTheme : lightTheme;

  ThemeData get getTheme => _selectedTheme;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    if (_isDarkMode) {
      _selectedTheme = lightTheme;
      _isDarkMode = false;
    } else {
      _selectedTheme = darkTheme;
      _isDarkMode = true;
    }
    notifyListeners();
  }
}