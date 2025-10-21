import 'package:flutter/material.dart';

class ValidationSuggestionItem
    extends InheritedNotifier<ValueNotifier<String?>> {
  /// Create an instance of ValidationSuggestionItem inherited widget.
  const ValidationSuggestionItem({
    super.key,
    required ValueNotifier<String?> validationNotifier,
    required super.child,
  }) : super(notifier: validationNotifier);

  static String? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ValidationSuggestionItem>()
        ?.notifier
        ?.value;
  }
}
