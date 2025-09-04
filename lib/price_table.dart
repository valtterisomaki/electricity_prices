import 'package:flutter/material.dart';
import 'price_service.dart';

class PriceTable extends StatelessWidget {
  final List<PriceEntry> prices;

  const PriceTable({super.key, required this.prices});

  Color getPriceColor(double price) {
    if (price > 50) return Colors.red.shade900;
    if (price > 20) return Colors.red;
    if (price >= 10) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final tomorrowUtc = todayUtc.add(const Duration(days: 1));

    // Filter for remaining hours today + tomorrow
    final filtered = prices.where((p) {
  final startUtc = p.startDate.toUtc();
  final endUtc = p.endDate.toUtc();
  return endUtc.isAfter(nowUtc) && startUtc.isBefore(tomorrowUtc.add(const Duration(days: 1)));
}).toList()
  ..sort((a, b) => a.startDate.compareTo(b.startDate));


    if (filtered.isEmpty) {
      return const Center(child: Text("No price data available."));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade400),
        defaultColumnWidth: const FixedColumnWidth(60),
        children: [
          // Hours
          TableRow(
            children: filtered.map((entry) {
              final local = entry.startDate.toLocal();
              final hour = local.hour.toString().padLeft(2, '0');
              final day = local.day == todayUtc.toLocal().day ? '' : 'Tmr\n';
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  '$day$hour',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              );
            }).toList(),
          ),
          // Prices
          TableRow(
            children: filtered.map((entry) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  entry.price.toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getPriceColor(entry.price),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
