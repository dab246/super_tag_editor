import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:super_tag_editor/tag_editor.dart';
import 'package:super_tag_editor/widgets/rich_text_widget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material Tag Editor Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Material Tag Editor Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const mockResults = [
    'dat@gmail.com',
    'dab246@gmail.com',
    'kaka@gmail.com',
    'datvu@gmail.com',
    'datvu1@gmail.com',
    'datvu2@gmail.com',
    'datvu3@gmail.com',
    'datvu4@gmail.com',
    'datvu5@gmail.com',
    'datvu6@gmail.com',
    'datvu7@gmail.com',
    'datvu8@gmail.com',
    'datvu9@gmail.com',
    'datvu10@gmail.com',
    'datvu11@gmail.com',
    'datvu12@gmail.com',
    'datvu13@gmail.com',
    'datvu14@gmail.com',
    'datvu15@gmail.com',
    'datvu16@gmail.com',
    'datvu17@gmail.com',
    'datvu18@gmail.com',
    'datvu19@gmail.com',
    'datvu20@gmail.com',
  ];

  final List<String> _values = [];
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  int tagFocusIndex = -1;

  FocusNode? _focusNodeKeyboard;

  _onDelete(index) {
    setState(() {
      _values.removeAt(index);
    });
  }

  /// This is just an example for using `TextEditingController` to manipulate
  /// the the `TextField` just like a normal `TextField`.
  _onPressedModifyTextField() {
    const text = 'Test';
    _textEditingController.text = text;
    _textEditingController.value = _textEditingController.value.copyWith(
      text: text,
      selection: const TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _focusNodeKeyboard = FocusNode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                TagEditor<String>(
                  length: _values.length,
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  focusNodeKeyboard: _focusNodeKeyboard,
                  delimiters: const [',', ' '],
                  hasAddButton: true,
                  resetTextOnSubmitted: true,
                  suggestionsBoxMaxHeight: 200,
                  isLoadMoreOnlyOnce: true,
                  isLoadMoreReplaceAllOld: false,
                  // This is set to grey just to illustrate the `textStyle` prop
                  textStyle: const TextStyle(color: Colors.grey),
                  onSubmitted: (outstandingValue) {
                    setState(() {
                      _values.add(outstandingValue);
                    });
                  },
                  inputDecoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Hint Text...',
                  ),
                  onTagChanged: (newValue) {
                    setState(() {
                      _values.add(newValue);
                    });
                  },
                  tagBuilder: (context, index) => Container(
                    color: tagFocusIndex == index
                        ? Colors.redAccent
                        : Colors.white,
                    child: _Chip(
                      index: index,
                      label: _values[index],
                      onDeleted: _onDelete,
                    ),
                  ),
                  // InputFormatters example, this disallow \ and /
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[/\\]'))
                  ],
                  useDefaultHighlight: false,
                  suggestionBuilder: (context, state, data, index, length,
                      highlight, suggestionValid) {
                    var borderRadius =
                        const BorderRadius.all(Radius.circular(20));
                    if (index == 0) {
                      borderRadius = const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      );
                    } else if (index == length - 1) {
                      borderRadius = const BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      );
                    }
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _values.add(data);
                        });
                        state.resetTextField();
                        state.closeSuggestionBox();
                      },
                      child: Container(
                          decoration: highlight
                              ? BoxDecoration(
                                  color: Theme.of(context).focusColor,
                                  borderRadius: borderRadius)
                              : null,
                          padding: const EdgeInsets.all(16),
                          child: RichTextWidget(
                            wordSearched: suggestionValid ?? '',
                            textOrigin: data,
                          )),
                    );
                  },
                  onFocusTagAction: (index) {
                    debugPrint(
                        '_MyHomePageState::build:onFocusTagAction::index = $index');
                    setState(() {
                      tagFocusIndex = index;
                    });
                  },
                  onDeleteTagAction: (index) {
                    if (_values.isNotEmpty &&
                        index >= 0 &&
                        index < _values.length) {
                      setState(() {
                        _values.removeAt(index);
                      });
                    }
                  },
                  onSelectOptionAction: (item) {
                    setState(() {
                      _values.add(item);
                    });
                  },
                  suggestionsBoxElevation: 10,
                  findSuggestions: (String query) {
                    debugPrint(
                        '_MyHomePageState::build:findSuggestions::query = $query');
                    if (query.isNotEmpty) {
                      var lowercaseQuery = query.toLowerCase();
                      return mockResults.sublist(0, 8).where((profile) {
                        return profile
                                .toLowerCase()
                                .contains(query.toLowerCase()) ||
                            profile.toLowerCase().contains(query.toLowerCase());
                      }).toList(growable: false)
                        ..sort((a, b) => a
                            .toLowerCase()
                            .indexOf(lowercaseQuery)
                            .compareTo(
                                b.toLowerCase().indexOf(lowercaseQuery)));
                    }
                    return [];
                  },
                  loadMoreSuggestions: (query) {
                    debugPrint(
                        '_MyHomePageState::build:_loadMoreSuggestion::query = $query');
                    if (query.isNotEmpty) {
                      var lowercaseQuery = query.toLowerCase();
                      return mockResults.where((profile) {
                        return profile
                                .toLowerCase()
                                .contains(query.toLowerCase()) ||
                            profile.toLowerCase().contains(query.toLowerCase());
                      }).toList(growable: false)
                        ..sort((a, b) => a
                            .toLowerCase()
                            .indexOf(lowercaseQuery)
                            .compareTo(
                                b.toLowerCase().indexOf(lowercaseQuery)));
                    }
                    return [];
                  },
                ),
                const Divider(),
                // This is just a button to illustrate how to use
                // TextEditingController to set the value
                // or do whatever you want with it
                ElevatedButton(
                  onPressed: _onPressedModifyTextField,
                  child: const Text('Use Controller to Set Value'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeKeyboard?.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: const Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}
