import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Utility functions for ROAST configuration export/import operations
class ROASTConfigUtils {
  /// Generate a descriptive filename for ROAST group configuration export
  /// Format: roast-group-[timestamp].yaml
  static String generateExportFilename() {
    final now = DateTime.now();
    final timestamp = now.toIso8601String().replaceAll(':', '-').split('.')[0];
    return 'roast-group-$timestamp.yaml';
  }

  /// Format timestamp for YAML metadata
  /// Returns ISO 8601 formatted string
  static String formatTimestamp(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Format current timestamp for YAML metadata
  /// Returns ISO 8601 formatted string for current time
  static String formatCurrentTimestamp() {
    return formatTimestamp(DateTime.now());
  }

  /// Get the temporary directory path for storing export files
  /// Returns path where temporary files can be stored before sharing
  static Future<String> getTempDirectoryPath() async {
    final tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  /// Get the full file path for a temporary export file
  /// Combines temp directory with generated filename
  static Future<String> getTempExportFilePath() async {
    final tempPath = await getTempDirectoryPath();
    final filename = generateExportFilename();
    return '$tempPath/$filename';
  }

  /// Check if a file exists at the given path
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return file.exists();
  }

  /// Delete a file at the given path
  /// Used for cleanup after sharing export files
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Validate that a file path has .yaml extension
  static bool hasYamlExtension(String filePath) {
    return filePath.toLowerCase().endsWith('.yaml') || 
           filePath.toLowerCase().endsWith('.yml');
  }

  /// Extract filename from full file path
  static String extractFilename(String filePath) {
    return filePath.split('/').last;
  }

  /// Clean up temporary files older than specified duration
  /// Helps prevent temp directory from filling up with old export files
  static Future<void> cleanupOldTempFiles({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final tempPath = await getTempDirectoryPath();
      final tempDir = Directory(tempPath);
      
      if (await tempDir.exists()) {
        final files = tempDir.listSync()
            .whereType<File>()
            .where((file) => file.path.contains('roast-group-'));
        
        final cutoffTime = DateTime.now().subtract(maxAge);
        
        for (final file in files) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // Ignore cleanup errors - not critical for functionality
    }
  }
}