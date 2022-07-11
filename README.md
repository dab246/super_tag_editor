# Super Tag Editor

A simple tag editor for inputting tags with suggestion box

![image](https://user-images.githubusercontent.com/18391546/82047483-dc8f0f00-96ed-11ea-8a91-7eaa64e2358b.gif)

#### Supported suggestion box
Screen Shot 1         |    Screen Shot 2
:-------------------------:|:-------------------------:
!["Screen Shot 2022-03-01 at 15 36 31](https://user-images.githubusercontent.com/80730648/156135105-04d93fac-ef0d-4889-b24a-61a7b3b470e3.png)  |  ![Screen Shot 2022-03-01 at 15 36 40](https://user-images.githubusercontent.com/80730648/156135234-dcfc5416-abff-4c1e-bb8b-0a78e386710c.png))


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