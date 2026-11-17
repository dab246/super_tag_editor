import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart' as intl;

abstract class DirectionHelper {
  static bool isDirectionRTLByEndsText(String text) =>
      intl.Bidi.endsWithRtl(text);

  static TextDirection getDirectionByEndsText(String text) =>
      isDirectionRTLByEndsText(text) ? TextDirection.rtl : TextDirection.ltr;
}
