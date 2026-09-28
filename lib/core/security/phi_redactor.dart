import '../constants/app_constants.dart';

/// Strips PHI patterns from strings before logging.
/// Not a full de-identification tool — do not rely on this for compliance.
class PhiRedactor {
  static final List<RegExp> _patterns = [
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
    RegExp(r'\+?[\d\s\-\(\)]{8,15}'),
    RegExp(r'\b[12]\d{9}\b'),
    RegExp(r'\b\d{4}[-/]\d{2}[-/]\d{2}\b'),
    RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
  ];

  static String redact(String input) {
    String result = input;
    for (final p in _patterns) {
      result = result.replaceAll(p, '[REDACTED]');
    }
    for (final f in AppConstants.phiFields) {
      result = result.replaceAll(
        RegExp('"$f"\\s*:\\s*"[^"]*"', caseSensitive: false),
        '"$f": "[REDACTED]"',
      );
    }
    return result;
  }
}
