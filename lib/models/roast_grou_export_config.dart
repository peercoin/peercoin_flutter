import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:noosphere_roast_client/noosphere_roast_client.dart';

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
          .map((p) => ROASTParticipantExportConfig.fromYamlMap(
              p as Map<String, dynamic>))
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
      Map<String, dynamic> yamlMap) {
    return ROASTParticipantExportConfig(
      name: yamlMap['name']?.toString() ?? '',
      identifier: yamlMap['identifier']?.toString() ?? '',
      publicKey: yamlMap['public_key']?.toString() ?? '',
    );
  }
}
