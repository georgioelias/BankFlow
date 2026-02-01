import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _recipient;
  bool _isSending = false;
  bool _isSearching = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await SupabaseService.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUsers();
          await context.read<AuthProvider>().refreshUser();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildBalanceCard(),
              const SizedBox(height: 25),
              if (_users.isNotEmpty) ...[
                _buildQuickSend(),
                const SizedBox(height: 25),
              ],
              _buildSendByEmail(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: const Row(
        children: [
          Icon(Icons.swap_horiz_rounded, size: 28, color: AppColor.primary),
          SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transfer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
              SizedBox(height: 3),
              Text('Send money to anyone', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColor.primary, Color(0xFF7c62fe)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withAlpha(80),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(auth.formattedBalance, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Quick Send', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 15),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final name = user['full_name'] ?? 'User';
                    final firstName = name.split(' ').first;

                    return GestureDetector(
                      onTap: () => _showSendSheet(user),
                      child: Container(
                        width: 75,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: _getColorForName(name),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getColorForName(name).withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              firstName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
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

  Widget _buildSendByEmail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send by Email', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                if (_recipient != null)
                  _buildSelectedRecipient()
                else ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter recipient email',
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade400),
                      errorText: _error,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 18),
                              ),
                              onPressed: _searchUser,
                            ),
                    ),
                    onSubmitted: (_) => _searchUser(),
                  ),
                ],
                if (_recipient != null) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '\$0.00',
                      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 28),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixText: '\$ ',
                      prefixStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColor.primary),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['50', '100', '500', '1000'].map((amt) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: ActionChip(
                          label: Text('\$$amt'),
                          backgroundColor: Colors.grey.shade100,
                          onPressed: () => _amountController.text = amt,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Add a note (optional)',
                      prefixIcon: Icon(Icons.note_outlined, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendMoney,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: AppColor.primary.withAlpha(100),
                      ),
                      child: _isSending
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Send Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedRecipient() {
    final name = _recipient!['full_name'] ?? 'User';
    final email = _recipient!['email'] ?? '';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColor.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.primary.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColor.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColor.primary.withAlpha(80), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 18),
            ),
            onPressed: () => setState(() {
              _recipient = null;
              _emailController.clear();
              _amountController.clear();
              _noteController.clear();
            }),
          ),
        ],
      ),
    );
  }

  void _showSendSheet(Map<String, dynamic> user) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final name = user['full_name'] ?? 'User';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getColorForName(name),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _getColorForName(name).withAlpha(80), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 16),
            Text('Send to $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '\$0.00',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                border: InputBorder.none,
                prefixText: '\$ ',
                prefixStyle: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColor.primary),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: ['50', '100', '500'].map((amt) {
                return ActionChip(label: Text('\$$amt'), onPressed: () => amountController.text = amt);
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
                    return;
                  }
                  final auth = context.read<AuthProvider>();
                  if (amount > auth.balance) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
                    return;
                  }
                  Navigator.pop(context);
                  setState(() => _isSending = true);
                  final success = await SupabaseService.sendMoney(
                    recipientId: user['id'],
                    amount: amount,
                    description: noteController.text.isNotEmpty ? noteController.text : 'Transfer to $name',
                  );
                  setState(() => _isSending = false);
                  if (success && mounted) {
                    await auth.refreshUser();
                    _showSuccessDialog(amount, name);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Send', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter an email');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    final user = await SupabaseService.findUserByEmail(email);

    if (mounted) {
      setState(() {
        _isSearching = false;
        if (user != null) {
          if (user['id'] == SupabaseService.currentUser?.id) {
            _error = "You can't send to yourself";
          } else {
            _recipient = user;
          }
        } else {
          _error = 'User not found';
        }
      });
    }
  }

  Future<void> _sendMoney() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    final auth = context.read<AuthProvider>();
    if (amount > auth.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    setState(() => _isSending = true);

    final success = await SupabaseService.sendMoney(
      recipientId: _recipient!['id'],
      amount: amount,
      description: _noteController.text.isNotEmpty ? _noteController.text : 'Transfer',
    );

    setState(() => _isSending = false);

    if (success && mounted) {
      await auth.refreshUser();
      _showSuccessDialog(amount, _recipient!['full_name'] ?? 'User');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer failed')));
    }
  }

  void _showSuccessDialog(double amount, String recipientName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColor.green, AppColor.green.withAlpha(180)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColor.green.withAlpha(100), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            const Text('Success!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Sent \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColor.primary),
            ),
            const SizedBox(height: 4),
            Text('to $recipientName', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _recipient = null;
                    _amountController.clear();
                    _noteController.clear();
                    _emailController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForName(String name) {
    final colors = [AppColor.primary, AppColor.green, AppColor.yellow, AppColor.pink, AppColor.purple];
    return colors[name.hashCode.abs() % colors.length];
  }
}
