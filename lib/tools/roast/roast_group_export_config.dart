import 'dart:io';
import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:peercoin/models/hive/roast_wallet.dart';
import 'package:peercoin/tools/roast_config_utils.dart';
import 'package:peercoin/exceptions/roast_config_exceptions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yaml/yaml.dart';

/// Simple data classes for YAML serialization of ROAST group configuration
/// Works with existing ROASTWallet and Map<Identifier, ECCompressedPublicKey> _participants

/// Configuration model for exporting/importing unfinalized ROAST group data
class ROASTGroupExportConfig {
  final String created;
  final String serverUrl;
  final String groupId;
  final List<ROASTParticipantExportConfig> participants;

  ROASTGroupExportConfig({
    required this.created,
    required this.serverUrl,
    required this.groupId,
    required this.participants,
  });

  /// Convert to YAML-compatible map structure
  Map<String, dynamic> toYamlMap() {
    return {
      'metadata': {
        'created': created,
        'server_url': serverUrl,
        'group_id': groupId,
        'participant_count': participants.length,
      },
      'participants': participants.map((p) => p.toYamlMap()).toList(),
    };
  }

  /// Create from YAML-compatible map structure
  factory ROASTGroupExportConfig.fromYamlMap(Map<String, dynamic> yamlMap) {
    final metadata = yamlMap['metadata'] as Map<String, dynamic>;
    final participantsList = yamlMap['participants'] as List<dynamic>;

    return ROASTGroupExportConfig(
      created: metadata['created']?.toString() ?? '',
      serverUrl: metadata['server_url']?.toString() ?? '',
      groupId: metadata['group_id']?.toString() ?? '',
      participants: participantsList
          .map(
            (p) => ROASTParticipantExportConfig.fromYamlMap(
              p as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  /// Create from ROASTWallet and temporary participants map
  factory ROASTGroupExportConfig.fromROASTWallet(
    String serverUrl,
    String groupId,
    Map<Identifier, ECCompressedPublicKey> participants,
    Map<String, String> participantNames,
  ) {
    final now = DateTime.now().toIso8601String();

    final participantConfigs = participants.entries.map((entry) {
      final identifier = entry.key;
      final publicKey = entry.value;
      final name = participantNames[identifier.toString()] ?? '';

      return ROASTParticipantExportConfig(
        name: name,
        identifier: identifier.toString(),
        publicKey: publicKey.hex,
      );
    }).toList();

    return ROASTGroupExportConfig(
      created: now,
      serverUrl: serverUrl,
      groupId: groupId,
      participants: participantConfigs,
    );
  }

  /// Convert to participants map for importing into ROASTWallet
  Map<Identifier, ECCompressedPublicKey> toParticipantsMap() {
    final Map<Identifier, ECCompressedPublicKey> participantsMap = {};

    for (final participant in participants) {
      try {
        final identifier = Identifier.fromHex(participant.identifier);
        final publicKey = ECCompressedPublicKey.fromHex(participant.publicKey);
        participantsMap[identifier] = publicKey;
      } catch (e) {
        // Skip invalid participants - will be handled by validation
        continue;
      }
    }

    return participantsMap;
  }

  /// Convert to participant names map for importing into ROASTWallet
  Map<String, String> toParticipantNamesMap() {
    final Map<String, String> namesMap = {};

    for (final participant in participants) {
      if (participant.name.isNotEmpty) {
        namesMap[participant.identifier] = participant.name;
      }
    }

    return namesMap;
  }

  /// Export a ROAST group configuration to YAML file
  static Future<String> exportGroupConfiguration(
    ROASTWallet roastWallet,
    Map<Identifier, ECCompressedPublicKey> participants,
  ) async {
    if (participants.isEmpty) {
      throw const ConfigValidationException(
        'Cannot export empty group',
        ['At least one participant is required for export'],
      );
    }
    try {
      final exportConfig = ROASTGroupExportConfig.fromROASTWallet(
        roastWallet.serverUrl,
        roastWallet.groupId,
        participants,
        roastWallet.participantNames,
      );
      final yamlString = _convertToYamlString(exportConfig);
      final filePath = await ROASTConfigUtils.getTempExportFilePath();
      await _writeYamlFile(filePath, yamlString);
      return filePath;
    } catch (e) {
      if (e is ROASTConfigException) rethrow;
      throw FileOperationException(
        'export',
        'Failed to export group configuration: [${e.toString()}]',
      );
    }
  }

  /// Share the exported YAML file using the device's share functionality
  static Future<void> shareExportedFile(String filePath) async {
    try {
      if (!await ROASTConfigUtils.fileExists(filePath)) {
        throw const FileOperationException(
          'share',
          'Export file not found',
        );
      }
      final filename = ROASTConfigUtils.extractFilename(filePath);
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'ROAST Group Configuration',
        subject: 'Share ROAST Group Configuration - $filename',
      );
      await ROASTConfigUtils.deleteFile(filePath);
    } catch (e) {
      if (e is ROASTConfigException) rethrow;
      throw FileOperationException(
        'share',
        'Failed to share export file: ${e.toString()}',
        filePath: filePath,
      );
    }
  }

  /// Get export preview for UI display
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

  static String _convertToYamlString(ROASTGroupExportConfig config) {
    final yamlMap = config.toYamlMap();
    final buffer = StringBuffer();
    buffer.writeln('# ROAST Group Configuration');
    buffer.writeln('# Generated: ${config.created}');
    buffer.writeln('');
    buffer.writeln('metadata:');
    final metadata = yamlMap['metadata'] as Map<String, dynamic>;
    metadata.forEach((key, value) {
      buffer.writeln('  $key: ${_formatYamlValue(value)}');
    });
    buffer.writeln('');
    buffer.writeln('participants:');
    final participants = yamlMap['participants'] as List<dynamic>;
    for (final participant in participants) {
      final participantMap = participant as Map<String, dynamic>;
      buffer.writeln('  - name: ${_formatYamlValue(participantMap['name'])}');
      buffer.writeln(
        '    identifier: ${_formatYamlValue(participantMap['identifier'])}',
      );
      buffer.writeln(
        '    public_key: ${_formatYamlValue(participantMap['public_key'])}',
      );
      if (participant != participants.last) {
        buffer.writeln('');
      }
    }
    return buffer.toString();
  }

  static String _formatYamlValue(dynamic value) {
    if (value == null) return '~'; // YAML null

    // For non-string values, just return as-is
    if (value is! String) {
      return value.toString();
    }

    // For empty strings
    if (value.isEmpty) return '""';

    // For strings that don't need quoting, return as-is
    // This regex matches strings that are safe to use unquoted in YAML
    // Including ISO date strings (with colons and dashes)
    if (RegExp(r'^[a-zA-Z0-9._/:+-]+$').hasMatch(value)) {
      return value;
    }

    // For everything else, use double quotes and escape properly
    // Escape backslashes and double quotes
    final escaped = value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    return '"$escaped"';
  }

  static Future<void> _writeYamlFile(
    String filePath,
    String yamlContent,
  ) async {
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

  /// Import a ROAST group configuration from YAML file
  static Future<ROASTGroupImportResult> importGroupConfiguration() async {
    try {
      final filePath = await _selectYamlFile();
      if (filePath == null) {
        throw const FileOperationException(
          'select',
          'No file selected for import',
        );
      }
      final yamlContent = await _readYamlFile(filePath);
      final parsedYaml = await _parseYamlContent(yamlContent);
      final exportConfig = ROASTGroupExportConfig.fromYamlMap(parsedYaml);
      await _validateConfiguration(exportConfig);
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
      LoggerWrapper.logError(
        'ROASTGroupExportConfig',
        'importGroupConfiguration',
        'Error importing group configuration: ${e.toString()}',
      );
      if (e is ROASTConfigException) rethrow;
      throw FileOperationException(
        'import',
        'Failed to import group configuration: ${e.toString()}',
      );
    }
  }

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

  static Future<String> _readYamlFile(String filePath) async {
    try {
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
      final fileStat = await file.stat();
      if (fileStat.size > 10 * 1024 * 1024) {
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
      if (content.trim().isEmpty) {
        throw const InvalidYAMLFormatException(
          'Configuration file contains no data. Please select a valid YAML file.',
        );
      }
      // Clean any invisible control characters that might have been inserted
      // This removes all control characters except newline, carriage return, and tab
      final cleanedContent = content.replaceAll(
        RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]'),
        '',
      );
      return cleanedContent;
    } catch (e) {
      if (e is ROASTConfigException) rethrow;
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

  static Future<Map<String, dynamic>> _parseYamlContent(
    String yamlContent,
  ) async {
    try {
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
      return _convertYamlToMap(yamlDoc);
    } catch (e) {
      LoggerWrapper.logError(
        'ROASTGroupExportConfig',
        '_parseYamlContent',
        'Error parsing YAML content: ${e.toString()}',
      );

      if (e is YamlException) {
        final String specificError = _parseYamlError(e);
        LoggerWrapper.logError(
          'ROASTGroupExportConfig',
          '_parseYamlContent',
          'YAML parsing error: $specificError',
        );
        throw InvalidYAMLFormatException(
          'Invalid YAML format: $specificError',
          details: e.message,
        );
      }
      if (e is ROASTConfigException) rethrow;
      throw InvalidYAMLFormatException(
        'Failed to parse YAML content: ${e.toString()}',
      );
    }
  }

  /// Recursively convert YAML objects to regular Dart collections
  static Map<String, dynamic> _convertYamlToMap(dynamic yamlObj) {
    if (yamlObj is Map) {
      final result = <String, dynamic>{};
      yamlObj.forEach((key, value) {
        result[key.toString()] = _convertYamlValue(value);
      });
      return result;
    }
    throw ArgumentError('Expected Map but got ${yamlObj.runtimeType}');
  }

  static dynamic _convertYamlValue(dynamic value) {
    if (value is Map) {
      final result = <String, dynamic>{};
      value.forEach((key, val) {
        result[key.toString()] = _convertYamlValue(val);
      });
      return result;
    } else if (value is List) {
      return value.map(_convertYamlValue).toList();
    } else {
      return value;
    }
  }

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

  static Future<void> _validateConfiguration(
    ROASTGroupExportConfig config,
  ) async {
    final List<String> validationErrors = [];
    if (config.groupId.isEmpty || config.participants.isEmpty) {
      throw const ConfigValidationException(
        'Invalid configuration file',
        [
          'The configuration file is missing required information. Please use a valid exported configuration file.',
        ],
      );
    }
    final Set<String> seenIdentifiers = {};
    final Set<String> seenNames = {};
    for (int i = 0; i < config.participants.length; i++) {
      final participant = config.participants[i];
      if (seenIdentifiers.contains(participant.identifier)) {
        throw const ConfigValidationException(
          'Invalid configuration file',
          [
            'The configuration file contains duplicate participants. Please use a valid exported configuration file.',
          ],
        );
      }
      seenIdentifiers.add(participant.identifier);
      if (participant.name.isNotEmpty) {
        if (seenNames.contains(participant.name)) {
          throw const ConfigValidationException(
            'Invalid configuration file',
            [
              'The configuration file contains duplicate participants. Please use a valid exported configuration file.',
            ],
          );
        }
        seenNames.add(participant.name);
      }
      try {
        Identifier.fromHex(participant.identifier);
        ECCompressedPublicKey.fromHex(participant.publicKey);
      } catch (e) {
        throw const ConfigValidationException(
          'Invalid configuration file',
          [
            'The configuration file contains invalid participant data. Please use a valid exported configuration file.',
          ],
        );
      }
    }
    if (validationErrors.isNotEmpty) {
      throw ConfigValidationException(
        'Configuration validation failed',
        validationErrors,
      );
    }
  }
}

/// Individual participant configuration for YAML export/import
class ROASTParticipantExportConfig {
  final String name;
  final String identifier;
  final String publicKey;

  ROASTParticipantExportConfig({
    required this.name,
    required this.identifier,
    required this.publicKey,
  });

  /// Convert to YAML-compatible map structure
  Map<String, dynamic> toYamlMap() {
    return {
      'name': name,
      'identifier': identifier,
      'public_key': publicKey,
    };
  }

  /// Create from YAML-compatible map structure
  factory ROASTParticipantExportConfig.fromYamlMap(
    Map<String, dynamic> yamlMap,
  ) {
    return ROASTParticipantExportConfig(
      name: yamlMap['name']?.toString() ?? '',
      identifier: yamlMap['identifier']?.toString() ?? '',
      publicKey: yamlMap['public_key']?.toString() ?? '',
    );
  }
}

/// Result class for import operations
class ROASTGroupImportResult {
  final String serverUrl;
  final String groupId;
  final Map<Identifier, ECCompressedPublicKey> participants;
  final Map<String, String> participantNames;
  final int participantCount;
  final String created;

  ROASTGroupImportResult({
    required this.serverUrl,
    required this.groupId,
    required this.participants,
    required this.participantNames,
    required this.participantCount,
    required this.created,
  });

  void applyToROASTWallet(ROASTWallet roastWallet) {
    roastWallet.serverUrl = serverUrl;
    roastWallet.groupId = groupId;
    roastWallet.participantNames = participantNames;
    // Note: participants map is applied separately in the UI layer
  }
}
