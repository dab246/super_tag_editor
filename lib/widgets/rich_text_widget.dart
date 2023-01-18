import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RichTextWidget extends StatelessWidget {
  final String textOrigin;
  final String wordSearched;
  final TextStyle? styleTextOrigin;
  final TextStyle? styleWordSearched;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const RichTextWidget(
      {Key? key,
      required this.textOrigin,
      required this.wordSearched,
      this.styleTextOrigin,
      this.styleWordSearched,
      this.maxLines,
      this.overflow,
      this.softWrap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wordSearched.isEmpty) {
      return Text(textOrigin,
          maxLines: maxLines ?? 1,
          softWrap: softWrap ?? kIsWeb ? false : true,
          overflow:
              overflow ?? (kIsWeb ? TextOverflow.fade : TextOverflow.ellipsis),
          style: styleTextOrigin ??
              const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal));
    } else {
      return RichText(
          maxLines: maxLines ?? 1,
          softWrap: softWrap ?? kIsWeb ? false : true,
          overflow:
              overflow ?? (kIsWeb ? TextOverflow.fade : TextOverflow.ellipsis),
          text: TextSpan(
              style: styleTextOrigin ??
                  const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
              children: _getSpans(
                  textOrigin,
                  wordSearched,
                  styleWordSearched ??
                      const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold))));
    }
  }

  List<TextSpan> _getSpans(String text, String matchWord, TextStyle style) {
    var spans = <TextSpan>[];
    var spanBoundary = 0;
    do {
      // look for the next match
      final startIndex =
          text.toLowerCase().indexOf(matchWord.toLowerCase(), spanBoundary);
      // if no more matches then add the rest of the string without style
      if (startIndex == -1) {
        spans.add(TextSpan(text: text.substring(spanBoundary)));
        return spans;
      }
      // add any unStyled text before the next match
      if (startIndex > spanBoundary) {
        spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));
      }
      // style the matched text
      final endIndex = startIndex + matchWord.length;
      final spanText = text.substring(startIndex, endIndex);
      spans.add(TextSpan(text: spanText, style: style));
      // mark the boundary to start the next search from
      spanBoundary = endIndex;
      // continue until there are no more matches
    } while (spanBoundary < text.length);

    return spans;
  }
}
