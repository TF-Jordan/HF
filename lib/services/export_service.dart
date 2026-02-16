import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/gesture_sample.dart';

/// Handles exporting collected gesture data to JSON.
class ExportService {
  /// Build a JSON string from all collected samples, grouped by label.
  String buildJson({
    required List<String> labels,
    required Map<String, List<GestureSample>> samplesByLabel,
  }) {
    final labelEntries = <Map<String, dynamic>>[];
    int labelId = 1;
    int exportTotalSamples = 0;

    for (final label in labels) {
      final allSamples = samplesByLabel[label];
      if (allSamples == null || allSamples.isEmpty) continue;

      final samples = allSamples.where((s) => !s.isEmpty).toList();
      if (samples.isEmpty) continue;

      int totalPoints = 0;
      int totalDuration = 0;

      final sampleMaps = samples.map((sample) {
        totalDuration += sample.durationMs;
        totalPoints += sample.pointCount;
        return {
          'sample_id': sample.sampleId,
          'duration_ms': sample.durationMs,
          'data_points': sample.dataPoints,
        };
      }).toList();

      final avgDuration =
          samples.isEmpty ? 0.0 : totalDuration / samples.length;

      labelEntries.add({
        'id': labelId++,
        'label': label,
        'timestamp': samples.first.startedAtIso,
        'sample_count': samples.length,
        'samples': sampleMaps,
        'metadata': {
          'target_sample_count': AppConstants.collectionTargetPoints,
          'avg_duration_ms': avgDuration,
          'total_data_points': totalPoints,
        },
      });
      exportTotalSamples += samples.length;
    }

    if (labelEntries.isEmpty) return '';

    final export = {
      'export_date': DateTime.now().toIso8601String(),
      'total_records': labelEntries.length,
      'total_samples': exportTotalSamples,
      'labels': labelEntries,
    };
    return const JsonEncoder.withIndent('  ').convert(export);
  }

  /// Generate a timestamped filename.
  String generateFileName() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return 'gesture_data_${y}${m}${d}_$hh$mm$ss.json';
  }

  /// Copy the JSON content to the system clipboard.
  /// Returns true on success, false on failure.
  Future<bool> copyToClipboard(String content) async {
    try {
      await Clipboard.setData(ClipboardData(text: content));
      return true;
    } catch (e) {
      debugPrint('Clipboard error: $e');
      return false;
    }
  }

  /// Write the JSON content to a file and return the path, or null on failure.
  Future<String?> writeToFile(String filename, String content) async {
    final directories = await _getExportDirectories();

    for (final dir in directories) {
      try {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/$filename');
        await file.writeAsString(content);
        // Verify the file was actually written.
        if (await file.exists() && await file.length() > 0) {
          debugPrint('Export success: ${file.path}');
          return file.path;
        }
      } catch (e) {
        debugPrint('Export failed to ${dir.path}: $e');
        continue;
      }
    }
    debugPrint('All export directories failed');
    return null;
  }

  /// Returns a prioritized list of export directories to try.
  Future<List<Directory>> _getExportDirectories() async {
    final dirs = <Directory>[];

    // 1. Android Downloads
    if (Platform.isAndroid) {
      dirs.add(Directory('/storage/emulated/0/Download'));
    }

    // 2. External storage (Android)
    try {
      final external = await getExternalStorageDirectory();
      if (external != null) dirs.add(external);
    } catch (_) {}

    // 3. Application documents directory (all platforms)
    try {
      dirs.add(await getApplicationDocumentsDirectory());
    } catch (_) {}

    // 4. Temp directory as last resort
    try {
      dirs.add(await getTemporaryDirectory());
    } catch (_) {}

    return dirs;
  }
}
