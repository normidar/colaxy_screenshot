import 'dart:io';
import 'dart:ui' as ui;

import 'package:coglax_screenshot/coglax_screenshot.dart';
import 'package:device_frame_plus/device_frame_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

/// メインのスクリーンショットサービス
class ScreenshotService {
  ScreenshotService(this.config);

  final ScreenshotConfig config;

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
          );
        }
      }
    }
  }

  /// 言語設定を含むアプリウィジェットを構築
  Widget _buildAppWithLocale({
    required Locale locale,
    required ScreenshotPageInfo page,
    required DeviceInfo deviceFrame,
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
                      device: deviceFrame,
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
                page.titleText,
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
  }) async {
    // 一時ファイルに保存
    final directory = await path_provider.getTemporaryDirectory();
    final fileName = '${page.name}_$locale.png';
    final imagePath = await File('${directory.path}/$fileName').create();

    try {
      // デバイスフレームを取得
      final deviceFrame = await _getDeviceFrame();

      // runAppでアプリを起動
      final app = _buildAppWithLocale(
        locale: locale,
        page: page,
        deviceFrame: deviceFrame,
      );
      runApp(app);

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

      await imagePath.writeAsBytes(imageBytes);

      // imghippoにアップロード
      // TODO: セーフ処理
    } finally {
      // 一時ファイルを削除
      if (imagePath.existsSync()) {
        await imagePath.delete();
      }
    }
  }

  /// 現在のデバイスに応じたデバイスフレームを取得
  Future<DeviceInfo> _getDeviceFrame() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      final model = iosInfo.model.toLowerCase();

      // iPadの判定
      if (model.contains('ipad')) {
        return DeviceInfo.genericTablet(
          platform: TargetPlatform.iOS,
          id: 'ipad_pro_11',
          name: 'iPad Pro 11"',
          screenSize: const Size(834, 1194),
          safeAreas: const EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          rotatedSafeAreas: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20,
          ),
        );
      }
    }

    // デフォルトはiPhone（従来の設定）
    return DeviceInfo.genericPhone(
      platform: TargetPlatform.iOS,
      id: 'iphone_13',
      name: 'iPhone 13',
      screenSize: const Size(390, 844),
      safeAreas: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      rotatedSafeAreas: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      pixelRatio: 3,
    );
  }
}
