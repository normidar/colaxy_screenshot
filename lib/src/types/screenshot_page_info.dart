import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// スクリーンショットするページの情報
class ScreenshotPageInfo {
  const ScreenshotPageInfo({
    required this.name,
    required this.index,
    required this.widget,
    required this.titleText,
    this.overrides,
    this.titleStyle,
    this.backgroundColor,
  });

  /// ページの名前（ファイル名にも使用される）
  final String name;

  final int index;

  /// ページのWidget
  final Widget Function() widget;

  final List<Override>? overrides;

  /// ページ固有のタイトルテキスト（nullの場合はConfigの設定を使用）
  final String titleText;

  /// ページ固有のタイトルスタイル（nullの場合はConfigの設定を使用）
  final TextStyle? titleStyle;

  /// ページ固有の背景色（nullの場合はConfigの設定を使用）
  final Color? backgroundColor;
}
