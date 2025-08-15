import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// スクリーンショット用の設定クラス
class ScreenshotConfig {
  const ScreenshotConfig({
    required this.imghippoApiKey,
    required this.supportedLocales,
    required this.pages,
    required this.wrapFunction,
    required this.overrides,
    required this.indexToScreenshot,
    this.captureDelay = const Duration(seconds: 3),
    this.uploadDelay = const Duration(seconds: 1),
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.titleStyle,
  });

  final List<int> indexToScreenshot;

  /// APIキー
  final String imghippoApiKey;

  final List<Override> overrides;

  /// スクリーンショットするページのラッパー関数
  final Widget Function(Widget) wrapFunction;

  /// サポートされている言語リスト
  final List<Locale> supportedLocales;

  /// スクリーンショットするページのリスト
  final List<ScreenshotPage> pages;

  /// スクリーンショット間の待機時間（デフォルト3秒）
  final Duration captureDelay;

  /// アップロード時の待機時間（デフォルト1秒）
  final Duration uploadDelay;

  /// 背景色（デフォルトはダークグレー）
  final Color backgroundColor;

  /// タイトルテキストのスタイル
  final TextStyle? titleStyle;
}

/// スクリーンショットするページの情報
class ScreenshotPage {
  const ScreenshotPage({
    required this.name,
    required this.index,
    required this.widget,
    required this.titleTextKey,
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
  final String titleTextKey;

  /// ページ固有のタイトルスタイル（nullの場合はConfigの設定を使用）
  final TextStyle? titleStyle;

  /// ページ固有の背景色（nullの場合はConfigの設定を使用）
  final Color? backgroundColor;
}
