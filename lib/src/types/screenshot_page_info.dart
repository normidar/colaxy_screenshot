import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Information for each page to capture
class ScreenshotPageInfo {
  const ScreenshotPageInfo({
    required this.name,
    required this.index,
    required this.widget,
    required this.titleTextKey,
    this.overrides,
    this.titleStyle,
    this.backgroundColor,
  });

  /// Page name (also used for the file name)
  final String name;

  final int index;

  /// Page widget
  final Widget Function() widget;

  final List<Override>? overrides;

  /// Page-specific title text (uses the config when null)
  final String titleTextKey;

  /// Page-specific title style (uses the config when null)
  final TextStyle? titleStyle;

  /// Page-specific background color (uses the config when null)
  final Color? backgroundColor;
}
