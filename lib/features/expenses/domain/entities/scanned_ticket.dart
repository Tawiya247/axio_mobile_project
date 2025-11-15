import 'package:equatable/equatable.dart';

class ScannedTicket extends Equatable {
  final String? merchantName;
  final double? totalAmount;
  final DateTime? date;
  final List<String> items;
  final String? rawText;

  const ScannedTicket({
    this.merchantName,
    this.totalAmount,
    this.date,
    this.items = const [],
    this.rawText,
  });

  @override
  List<Object?> get props => [merchantName, totalAmount, date, items, rawText];

  ScannedTicket copyWith({
    String? merchantName,
    double? totalAmount,
    DateTime? date,
    List<String>? items,
    String? rawText,
  }) {
    return ScannedTicket(
      merchantName: merchantName ?? this.merchantName,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      items: items ?? this.items,
      rawText: rawText ?? this.rawText,
    );
  }
}
