import 'package:flutter/material.dart';
import 'price_service.dart';
import 'price_table.dart';
import 'price_chart.dart'; // Make sure this imports your existing chart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electricity Prices',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PriceScreen(),
    );
  }
}

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  final PriceService service = PriceService();
  late Future<List<PriceEntry>> pricesFuture;
  bool showTable = false; // Toggle between chart and table

  @override
  void initState() {
    super.initState();
    pricesFuture = service.fetchPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Electricity Prices")),
      body: FutureBuilder<List<PriceEntry>>(
        future: pricesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          final prices = snapshot.data!;

          return Column(
            children: [
              // Toggle switch
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chart'),
                  Switch(
                    value: showTable,
                    onChanged: (value) {
                      setState(() {
                        showTable = value;
                      });
                    },
                  ),
                  const Text('Table'),
                ],
              ),
              // Chart or table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: showTable
                      ? PriceTable(prices: prices)
                      : PriceChart(prices: prices),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
