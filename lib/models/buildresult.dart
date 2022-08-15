class BuildResult {
  final int fee;
  final String hex;
  final Map<String, double> recipients;
  final int totalAmount;
  final String id;
  final int destroyedChange;
  final String opReturn;
  final bool neededChange;

  BuildResult({
    required this.fee,
    required this.hex,
    required this.recipients,
    required this.totalAmount,
    required this.id,
    required this.destroyedChange,
    required this.opReturn,
    required this.neededChange,
  });
}
