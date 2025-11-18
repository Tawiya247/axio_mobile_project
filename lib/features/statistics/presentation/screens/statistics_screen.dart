import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: const Center(
        child: Text('Écran des statistiques', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
