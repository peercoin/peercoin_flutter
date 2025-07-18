import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:peercoin/models/roast_grou_export_config.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/exceptions/roast_config_exceptions.dart';
import 'package:peercoin/tools/roast_config_utils.dart';

/// Core import functionality for ROAST group configurations
class ROASTConfigImport {
  /// Import a ROAST group configuration from YAML file
  ///
  /// Prompts user to select a YAML file, parses it, validates the structure,
  /// and returns the configuration data ready for use in ROASTWallet
  ///
  /// Throws [InvalidYAMLFormatException] if YAML parsing fails
  /// Throws [ConfigValidationException] if validation fails
  /// Throws [FileOperationException] if file operations fail
  static Future<ROASTGroupImportResult> importGroupConfiguration() async {
    try {
      // Let user select YAML file
      final filePath = await _selectYamlFile();
      if (filePath == null) {
        throw const FileOperationException(
          'select',
          'No file selected for import',
        );
      }

      // Read and parse YAML file
      final yamlContent = await _readYamlFile(filePath);
      final parsedYaml = await _parseYamlContent(yamlContent);

      // Create export config from parsed YAML (this will throw if structure is wrong)
      final exportConfig = ROASTGroupExportConfig.fromYamlMap(parsedYaml);

      // Validate the configuration
      await _validateConfiguration(exportConfig);

      // Convert to participants maps for ROASTWallet
      final participantsMap = exportConfig.toParticipantsMap();
      final participantNamesMap = exportConfig.toParticipantNamesMap();

      return ROASTGroupImportResult(
        serverUrl: exportConfig.serverUrl,
        groupId: exportConfig.groupId,
        participants: participantsMap,
        participantNames: participantNamesMap,
        participantCount: exportConfig.participants.length,
        created: exportConfig.created,
      );
    } catch (e) {
      if (e is ROASTConfigException) {
        rethrow;
      }
      throw FileOperationException(
        'import',
        'Failed to import group configuration: ${e.toString()}',
      );
    }
  }

