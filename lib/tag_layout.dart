import 'package:flutter/material.dart';
import './tag_editor_layout_delegate.dart';
import './tag_render_layout_box.dart';

/// This is just a normal [CustomMultiChildLayout] with
/// overrided [createRenderObject] to use custom [RenderCustomMultiChildLayoutBox]
class TagLayout extends CustomMultiChildLayout {
  const TagLayout({
    super.key,
    required TagEditorLayoutDelegate super.delegate,
    super.children,
  });

  @override
  TagRenderLayoutBox createRenderObject(BuildContext context) {
    return TagRenderLayoutBox(delegate: delegate as TagEditorLayoutDelegate);
  }
}
