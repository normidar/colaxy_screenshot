import 'dart:io';
import 'dart:ui' as ui;

import 'package:coglax_screenshot/coglax_screenshot.dart';
import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Android用のロケールマッピング
const _androidLocaleMap = {'en': 'en-US', 'ja': 'ja-JP', 'zh': 'zh-CN'};

/// iOS用のロケールマッピング
const _iOSLocaleMap = {'en': 'en-US', 'ja': 'ja', 'zh': 'zh-Hans'};

/// メインのスクリーンショットサービス
class ScreenshotService {
  ScreenshotService({required this.config, required this.appPath});

  final ScreenshotConfig config;

  final String appPath;

  GlobalKey? _appKey;

  /// スクリーンショットを実行する
  Future<void> executeScreenshots() async {
    // 各デバイス × 各言語 × 各ページの組み合わせでスクリーンショットを作成
    for (final mode in ScreenshotModeInfo.all) {
      mode.setWindowToSize();
      for (final locale in config.supportedLocales) {
        for (final page in config.pages) {
          // スクリーンショットするインデックスに含まれていない場合はスキップ
          if (!config.indexToScreenshot.contains(page.index)) {
            continue;
          }

          await _capturePageScreenshot(
            locale: locale,
            page: page,
            modeInfo: mode,
          );
        }
      }
    }
  }

  /// 言語設定を含むアプリウィジェットを構築
  Widget _buildAppWithLocale({
    required Locale locale,
    required ScreenshotPageInfo page,
    required ScreenshotModeInfo modeInfo,
  }) {
    _appKey = GlobalKey();

    final Widget appWidget = ProviderScope(
      overrides: [
        ...config.overrides,
        ...page.overrides ?? [],
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('ja', 'JP'),
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: Builder(
          builder: (context) {
            return FutureBuilder(
              future: () async {
                Intl.defaultLocale = locale.languageCode;
                await context.setLocale(locale);
                return null;
              }(),
              builder: (_, __) => config.wrapFunction(
                _buildMarketingLayout(
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: DeviceFrame(
                      device: modeInfo.toDeviceInfo(),
                      screen: page.widget(),
                    ),
                  ),
                  page,
                ),
              ),
            );
          },
        ),
      ),
    );

    return RepaintBoundary(
      key: _appKey,
      child: appWidget,
    );
  }

  /// マーケティング用のレイアウトを構築（背景 + タイトル + デバイスフレーム）
  Widget _buildMarketingLayout(Widget deviceFrame, ScreenshotPageInfo page) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        width: 1080, // 一般的なスクリーンショットサイズ
        height: 1920,
        color: const ui.Color.fromARGB(255, 216, 255, 239),
        child: Column(
          children: [
            // 上部のタイトルエリア
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 80, 40, 20),
              child: Text(
                page.titleTextKey.tr(),
                style: const TextStyle(
                  color: ui.Color.fromARGB(255, 25, 178, 255),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // デバイスフレーム（中央配置）
            Expanded(
              child: Center(
                child: deviceFrame,
              ),
            ),

            // 下部のスペース
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// 単一ページのスクリーンショットを撮影してアップロード
  Future<void> _capturePageScreenshot({
    required Locale locale,
    required ScreenshotPageInfo page,
    required ScreenshotModeInfo modeInfo,
  }) async {
    // runAppでアプリを起動
    final app =
        _buildAppWithLocale(locale: locale, page: page, modeInfo: modeInfo);

    print('before runApp');
    runApp(app);
    print('after runApp');

    // アプリが完全に描画されるまで待機
    await Future<void>.delayed(config.captureDelay);

    // フレームのコールバックを待機して描画が完了することを確認
    await WidgetsBinding.instance.endOfFrame;

    // RepaintBoundaryからスクリーンショットを取得
    Uint8List? imageBytes;
    final currentContext = _appKey?.currentContext;
    if (currentContext != null && currentContext.mounted) {
      final boundary =
          currentContext.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      imageBytes = byteData?.buffer.asUint8List();
    }

    if (imageBytes == null) {
      throw Exception('スクリーンショットの撮影に失敗しました');
    }
    // TODO: セーフ処理
    final index = page.index;
    final screenshotData = page.name;
    switch (modeInfo.mode) {
      case ScreenshotMode.phone:
        final iOSLocaleName = _iOSLocaleMap[locale.languageCode] ?? 'en-US';
        final iphonePath =
            '$appPath/fastlane/screenshots/$iOSLocaleName/${index}_iphone65_$index.$screenshotData.png';
        print('iphonePath: $iphonePath');
        File(iphonePath).writeAsBytesSync(imageBytes);
      case ScreenshotMode.tablet:
    }
  }
}
