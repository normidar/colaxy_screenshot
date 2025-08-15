import 'dart:ui' show Locale;

/// スクリーンショット結果
class ScreenshotResult {
  const ScreenshotResult({
    required this.pageName,
    required this.locale,
    this.error,
  });
  final String pageName;
  final Locale locale;

  final String? error;

  Map<String, dynamic> toJson() => {
        'pageName': pageName,
        'locale': locale.toString(),
        'error': error,
      };
}
