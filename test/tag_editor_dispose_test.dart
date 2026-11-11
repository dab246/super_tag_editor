import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_tag_editor/tag_editor.dart';

Widget _editor({
  required InputSuggestions<String> findSuggestions,
  SearchSuggestions<String>? searchAllSuggestions,
  InputSuggestions<String>? loadMoreSuggestions,
  GlobalKey<TagsEditorState<String>>? key,
  double? suggestionsBoxMaxHeight,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TagEditor<String>(
        key: key,
        length: 0,
        tagBuilder: (_, __) => const SizedBox(),
        onTagChanged: (_) {},
        suggestionBuilder: (_, __, data, ___, ____, _____, ______) =>
            SizedBox(height: 48, child: Text(data)),
        findSuggestions: findSuggestions,
        searchAllSuggestions: searchAllSuggestions,
        loadMoreSuggestions: loadMoreSuggestions,
        suggestionsBoxMaxHeight: suggestionsBoxMaxHeight,
        suggestionItemHeight: 48,
        debounceDuration: const Duration(milliseconds: 10),
        autoScrollToInput: false,
      ),
    ),
  );
}

Future<void> _typeAndWaitForDebounce(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(milliseconds: 20));
}

void _dispatchScrollEndAtMax(WidgetTester tester) {
  final listContext = tester.element(find.byType(ListView));
  ScrollEndNotification(
    metrics: FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 100,
      pixels: 100,
      viewportDimension: 50,
      axisDirection: AxisDirection.down,
      devicePixelRatio: tester.view.devicePixelRatio,
    ),
    context: listContext,
  ).dispatch(listContext);
}

Future<void> _completeLookupAfterOptionalDispose({
  required WidgetTester tester,
  required Completer<List<String>> lookup,
  required List<String> results,
  required bool disposeFirst,
}) async {
  if (disposeFirst) {
    await tester.pumpWidget(const SizedBox());
  }
  lookup.complete(results);
  await tester.pump();
}

Future<void> _searchFinishesAfterDispose(WidgetTester tester) async {
  final lookup = Completer<List<String>>();
  var started = false;
  await tester.pumpWidget(_editor(findSuggestions: (_) {
    started = true;
    return lookup.future;
  }));
  await _typeAndWaitForDebounce(tester, 'abc');
  expect(started, isTrue);

  await _completeLookupAfterOptionalDispose(
    tester: tester,
    lookup: lookup,
    results: ['abc@x.io'],
    disposeFirst: true,
  );

  expect(tester.takeException(), isNull);
}

Future<void> _runSearchAll({
  required WidgetTester tester,
  required bool disposeBeforeComplete,
  required String completedValue,
  Finder? expectVisible,
}) async {
  final lookup = Completer<List<String>>();
  final key = GlobalKey<TagsEditorState<String>>();
  await tester.pumpWidget(_editor(
    key: key,
    findSuggestions: (_) => const [],
    searchAllSuggestions: () => lookup.future,
  ));
  key.currentState!.openSuggestionBox();

  await _completeLookupAfterOptionalDispose(
    tester: tester,
    lookup: lookup,
    results: [completedValue],
    disposeFirst: disposeBeforeComplete,
  );

  if (expectVisible != null) {
    expect(expectVisible, findsOneWidget);
  }
  expect(tester.takeException(), isNull);
}

Future<void> _runLoadMore({
  required WidgetTester tester,
  required bool disposeBeforeComplete,
  Finder? expectVisible,
}) async {
  final loadMore = Completer<List<String>>();
  var loadMoreStarted = false;
  await tester.pumpWidget(_editor(
    findSuggestions: (_) => List.generate(8, (i) => 'item-$i'),
    loadMoreSuggestions: (_) {
      loadMoreStarted = true;
      return loadMore.future;
    },
    suggestionsBoxMaxHeight: 120,
  ));
  await _typeAndWaitForDebounce(tester, 'item');
  await tester.pump();
  expect(find.text('item-0'), findsOneWidget);

  _dispatchScrollEndAtMax(tester);
  await tester.pump();
  expect(loadMoreStarted, isTrue);

  await _completeLookupAfterOptionalDispose(
    tester: tester,
    lookup: loadMore,
    results: ['item-8'],
    disposeFirst: disposeBeforeComplete,
  );

  if (expectVisible != null) {
    expect(expectVisible, findsOneWidget);
  }
  expect(tester.takeException(), isNull);
}

Future<void> _searchFinishesWhileMounted(WidgetTester tester) async {
  final lookup = Completer<List<String>>();
  await tester.pumpWidget(_editor(findSuggestions: (_) => lookup.future));
  await _typeAndWaitForDebounce(tester, 'abc');

  await _completeLookupAfterOptionalDispose(
    tester: tester,
    lookup: lookup,
    results: ['abc@x.io'],
    disposeFirst: false,
  );

  expect(find.text('abc@x.io'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'a suggestion search finishing after dispose does not throw',
    _searchFinishesAfterDispose,
  );
  testWidgets(
    'a search-all finishing after dispose does not throw',
    (tester) => _runSearchAll(
      tester: tester,
      disposeBeforeComplete: true,
      completedValue: 'abc@x.io',
    ),
  );
  testWidgets(
    'a load-more finishing after dispose does not throw',
    (tester) => _runLoadMore(
      tester: tester,
      disposeBeforeComplete: true,
    ),
  );
  testWidgets(
    'a suggestion search finishing while mounted updates the list',
    _searchFinishesWhileMounted,
  );
  testWidgets(
    'a search-all finishing while mounted updates the list',
    (tester) => _runSearchAll(
      tester: tester,
      disposeBeforeComplete: false,
      completedValue: 'all@x.io',
      expectVisible: find.text('all@x.io'),
    ),
  );
  testWidgets(
    'a load-more finishing while mounted updates the list',
    (tester) => _runLoadMore(
      tester: tester,
      disposeBeforeComplete: false,
      expectVisible: find.text('item-8'),
    ),
  );
}
