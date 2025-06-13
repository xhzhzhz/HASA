class Withdrawal {
  final int? id;
  final int points;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final DateTime timestamp;

  Withdrawal({
    this.id,
    required this.points,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.timestamp,
  });

  String get amountInRupiah {
    return 'Rp ${(points / 10).toStringAsFixed(0)}00';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Withdrawal.fromMap(Map<String, dynamic> map) {
    return Withdrawal(
      id: map['id'],
      points: map['points'],
      bankName: map['bankName'],
      accountNumber: map['accountNumber'],
      accountHolderName: map['accountHolderName'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
