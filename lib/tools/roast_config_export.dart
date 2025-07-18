import 'dart:io';
import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:peercoin/models/roast_grou_export_config.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/exceptions/roast_config_exceptions.dart';
import 'package:peercoin/tools/roast_config_utils.dart';

/// Core export functionality for ROAST group configurations
class ROASTConfigExport {
  /// Export a ROAST group configuration to YAML file
  ///
  /// Takes the current ROASTWallet data and temporary participants map
  /// and exports them as a YAML file that can be shared with other participants
  ///
  /// Throws [FinalizedGroupException] if trying to export a finalized group
  /// Throws [FileOperationException] if file operations fail
  static Future<String> exportGroupConfiguration(
    ROASTWallet roastWallet,
    Map<Identifier, ECCompressedPublicKey> participants,
  ) async {
    // Validate required fields
    if (roastWallet.serverUrl.isEmpty || roastWallet.groupId.isEmpty) {
      throw const ConfigValidationException(
        'Cannot export incomplete configuration',
        ['Please ensure server URL and group ID are set before exporting.'],
      );
    }

    if (participants.isEmpty) {
      throw const ConfigValidationException(
        'Cannot export empty group',
        ['At least one participant is required for export'],
      );
    }

    try {
      // Create export configuration
      final exportConfig = ROASTGroupExportConfig.fromROASTWallet(
        roastWallet.serverUrl,
        roastWallet.groupId,
        participants,
        roastWallet.participantNames,
      );

      // Convert to YAML string
      final yamlString = _convertToYamlString(exportConfig);

      // Generate file path
      final filePath = await ROASTConfigUtils.getTempExportFilePath();

      // Write to file
      await _writeYamlFile(filePath, yamlString);

      return filePath;
    } catch (e) {
      if (e is ROASTConfigException) {
        rethrow;
      }
      throw FileOperationException(
        'export',
        'Failed to export group configuration: ${e.toString()}',
      );
    }
  }

  /// Share the exported YAML file using the device's share functionality
  ///
  /// Takes a file path and shares it via the system share dialog
  /// Cleans up the temporary file after sharing
  static Future<void> shareExportedFile(String filePath) async {
    try {
      if (!await ROASTConfigUtils.fileExists(filePath)) {
        throw const FileOperationException(
          'share',
          'Export file not found',
        );
      }

      final filename = ROASTConfigUtils.extractFilename(filePath);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'ROAST Group Configuration',
        subject: 'Share ROAST Group Configuration - $filename',
      );

      // Clean up temporary file after sharing
      await ROASTConfigUtils.deleteFile(filePath);
    } catch (e) {
      if (e is ROASTConfigException) {
        rethrow;
      }
      throw FileOperationException(
        'share',
        'Failed to share export file: ${e.toString()}',
        filePath: filePath,
      );
    }
  }

  /// Convert ROASTGroupExportConfig to YAML string with proper formatting
  static String _convertToYamlString(ROASTGroupExportConfig config) {
    final yamlMap = config.toYamlMap();

    // Create formatted YAML string with comments
    final buffer = StringBuffer();

    // Add header comment
    buffer.writeln('# ROAST Group Configuration');
    buffer.writeln('# Generated: ${config.created}');
    buffer.writeln('');

    // Add metadata section
    buffer.writeln('metadata:');
    final metadata = yamlMap['metadata'] as Map<String, dynamic>;
    metadata.forEach((key, value) {
      buffer.writeln('  $key: ${_formatYamlValue(value)}');
    });

    buffer.writeln('');
    buffer.writeln('participants:');

    // Add participants section
    final participants = yamlMap['participants'] as List<dynamic>;
    for (final participant in participants) {
      final participantMap = participant as Map<String, dynamic>;
      buffer.writeln('  - name: ${_formatYamlValue(participantMap['name'])}');
      buffer.writeln(
          '    identifier: ${_formatYamlValue(participantMap['identifier'])}');
      buffer.writeln(
          '    public_key: ${_formatYamlValue(participantMap['public_key'])}');
      if (participant != participants.last) {
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  /// Format a value for YAML output with proper quoting
  static String _formatYamlValue(dynamic value) {
    if (value is String) {
      // Quote strings that contain special characters or are empty
      if (value.isEmpty ||
          value.contains(':') ||
          value.contains('#') ||
          value.contains('[') ||
          value.contains(']') ||
          value.contains('{') ||
          value.contains('}') ||
          value.startsWith(' ') ||
          value.endsWith(' ')) {
        return '"$value"';
      }
      return value;
    }
    return value.toString();
  }

  /// Write YAML string to file
  static Future<void> _writeYamlFile(
      String filePath, String yamlContent) async {
    try {
      final file = File(filePath);
      await file.writeAsString(yamlContent);
    } catch (e) {
      throw FileOperationException(
        'write',
        'Failed to write YAML file: ${e.toString()}',
        filePath: filePath,
      );
    }
  }

  /// Get export preview for UI display
  /// Returns a summary of what will be exported without actually creating the file
  static Map<String, dynamic> getExportPreview(
    ROASTWallet roastWallet,
    Map<Identifier, ECCompressedPublicKey> participants,
  ) {
    return {
      'serverUrl': roastWallet.serverUrl,
      'groupId': roastWallet.groupId,
      'participantCount': participants.length,
      'participants': participants.entries.map((entry) {
        final identifier = entry.key;
        final name =
            roastWallet.participantNames[identifier.toString()] ?? 'Unknown';
        return {
          'name': name,
          'identifier': identifier.toString(),
        };
      }).toList(),
      'filename': ROASTConfigUtils.generateExportFilename(),
    };
  }
}
