import 'package:flutter/material.dart';

extension BoxDecorationExtension on ThemeData {
  BoxDecoration get boxDecoration => BoxDecoration(
    border: BoxBorder.all(
      color: brightness == Brightness.dark
          ? Colors.transparent
          : colorScheme.inverseSurface.withValues(alpha: .125),
    ),
    borderRadius: BorderRadius.circular(10),
    color: colorScheme.surfaceContainer,
  );
}
