class TransactionModel {
  final String id;
  final String userId;
  final String recipientId;
  final double amount;
  final String type; // 'send', 'receive', 'deposit', 'withdraw'
  final String? description;
  final DateTime createdAt;
  final String? recipientName;
  final String? recipientEmail;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.recipientId,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
    this.recipientName,
    this.recipientEmail,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final recipient = json['recipient'] as Map<String, dynamic>?;
    
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recipientId: json['recipient_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      recipientName: recipient?['full_name'] as String?,
      recipientEmail: recipient?['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipient_id': recipientId,
      'amount': amount,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inDays == 0) {
      return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  bool get isIncoming => type == 'receive' || type == 'deposit';
}
