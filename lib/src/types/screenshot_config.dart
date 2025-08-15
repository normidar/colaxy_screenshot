import 'package:coglax_screenshot/src/types/screenshot_page_info.dart';
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
  final List<ScreenshotPageInfo> pages;

  /// スクリーンショット間の待機時間（デフォルト3秒）
  final Duration captureDelay;

  /// アップロード時の待機時間（デフォルト1秒）
  final Duration uploadDelay;

  /// 背景色（デフォルトはダークグレー）
  final Color backgroundColor;

  /// タイトルテキストのスタイル
  final TextStyle? titleStyle;
}
