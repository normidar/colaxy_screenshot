import 'package:colaxy_screenshot/src/types/screenshot_page_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef EasyLocalizationWrapper = EasyLocalization Function(Widget);

/// Configuration class for screenshots
class ScreenshotConfig {
  ScreenshotConfig({
    required this.featureGraphicPage,
    required this.imghippoApiKey,
    required this.supportedLocales,
    required this.pages,
    required this.wrapFunction,
    required this.overrides,
    required this.easyLocalizationWrapper,
    this.captureDelay = const Duration(milliseconds: 500),
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.titleStyle,
  });

  final Widget featureGraphicPage;

  /// API key
  final String imghippoApiKey;

  final List<Override> overrides;

  final EasyLocalizationWrapper easyLocalizationWrapper;

  /// Wrapper function for screenshot pages
  final Widget Function(Widget) wrapFunction;

  /// List of supported locales
  final List<Locale> supportedLocales;

  /// List of pages to capture
  final List<ScreenshotPageInfo> pages;

  /// Delay between screenshots (default 3 seconds)
  Duration captureDelay;

  /// Background color (default dark gray)
  final Color backgroundColor;

  /// Title text style
  final TextStyle? titleStyle;
}
