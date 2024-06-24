class Vuln {
  /// 製品ID
  final String productId;

  /// ヒットしたページのURL
  final String url;

  const Vuln({
    required this.productId,
    required this.url,
  });
}
