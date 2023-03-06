# Super Tag Editor

A simple tag editor for imported tags in Flutter.

Enhance:
- Suggestion box
- Validation

![image](https://user-images.githubusercontent.com/80730648/223016736-684771bb-4892-4707-954d-9fffc0c929b2.gif)

## Usage

Add the package to pubspec.yaml

```dart
dependencies:
  super_tag_editor: x.x.x
```

Import it

```dart
import 'package:super_tag_editor/tag_editor.dart';
```

Use the widget

```dart
TagEditor(
  length: values.length,
  delimiters: [',', ' '],
  hasAddButton: true,
  inputDecoration: const InputDecoration(
    border: InputBorder.none,
    hintText: 'Hint Text...',
  ),
  onTagChanged: (newValue) {
    setState(() {
      values.add(newValue);
    });
  },
  tagBuilder: (context, index) => _Chip(
    index: index,
    label: values[index],
    onDeleted: onDelete,
  ),
  suggestionBuilder: (context, state, data) => ListTile(
    key: ObjectKey(data),
    title: Text(data),
    onTap: () {
      state.selectSuggestion(data);
    },
  ),
  suggestionsBoxElevation: 10,
  findSuggestions: (String query) {
    return [];
  }
)
```

It is possible to build the tag from your own widget, but it is recommended that Material Chip is used

```dart
class _Chip extends StatelessWidget {
  const _Chip({
    @required this.label,
    @required this.onDeleted,
    @required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}
```