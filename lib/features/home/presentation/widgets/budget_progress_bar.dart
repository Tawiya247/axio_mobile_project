import 'package:flutter/material.dart';

class BudgetProgressBar extends StatelessWidget {
  final double currentAmount;
  final double maxAmount;
  final String label;

  const BudgetProgressBar({
    super.key,
    required this.currentAmount,
    required this.maxAmount,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxAmount > 0
        ? (currentAmount / maxAmount).clamp(0.0, 1.0)
        : 0.0;
    final percentage = (progress * 100).toStringAsFixed(1);
    final remaining = maxAmount - currentAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8
                    ? Colors.red
                    : progress > 0.5
                    ? Colors.orange
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentAmount.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${maxAmount.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (remaining > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Il vous reste ${remaining.toStringAsFixed(2)} € (${(100 - (progress * 100)).toStringAsFixed(1)}%)',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ] else if (remaining < 0) ...[
              const SizedBox(height: 4),
              Text(
                'Dépassement de ${(-remaining).toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
