class Transaction {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime date;
  final String status; // 'pending', 'completed', 'failed'
  final String? description;

  Transaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.date,
    this.status = 'pending',
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'pending',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}