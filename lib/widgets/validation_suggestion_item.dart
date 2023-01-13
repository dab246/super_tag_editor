import 'package:flutter/material.dart';

class ValidationSuggestionItem
    extends InheritedNotifier<ValueNotifier<String?>> {
  /// Create an instance of ValidationSuggestionItem inherited widget.
  const ValidationSuggestionItem({
    Key? key,
    required ValueNotifier<String?> validationNotifier,
    required Widget child,
  }) : super(key: key, notifier: validationNotifier, child: child);

  static String? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ValidationSuggestionItem>()
        ?.notifier
        ?.value;
  }
}
