import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';

class SendMoneyPage extends StatefulWidget {
  final String? recipientId;
  final String? recipientName;

  const SendMoneyPage({super.key, this.recipientId, this.recipientName});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _emailController = TextEditingController();
  
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _selectedRecipient;
  bool _isLoading = false;
  bool _isSending = false;
  bool _useEmail = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await SupabaseService.getAllUsers();
    
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
        
        if (widget.recipientId != null) {
          _selectedRecipient = users.firstWhere(
            (u) => u['id'] == widget.recipientId,
            orElse: () => {'id': widget.recipientId, 'full_name': widget.recipientName ?? 'User'},
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: AppBar(
        backgroundColor: AppColor.appBgColor,
        title: const Text('Send Money'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipientSection(),
            const SizedBox(height: 24),
            _buildAmountSection(),
            const SizedBox(height: 24),
            _buildNoteSection(),
            const SizedBox(height: 32),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Send To', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _useEmail = !_useEmail;
                    _selectedRecipient = null;
                    _emailController.clear();
                    _emailError = null;
                  });
                },
                child: Text(_useEmail ? 'Choose Contact' : 'Use Email'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedRecipient != null)
            _buildSelectedRecipient()
          else if (_useEmail)
            _buildEmailInput()
          else if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_users.isEmpty)
            const Center(child: Text('No users available'))
          else
            _buildUserGrid(),
        ],
      ),
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter recipient email',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: _emailError,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _findUserByEmail,
            ),
          ),
          onSubmitted: (_) => _findUserByEmail(),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the email of the person you want to send money to',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _findUserByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Enter an email');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    final user = await SupabaseService.findUserByEmail(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (user != null) {
          if (user['id'] == SupabaseService.currentUser?.id) {
            _emailError = "You can't send money to yourself";
          } else {
            _selectedRecipient = user;
            _emailError = null;
          }
        } else {
          _emailError = 'User not found';
        }
      });
    }
  }

  Widget _buildSelectedRecipient() {
    final name = _selectedRecipient!['full_name'] ?? 'User';
    final email = _selectedRecipient!['email'] ?? '';
    
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: AppColor.primary, shape: BoxShape.circle),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text(email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => setState(() {
            _selectedRecipient = null;
            _emailController.clear();
          }),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildUserGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Recipient', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _users.take(8).map((user) {
            final name = user['full_name'] ?? 'User';
            return GestureDetector(
              onTap: () => setState(() => _selectedRecipient = user),
              child: SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: _getColorForName(name), shape: BoxShape.circle),
                      child: Center(
                        child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(name.split(' ').first, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Balance: ${auth.formattedBalance}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('\$', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColor.primary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(hintText: '0.00', border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: ['50', '100', '500', '1000'].map((amt) {
                  return ActionChip(label: Text('\$$amt'), onPressed: () => _amountController.text = amt);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteSection() {
    return TextField(
      controller: _noteController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Note (Optional)',
        hintText: 'What is this for?',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedRecipient != null && !_isSending ? _sendMoney : null,
        child: _isSending
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Send Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _sendMoney() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

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
      recipientId: _selectedRecipient!['id'],
      amount: amount,
      description: _noteController.text.isNotEmpty ? _noteController.text : 'Transfer to ${_selectedRecipient!['full_name']}',
    );

    setState(() => _isSending = false);

    if (success && mounted) {
      _showSuccessDialog(amount);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer failed. Try again.')));
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppColor.green.withAlpha(51), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColor.green, size: 50),
            ),
            const SizedBox(height: 24),
            const Text('Success!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Sent \$${amount.toStringAsFixed(2)} to ${_selectedRecipient!['full_name']}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
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
