import 'package:flutter/material.dart';

/// Responsive sizing utility that scales dimensions based on screen size.
/// Uses a reference design of 375x812 (iPhone X).
class Responsive {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _scaleFactor;
  static late EdgeInsets _safePadding;

  static const double _referenceWidth = 375.0;
  static const double _referenceHeight = 812.0;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _safePadding = mediaQuery.padding;
    _scaleFactor = _screenWidth / _referenceWidth;
  }

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static EdgeInsets get safePadding => _safePadding;
  static double get scaleFactor => _scaleFactor;

  /// Scale a value relative to screen width.
  static double w(double value) => value * _scaleFactor;

  /// Scale a value relative to screen height.
  static double h(double value) => value * (_screenHeight / _referenceHeight);

  /// Scale font size.
  static double sp(double value) => value * _scaleFactor.clamp(0.8, 1.3);

  /// Get the available board height (excluding safe areas and HUD).
  static double get boardHeight {
    return _screenHeight - _safePadding.top - _safePadding.bottom - 140;
  }

  /// Get the board size (square, limited by smallest dimension).
  static double get boardSize {
    final availableWidth = _screenWidth - 40;
    final availableHeight = boardHeight - 40;
    return availableWidth < availableHeight ? availableWidth : availableHeight;
  }
}
