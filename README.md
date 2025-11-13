# colaxy_screenshot

[![GitHub](https://img.shields.io/github/license/normidar/colaxy_screenshot.svg)](https://github.com/normidar/colaxy_screenshot/blob/main/LICENSE)
[![pub package](https://img.shields.io/pub/v/colaxy_screenshot.svg)](https://pub.dartlang.org/packages/colaxy_screenshot)
[![GitHub Stars](https://img.shields.io/github/stars/normidar/colaxy_screenshot.svg)](https://github.com/normidar/colaxy_screenshot/stargazers)
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/normidar.svg?style=social&label=Follow%20%40normidar)](https://twitter.com/normidar2)
[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/normidar)

A powerful Flutter package for automated screenshot generation for App Store and Google Play Store listings. Generate beautiful, consistent screenshots across multiple devices, languages, and platforms with ease.

## Features

✨ **Multi-platform Support**: Generate screenshots for both iOS and Android  
🌍 **Multi-language Support**: Support for Japanese, English, and Chinese  
📱 **Device Compatibility**: Phone and tablet screenshot generation  
🎨 **Marketing Layouts**: Beautiful backgrounds and titles for app store listings  
🚀 **Fastlane Integration**: Direct integration with Fastlane for automated app store uploads  
⚙️ **Highly Configurable**: Customizable layouts, delays, and overrides  
🎯 **Device Frame Support**: Realistic device frames using device_frame_plus

## Installation

Run the following command:

```sh
flutter pub add colaxy_screenshot
```

## Setup

### 1. Add Configuration File

Create `assets/config.yaml` in your project:

```yaml
app_path: "/path/to/your/app"
launch_mode: "screenshot" # Set to "screenshot" to enable screenshot mode
```

### 2. Add Translation Files

Create translation files in `assets/translations/`:

- `assets/translations/en.json`
- `assets/translations/ja.json`
- `assets/translations/zh.json`

Example `en.json`:

```json
{
  "welcome_title": "Welcome to Our App",
  "features_title": "Amazing Features",
  "settings_title": "Customize Your Experience"
}
```

### 3. Update pubspec.yaml

```yaml
flutter:
  assets:
    - assets/config.yaml
    - assets/translations/
```

## Usage

### Basic Setup

```dart
import 'package:colaxy_screenshot/colaxy_screenshot.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if screenshot mode is enabled
  if (await checkScreenshotRunable()) {
    await takeScreenshots(ScreenshotConfig(
      imghippoApiKey: "your-api-key",
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ja', 'JP'),
        Locale('zh', 'CN'),
      ],
      pages: [
        ScreenshotPageInfo(
          name: "welcome",
          index: 1,
          titleTextKey: "welcome_title",
          widget: () => const WelcomeScreen(),
        ),
        ScreenshotPageInfo(
          name: "features",
          index: 2,
          titleTextKey: "features_title",
          widget: () => const FeaturesScreen(),
        ),
      ],
      wrapFunction: (child) => MaterialApp(
        home: child,
        theme: ThemeData.light(),
      ),
      overrides: [], // Riverpod overrides if needed
    ));
    return;
  }

  // Normal app launch
  runApp(MyApp());
}
```

### Advanced Configuration

```dart
ScreenshotConfig(
  // ... basic config
  captureDelay: const Duration(milliseconds: 1000), // Wait time between screenshots
  backgroundColor: const Color(0xFF1E1E1E), // Background color
  titleStyle: const TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)
```

### Page Configuration with Overrides

```dart
ScreenshotPageInfo(
  name: "profile",
  index: 3,
  titleTextKey: "profile_title",
  widget: () => const ProfileScreen(),
  overrides: [
    // Riverpod overrides for this specific page
    userProvider.overrideWith((ref) => mockUser),
  ],
  backgroundColor: Colors.purple,
  titleStyle: const TextStyle(color: Colors.white),
)
```

## Output Structure

Screenshots are automatically organized for Fastlane:

```
your_app/
├── fastlane/
│   ├── screenshots/
│   │   ├── en-US/
│   │   │   ├── 1_iphone65_1.welcome.png
│   │   │   └── 1_ipadPro129_1.welcome.png
│   │   ├── ja/
│   │   └── zh-Hans/
│   └── metadata/
│       └── android/
│           ├── en-US/images/phoneScreenshots/
│           ├── ja-JP/images/phoneScreenshots/
│           └── zh-CN/images/phoneScreenshots/
```

## Supported Devices

### Phone Screenshots

- **iOS**: iPhone 13 (1284×2778)
- **Android**: Phone screenshots (1284×2778)

### Tablet Screenshots

- **iOS**: iPad Pro 11" (2048×2732)
- **Android**: 7-inch and 10-inch tablets (2048×2732)

## Configuration Options

| Parameter          | Type                     | Description                                |
| ------------------ | ------------------------ | ------------------------------------------ |
| `imghippoApiKey`   | String                   | API key for image uploading service        |
| `supportedLocales` | List<Locale>             | Languages to generate screenshots for      |
| `pages`            | List<ScreenshotPageInfo> | Pages to screenshot                        |
| `wrapFunction`     | Widget Function(Widget)  | Wrapper function for your app              |
| `overrides`        | List<Override>           | Global Riverpod overrides                  |
| `captureDelay`     | Duration                 | Delay between screenshots (default: 500ms) |
| `backgroundColor`  | Color                    | Background color (default: dark gray)      |
| `titleStyle`       | TextStyle?               | Global title text style                    |

## Requirements

- **Platform**: macOS only (for development)
- **Mode**: Debug mode only
- **Flutter**: >=1.17.0
- **Dart**: ^3.0.0

## Example Project Structure

```dart
// screens/welcome_screen.dart
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'welcome_message'.tr(), // Using easy_localization
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Tips & Best Practices

1. **Use descriptive page names** for easy identification in app stores
2. **Test with different locales** to ensure text fits properly
3. **Use consistent branding** across all screenshots
4. **Keep titles concise** for better readability
5. **Test on both orientations** if your app supports rotation

## Dependencies

This package relies on several key Flutter packages:

- `device_frame_plus`: For realistic device frames
- `easy_localization`: For internationalization
- `flutter_riverpod`: For state management
- `screenshot`: For image capture
- `image`: For image processing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you find this package helpful, consider:

- ⭐ Starring the repository
- 🐛 Reporting issues
- 💡 Suggesting new features
- ☕ [Sponsoring the developer](https://github.com/sponsors/normidar)
