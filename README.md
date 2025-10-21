# 🏷️ Super Tag Editor

[![pub package](https://img.shields.io/pub/v/super_tag_editor.svg)](https://pub.dev/packages/super_tag_editor)
[![likes](https://img.shields.io/pub/likes/super_tag_editor.svg)](https://pub.dev/packages/super_tag_editor)
[![pub points](https://img.shields.io/pub/points/super_tag_editor.svg)](https://pub.dev/packages/super_tag_editor)
[![popularity](https://img.shields.io/pub/popularity/super_tag_editor.svg)](https://pub.dev/packages/super_tag_editor)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Flutter widget for editing and managing tags with a Material-style input experience.  
Designed to act and feel like the standard **TextField**, but with additional features such as:
- 🔍 **Suggestions box**
- ✅ **Validation support**
- 🧱 **Customizable tag builder**
- ⚡ **Debounced input and throttled callbacks**

![Demo](https://user-images.githubusercontent.com/80730648/223016736-684771bb-4892-4707-954d-9fffc0c929b2.gif)

---

## 🚀 Installation

Add this line to your `pubspec.yaml`:

```yaml
dependencies:
  super_tag_editor: ^0.4.1
```

Then run:

```bash
flutter pub get
```

Import it:

```dart
import 'package:super_tag_editor/tag_editor.dart';
```

---

## 🧩 Basic Usage

```dart
TagEditor(
  length: values.length,
  delimiters: [',', ' '],
  hasAddButton: true,
  inputDecoration: const InputDecoration(
    border: InputBorder.none,
    hintText: 'Enter tags...',
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
    // Example: implement your own search logic
    return [];
  },
)
```

---

## 🧱 Custom Tag Builder

You can customize how each tag looks by providing your own widget.  
Below is an example using a Material `Chip`:

```dart
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
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => onDeleted(index),
    );
  }
}
```

---

## 💡 Advanced Features

| Feature | Description |
|----------|-------------|
| `findSuggestions` | Returns async or sync list of suggestions. |
| `suggestionBuilder` | Custom widget builder for each suggestion item. |
| `onTagChanged` | Called whenever a new tag is added. |
| `onDeleteTagAction` | Callback when a tag is removed. |
| `debounce_throttle` | Built-in support for throttled input changes. |
| `pointer_interceptor` | Prevents UI overlaps with web platform overlays. |

---

## 🧪 Example App

A complete working example is available under the [`example/`](example/) directory:

```bash
cd example
flutter run
```

Example preview:

```dart
import 'package:flutter/material.dart';
import 'package:super_tag_editor/tag_editor.dart';

void main() => runApp(const TagEditorExampleApp());

class TagEditorExampleApp extends StatefulWidget {
  const TagEditorExampleApp({super.key});

  @override
  State<TagEditorExampleApp> createState() => _TagEditorExampleAppState();
}

class _TagEditorExampleAppState extends State<TagEditorExampleApp> {
  final List<String> values = [];

  void onDelete(int index) {
    setState(() => values.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Super Tag Editor Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TagEditor(
            length: values.length,
            delimiters: [',', ' '],
            hasAddButton: true,
            inputDecoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter tags...',
            ),
            onTagChanged: (newValue) {
              setState(() => values.add(newValue));
            },
            tagBuilder: (context, index) => _Chip(
              index: index,
              label: values[index],
              onDeleted: onDelete,
            ),
            suggestionBuilder: (context, state, data) => ListTile(
              key: ObjectKey(data),
              title: Text(data),
              onTap: () => state.selectSuggestion(data),
            ),
            suggestionsBoxElevation: 10,
            findSuggestions: (String query) {
              return ['flutter', 'dart', 'widget', 'state']
                  .where((tag) => tag.contains(query.toLowerCase()))
                  .toList();
            },
          ),
        ),
      ),
    );
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
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => onDeleted(index),
    );
  }
}
```

---

## 🧠 Maintainer

Developed and maintained by [Dat X](https://github.com/dab246).

If you find this package helpful, please consider giving it a ⭐ on [GitHub](https://github.com/dab246/super_tag_editor)!

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

### 🧭 Links

- [Repository](https://github.com/dab246/super_tag_editor)
- [Issue Tracker](https://github.com/dab246/super_tag_editor/issues)
- [Pub.dev Page](https://pub.dev/packages/super_tag_editor)

---

> 💬 “Super Tag Editor makes handling tag inputs in Flutter effortless — it feels native, flexible, and intuitive.”
