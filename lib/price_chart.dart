import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'price_service.dart';

class PriceChart extends StatelessWidget {
  final List<PriceEntry> prices;

  const PriceChart({super.key, required this.prices});

  Color priceColor(double price) {
    if (price < 10) return Colors.green;
    if (price <= 20) return Colors.yellow;
    if (price <= 50) return Colors.red;
    return Colors.red.shade900;
  }

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final tomorrowUtc = todayUtc.add(const Duration(days: 1));

    // Filter prices: current hour onward, today + tomorrow
    final filteredPrices = prices.where((p) {
      final startUtc = p.startDate.toUtc();
      final endUtc = p.endDate.toUtc();
      return endUtc.isAfter(nowUtc) &&
          startUtc.isBefore(tomorrowUtc.add(const Duration(days: 1)));
    }).toList();

    if (filteredPrices.isEmpty) {
      return const Center(child: Text('No price data available.'));
    }

    // Convert to local and sort oldest → newest
    final sortedPrices = filteredPrices
        .map((p) => PriceEntry(
              price: p.price,
              startDate: p.startDate.toLocal(),
              endDate: p.endDate.toLocal(),
            ))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final maxPrice =
        sortedPrices.map((e) => e.price).reduce((a, b) => a > b ? a : b);
    final yInterval = 5.0;

    // Index where tomorrow starts
    int tomorrowIndex = sortedPrices.indexWhere(
        (p) => p.startDate.day != sortedPrices.first.startDate.day);

    return Stack(
      children: [
        if (tomorrowIndex != -1)
          Positioned.fill(
            left: MediaQuery.of(context).size.width / sortedPrices.length *
                tomorrowIndex,
            child: Container(color: Colors.grey.withOpacity(0.1)),
          ),
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxPrice + yInterval).ceilToDouble(),
            minY: 0,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}',
                        style: const TextStyle(fontSize: 10));
                  },
                ),
                axisNameWidget: const Text(
                  'snt/kWh',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                axisNameSize: 30,
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < sortedPrices.length) {
                      final entry = sortedPrices[value.toInt()];
                      final hour = entry.startDate.hour.toString().padLeft(2, '0');
                      final day = entry.startDate.day;

                      if (value.toInt() == 0 ||
                          entry.startDate.day !=
                              sortedPrices[value.toInt() - 1].startDate.day) {
                        final label = entry.startDate.day ==
                                DateTime.now().day
                            ? '$hour'
                            : 'Tmr\n$hour';
                        return Text(label, style: const TextStyle(fontSize: 10));
                      }
                      return Text(hour, style: const TextStyle(fontSize: 10));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingVerticalLine: (value) {
                if (value.toInt() < sortedPrices.length &&
                    value.toInt() > 0 &&
                    sortedPrices[value.toInt()].startDate.day !=
                        sortedPrices[value.toInt() - 1].startDate.day) {
                  return FlLine(color: Colors.black, strokeWidth: 1.5);
                }
                return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 0.5);
              },
            ),
            borderData: FlBorderData(show: true),
            barGroups: sortedPrices.asMap().entries.map((entry) {
              final index = entry.key;
              final priceEntry = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: priceEntry.price,
                    color: priceColor(priceEntry.price),
                    width: 8,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
