import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';
import '../widgets/balance_card.dart';
import '../widgets/service_box.dart';
import 'send_money_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final transactions = await SupabaseService.getTransactions(limit: 10);
    final users = await SupabaseService.getAllUsers();

    if (mounted) {
      setState(() {
        _transactions = transactions;
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().refreshUser();
          await _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildBalance(),
              const SizedBox(height: 35),
              _buildServices(),
              const SizedBox(height: 25),
              if (_users.isNotEmpty) ...[
                _buildSendAgainSection(),
                const SizedBox(height: 25),
              ],
              _buildTransactionsSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final firstName = auth.userName.split(' ').first;
        return Container(
          height: 130,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 35),
          decoration: BoxDecoration(
            color: AppColor.appBgColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadowColor.withAlpha(26),
                blurRadius: .5,
                spreadRadius: .5,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello $firstName,', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 5),
                    const Text('Welcome Back!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalance() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              BalanceCard(balance: auth.formattedBalance),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showAddMoneySheet,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColor.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddMoneySheet() {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Money', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: '\$ ', hintText: 'Enter amount'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: ['100', '500', '1000'].map((amt) {
                return ActionChip(label: Text('\$$amt'), onPressed: () => amountController.text = amt);
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
                    return;
                  }
                  Navigator.pop(context);
                  final success = await SupabaseService.addMoney(amount);
                  if (success && mounted) {
                    await context.read<AuthProvider>().refreshUser();
                    await _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\$${amount.toStringAsFixed(0)} added!')));
                  }
                },
                child: const Text('Add Money'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(width: 15),
        Expanded(
          child: ServiceBox(
            title: 'Send',
            icon: Icons.send_rounded,
            bgColor: AppColor.green,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SendMoneyPage()));
              await context.read<AuthProvider>().refreshUser();
              await _loadData();
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ServiceBox(
            title: 'Add Money',
            icon: Icons.add_circle_outline,
            bgColor: AppColor.yellow,
            onTap: _showAddMoneySheet,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ServiceBox(
            title: 'Cards',
            icon: Icons.credit_card,
            bgColor: AppColor.purple,
            onTap: () {
              // Navigate to wallet tab - index 1
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Go to Wallet tab for cards')));
            },
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget _buildSendAgainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Send Again', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 15),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              final name = user['full_name'] ?? 'User';
              final firstName = name.split(' ').first;

              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SendMoneyPage(recipientId: user['id'], recipientName: name)),
                  );
                  await context.read<AuthProvider>().refreshUser();
                  await _loadData();
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: _getColorForName(name), shape: BoxShape.circle),
                        child: Center(
                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(firstName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transactions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_transactions.isEmpty)
            _buildEmptyTransactions()
          else
            ..._transactions.map((tx) => _buildTransactionItem(tx)),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No transactions yet', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Send money to see your activity', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final amount = (tx['amount'] as num).toDouble();
    final type = tx['type'] as String;
    final currentUserId = SupabaseService.currentUser?.id;
    
    // Determine if this is incoming or outgoing
    final bool isIncoming;
    if (type == 'deposit') {
      isIncoming = true;
    } else if (type == 'send' && tx['user_id'] == currentUserId) {
      isIncoming = false;
    } else if (tx['recipient_id'] == currentUserId) {
      isIncoming = true;
    } else {
      isIncoming = false;
    }

    // Get the display name
    String name;
    if (type == 'deposit') {
      name = 'Deposit';
    } else if (isIncoming) {
      name = tx['sender_name'] ?? tx['description'] ?? 'Received';
    } else {
      name = tx['recipient_name'] ?? tx['description'] ?? 'Sent';
    }

    final date = DateTime.tryParse(tx['created_at'] ?? '');
    final dateStr = date != null ? _formatDate(date) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isIncoming ? AppColor.green.withAlpha(51) : AppColor.red.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncoming ? AppColor.green : AppColor.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            '${isIncoming ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: isIncoming ? AppColor.green : AppColor.red),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getColorForName(String name) {
    final colors = [AppColor.primary, AppColor.green, AppColor.yellow, AppColor.pink, AppColor.purple];
    return colors[name.hashCode.abs() % colors.length];
  }
}
