import 'package:colaxy_screenshot/src/screenshot_result.dart'
    show ScreenshotResult;
import 'package:flutter/material.dart';

/// スクリーンショット結果を表示するページ
class ScreenshotResultPage extends StatelessWidget {
  const ScreenshotResultPage({
    required this.results,
    super.key,
  });

  final Map<String, List<ScreenshotResult>> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スクリーンショット結果'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(),
            const SizedBox(height: 20),
            _buildResultsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return const Center(
      child: Text('結果を表示する'),
    );
  }

  Widget _buildSummary() {
    final allResults = results.values.expand((e) => e).toList();
    final errorCount = allResults.where((r) => r.error != null).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '実行結果',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('合計: ${allResults.length}枚'),
            Text('失敗: $errorCount枚', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