  /// Select YAML file using file picker
  static Future<String?> _selectYamlFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['yaml', 'yml'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return file.path!;
        }
      }
      return null;
    } catch (e) {
      throw FileOperationException(
        'select',
        'Failed to select file: ${e.toString()}',
      );
    }
  }

  /// Read YAML file content
  static Future<String> _readYamlFile(String filePath) async {
    try {
      // Validate file extension
      if (!ROASTConfigUtils.hasYamlExtension(filePath)) {
        throw const InvalidYAMLFormatException(
          'Invalid file type. Please select a YAML configuration file (.yaml or .yml).',
        );
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw FileOperationException(
          'read',
          'Configuration file not found. Please check the file path and try again.',
          filePath: filePath,
        );
      }

      // Check file size (prevent loading extremely large files)
      final fileStat = await file.stat();
      if (fileStat.size > 10 * 1024 * 1024) {
        // 10MB limit
        throw const FileOperationException(
          'read',
          'Configuration file is too large. Maximum size is 10MB.',
        );
      }

      if (fileStat.size == 0) {
        throw const InvalidYAMLFormatException(
          'Configuration file is empty. Please select a valid YAML file.',
        );
      }

      final content = await file.readAsString();

      // Additional content validation
      if (content.trim().isEmpty) {
        throw const InvalidYAMLFormatException(
          'Configuration file contains no data. Please select a valid YAML file.',
        );
      }

      return content;
    } catch (e) {
      if (e is ROASTConfigException) {
        rethrow;
      }

      // Handle specific file system errors
      if (e.toString().contains('Permission denied')) {
        throw FileOperationException(
          'read',
          'Permission denied. Please check file permissions and try again.',
          filePath: filePath,
        );
      }

      if (e.toString().contains('No such file')) {
        throw FileOperationException(
          'read',
          'File not found. Please check the file path and try again.',
          filePath: filePath,
        );
      }

      throw FileOperationException(
        'read',
        'Failed to read configuration file: ${e.toString()}',
        filePath: filePath,
      );
    }
  }

  /// Parse YAML content with immediate failure on parsing errors
  static Future<Map<String, dynamic>> _parseYamlContent(
      String yamlContent) async {
    try {
      // Check for empty or whitespace-only content
      if (yamlContent.trim().isEmpty) {
        throw const InvalidYAMLFormatException(
          'The configuration file is empty or contains only whitespace.',
        );
      }

      final yamlDoc = loadYaml(yamlContent);

      if (yamlDoc == null) {
        throw const InvalidYAMLFormatException(
          'The configuration file contains no valid YAML data.',
        );
      }

      if (yamlDoc is! Map) {
        throw const InvalidYAMLFormatException(
          'Invalid YAML structure. Expected a configuration object at root level.',
        );
      }

      // Convert YamlMap to regular Map<String, dynamic>
      return Map<String, dynamic>.from(yamlDoc);
    } catch (e) {
      if (e is YamlException) {
        // Parse YamlException details for more specific error messages
        final String specificError = _parseYamlError(e);
        throw InvalidYAMLFormatException(
          'Invalid YAML format: $specificError',
          details: e.message,
        );
      }
      if (e is ROASTConfigException) {
        rethrow;
      }
      throw InvalidYAMLFormatException(
        'Failed to parse YAML content: ${e.toString()}',
      );
    }
  }

  /// Parse YamlException to provide more specific error messages
  static String _parseYamlError(YamlException e) {
    final message = e.message.toLowerCase();

    if (message.contains('unexpected character')) {
      return 'Unexpected character found. Please check for special characters or formatting issues.';
    }
    if (message.contains('expected') && message.contains('found')) {
      return 'YAML syntax error. Please check indentation and structure.';
    }
    if (message.contains('duplicate key')) {
      return 'Duplicate key found. Each field name must be unique.';
    }
    if (message.contains('invalid')) {
      return 'Invalid YAML syntax. Please check the file format.';
    }
    if (message.contains('indent')) {
      return 'Incorrect indentation. Please use consistent spacing.';
    }

    return 'YAML parsing error. Please check the file format and structure.';
  }

  /// Validate configuration structure and content
  static Future<void> _validateConfiguration(
      ROASTGroupExportConfig config) async {
    final List<String> validationErrors = [];

    // Validate required fields
    if (config.serverUrl.isEmpty ||
        config.groupId.isEmpty ||
        config.participants.isEmpty) {
      throw const ConfigValidationException(
        'Invalid configuration file',
        [
          'The configuration file is missing required information. Please use a valid exported configuration file.'
        ],
      );
    }

    // Validate participants
    final Set<String> seenIdentifiers = {};
    final Set<String> seenNames = {};

    for (int i = 0; i < config.participants.length; i++) {
      final participant = config.participants[i];

      // Check for duplicate identifiers
      if (seenIdentifiers.contains(participant.identifier)) {
        throw const ConfigValidationException(
          'Invalid configuration file',
          [
            'The configuration file contains duplicate participants. Please use a valid exported configuration file.'
          ],
        );
      }
      seenIdentifiers.add(participant.identifier);

      // Check for duplicate names (if names are provided)
      if (participant.name.isNotEmpty) {
        if (seenNames.contains(participant.name)) {
          throw const ConfigValidationException(
            'Invalid configuration file',
            [
              'The configuration file contains duplicate participants. Please use a valid exported configuration file.'
            ],
          );
        }
        seenNames.add(participant.name);
      }

      // Validate identifier and public key format
      try {
        Identifier.fromHex(participant.identifier);
        ECCompressedPublicKey.fromHex(participant.publicKey);
      } catch (e) {
        throw const ConfigValidationException(
          'Invalid configuration file',
          [
            'The configuration file contains invalid participant data. Please use a valid exported configuration file.'
          ],
        );
      }
    }

    // Throw validation errors if any
    if (validationErrors.isNotEmpty) {
      throw ConfigValidationException(
        'Configuration validation failed',
        validationErrors,
      );
    }
  }

  /// Get import preview for UI display
  /// Shows what will be imported without actually importing
  static Future<Map<String, dynamic>?> getImportPreview(String filePath) async {
    try {
      final yamlContent = await _readYamlFile(filePath);
      final parsedYaml = await _parseYamlContent(yamlContent);
      final exportConfig = ROASTGroupExportConfig.fromYamlMap(parsedYaml);

      return {
        'serverUrl': exportConfig.serverUrl,
        'groupId': exportConfig.groupId,
        'participantCount': exportConfig.participants.length,
        'created': exportConfig.created,
        'participants': exportConfig.participants
            .map((p) => {
                  'name': p.name,
                  'identifier':
                      '${p.identifier.substring(0, 8)}...', // Truncate for display
                })
            .toList(),
      };
    } catch (e) {
      return null; // Return null on error, let caller handle
    }
  }
}

/// Result class for import operations
class ROASTGroupImportResult {
  final String serverUrl;
  final String groupId;
  final Map<Identifier, ECCompressedPublicKey> participants;
  final Map<String, String> participantNames;
  final int participantCount;
  final String version;
  final String created;

  ROASTGroupImportResult({
    required this.serverUrl,
    required this.groupId,
    required this.participants,
    required this.participantNames,
    required this.participantCount,
    required this.version,
    required this.created,
  });

  /// Apply the imported configuration to a ROASTWallet
  void applyToROASTWallet(ROASTWallet roastWallet) {
    roastWallet.serverUrl = serverUrl;
    roastWallet.groupId = groupId;
    roastWallet.participantNames = participantNames;
    // Note: participants map is applied separately in the UI layer
  }
}
