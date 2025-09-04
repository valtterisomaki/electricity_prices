import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceEntry {
  final double price;
  final DateTime startDate;
  final DateTime endDate;

  PriceEntry({
    required this.price,
    required this.startDate,
    required this.endDate,
  });

  factory PriceEntry.fromJson(Map<String, dynamic> json) {
    return PriceEntry(
      price: (json['price'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

class PriceService {
  // Proxy that bypasses browser CORS restrictions
  static const String proxyUrl =
      'https://api.allorigins.win/get?url=https://api.porssisahko.net/v1/latest-prices.json';

  Future<List<PriceEntry>> fetchPrices() async {
    final response = await http.get(Uri.parse(proxyUrl));

    if (response.statusCode == 200) {
      // AllOrigins wraps the response JSON inside "contents"
      final wrapper = jsonDecode(response.body);
      final data = jsonDecode(wrapper['contents']);

      final List pricesJson = data['prices'] ?? [];
      return pricesJson.map((e) => PriceEntry.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load prices: ${response.statusCode}");
    }
  }
}
