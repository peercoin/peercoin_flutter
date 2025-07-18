/// Custom exceptions for ROAST group configuration export/import operations
library roast_config_exceptions;

/// Base exception class for ROAST configuration operations
abstract class ROASTConfigException implements Exception {
  final String message;
  final String? details;

  const ROASTConfigException(this.message, {this.details});

  @override
  String toString() {
    if (details != null) {
      return 'ROASTConfigException: $message\nDetails: $details';
    }
    return 'ROASTConfigException: $message';
  }
}

/// Exception thrown when YAML format is invalid or cannot be parsed
class InvalidYAMLFormatException extends ROASTConfigException {
  const InvalidYAMLFormatException(
    super.message, {
    super.details,
  });
}

/// Exception thrown when file operations fail
class FileOperationException extends ROASTConfigException {
  final String operation;
  final String? filePath;

  const FileOperationException(
    this.operation,
    super.message, {
    this.filePath,
    super.details,
  });

  @override
  String toString() {
    String result = 'FileOperationException: $message\nOperation: $operation';
    if (filePath != null) {
      result += '\nFile: $filePath';
    }
    return result;
  }
}

/// Exception thrown when configuration validation fails
class ConfigValidationException extends ROASTConfigException {
  final List<String> validationErrors;

  const ConfigValidationException(
    super.message,
    this.validationErrors, {
    super.details,
  });

  @override
  String toString() {
    String result = 'ConfigValidationException: $message';
    if (validationErrors.isNotEmpty) {
      result +=
          '\nValidation errors:\n${validationErrors.map((e) => '  - $e').join('\n')}';
    }
    return result;
  }
}
