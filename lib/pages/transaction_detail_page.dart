import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amount = (transaction['amount'] as num).toDouble();
    final type = transaction['type'] as String;
    final currentUserId = SupabaseService.currentUser?.id;
    final isIncoming = transaction['recipient_id'] == currentUserId || type == 'deposit';

    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: AppBar(
        backgroundColor: AppColor.appBgColor,
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            onPressed: () => _shareTransaction(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(isIncoming, amount),
            const SizedBox(height: 24),
            _buildDetails(),
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isIncoming, double amount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isIncoming ? AppColor.green.withAlpha(51) : AppColor.red.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
              size: 40,
              color: isIncoming ? AppColor.green : AppColor.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isIncoming ? 'Money Received' : 'Money Sent',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${isIncoming ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isIncoming ? AppColor.green : AppColor.red,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withAlpha(51),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (transaction['status'] ?? 'completed').toString().toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (transaction['status']?.toString().toLowerCase()) {
      case 'pending': return AppColor.yellow;
      case 'failed': return AppColor.red;
      case 'cancelled': return Colors.grey;
      default: return AppColor.green;
    }
  }

  Widget _buildDetails() {
    final date = DateTime.tryParse(transaction['created_at'] ?? '');
    final dateStr = date != null
        ? '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : 'Unknown';

    String recipient = 'N/A';
    if (transaction['recipient'] != null && transaction['recipient']['full_name'] != null) {
      recipient = transaction['recipient']['full_name'];
    } else if (transaction['type'] == 'deposit') {
      recipient = 'Your Account';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildDetailRow('To/From', recipient),
          _buildDetailRow('Type', (transaction['type'] ?? 'Transfer').toString().toUpperCase()),
          _buildDetailRow('Category', transaction['category'] ?? 'General'),
          _buildDetailRow('Description', transaction['description'] ?? 'No description'),
          _buildDetailRow('Date & Time', dateStr),
          _buildDetailRow('Transaction ID', (transaction['id'] ?? '').toString().substring(0, 8).toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _downloadReceipt(context),
            icon: const Icon(Icons.download),
            label: const Text('Receipt'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _reportIssue(context),
            icon: const Icon(Icons.report_outlined),
            label: const Text('Report'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
  }

  void _shareTransaction(BuildContext context) {
    final text = 'Transaction: \$${transaction['amount']} - ${transaction['description'] ?? transaction['type']}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction details copied')),
    );
  }

  void _downloadReceipt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt downloaded')),
    );
  }

  void _reportIssue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Report an Issue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.error_outline),
              title: const Text('Incorrect amount'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: const Text("Didn't recognize this transaction"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Other issue'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
