import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_tag_editor/tag_editor.dart';

Widget _editor({
  required InputSuggestions<String> findSuggestions,
  SearchSuggestions<String>? searchAllSuggestions,
  GlobalKey<TagsEditorState<String>>? key,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TagEditor<String>(
        key: key,
        length: 0,
        tagBuilder: (_, __) => const SizedBox(),
        onTagChanged: (_) {},
        suggestionBuilder: (_, __, data, ___, ____, _____, ______) => Text(data),
        findSuggestions: findSuggestions,
        searchAllSuggestions: searchAllSuggestions,
        debounceDuration: const Duration(milliseconds: 10),
        autoScrollToInput: false,
      ),
    ),
  );
}

void main() {
  testWidgets('a suggestion search finishing after dispose does not throw', (tester) async {
    final lookup = Completer<List<String>>();
    var started = false;
    await tester.pumpWidget(_editor(findSuggestions: (_) {
      started = true;
      return lookup.future;
    }));
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump(const Duration(milliseconds: 20));
    expect(started, isTrue);

    await tester.pumpWidget(const SizedBox());
    lookup.complete(['abc@x.io']);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a search-all finishing after dispose does not throw', (tester) async {
    final lookup = Completer<List<String>>();
    final key = GlobalKey<TagsEditorState<String>>();
    await tester.pumpWidget(_editor(
      key: key,
      findSuggestions: (_) => const [],
      searchAllSuggestions: () => lookup.future,
    ));
    key.currentState!.openSuggestionBox();

    await tester.pumpWidget(const SizedBox());
    lookup.complete(['abc@x.io']);
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
