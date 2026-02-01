import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';
import 'send_money_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _transactions = [];
  int _selectedCardIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final cards = await SupabaseService.getCards();
    final transactions = await SupabaseService.getTransactions(limit: 5);
    
    if (mounted) {
      setState(() {
        _cards = cards;
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
                else ...[
                  if (_cards.isNotEmpty) ...[
                    _buildCardCarousel(),
                    const SizedBox(height: 8),
                    _buildCardIndicators(),
                  ] else
                    _buildNoCards(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColor.appBgColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: AppColor.shadowColor.withAlpha(26), blurRadius: 1)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Wallet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${_cards.length} card${_cards.length != 1 ? 's' : ''} connected', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          IconButton(onPressed: _showAddCardDialog, icon: const Icon(Icons.add_card_rounded)),
        ],
      ),
    );
  }

  Widget _buildNoCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(Icons.credit_card_off, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No cards added yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: _showAddCardDialog, icon: const Icon(Icons.add), label: const Text('Add Card')),
        ],
      ),
    );
  }

  Widget _buildCardCarousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: _cards.length,
        onPageChanged: (index) => setState(() => _selectedCardIndex = index),
        itemBuilder: (context, index) => Container(margin: const EdgeInsets.symmetric(horizontal: 16), child: _buildCard(_cards[index])),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    final cardType = (card['card_type'] as String?)?.toLowerCase() ?? 'visa';
    final isVisa = cardType == 'visa';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVisa ? [const Color(0xFF1A1F71), const Color(0xFF2E3192)] : [const Color(0xFFEB001B), const Color(0xFFF79E1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (isVisa ? const Color(0xFF1A1F71) : const Color(0xFFEB001B)).withAlpha(100), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Icon(Icons.wifi, color: Colors.white), _buildCardLogo(cardType)],
          ),
          Text(card['card_number'] ?? '**** **** **** ****', style: const TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Card Holder', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text(card['card_holder_name'] ?? 'CARD HOLDER', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Expires', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text(card['expiry_date'] ?? 'MM/YY', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardLogo(String cardType) {
    if (cardType == 'visa') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: const Text('VISA', style: TextStyle(color: Color(0xFF1A1F71), fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
      );
    } else {
      return Row(
        children: [
          Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFEB001B), shape: BoxShape.circle)),
          Transform.translate(
            offset: const Offset(-10, 0),
            child: Container(width: 30, height: 30, decoration: BoxDecoration(color: const Color(0xFFF79E1B).withAlpha(200), shape: BoxShape.circle)),
          ),
        ],
      );
    }
  }

  Widget _buildCardIndicators() {
    if (_cards.length <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cards.length, (index) {
        return Container(
          width: index == _selectedCardIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: index == _selectedCardIndex ? AppColor.primary : Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
        );
      }),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(Icons.add, 'Top Up', AppColor.green, _showTopUp),
              _buildActionButton(Icons.send, 'Send', AppColor.primary, () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const SendMoneyPage()));
                await context.read<AuthProvider>().refreshUser();
                await _loadData();
              }),
              _buildActionButton(Icons.delete_outline, 'Remove', AppColor.red, _cards.isNotEmpty ? () => _showRemoveCard() : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.5,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: color.withAlpha(51), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (_transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('No recent activity', style: TextStyle(color: Colors.grey.shade600))),
            )
          else
            ..._transactions.map(_buildActivityItem),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> tx) {
    final amount = (tx['amount'] as num).toDouble();
    final type = tx['type'] as String;
    final currentUserId = SupabaseService.currentUser?.id;
    
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

    String name;
    if (type == 'deposit') {
      name = 'Deposit';
    } else if (isIncoming) {
      name = tx['sender_name'] ?? 'Received';
    } else {
      name = tx['recipient_name'] ?? 'Sent';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncoming ? AppColor.green.withAlpha(51) : AppColor.red.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isIncoming ? Icons.arrow_downward : Icons.arrow_upward, color: isIncoming ? AppColor.green : AppColor.red),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Text(
            '${isIncoming ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: isIncoming ? AppColor.green : AppColor.red),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    final numberController = TextEditingController();
    final holderController = TextEditingController();
    final expiryController = TextEditingController();
    String selectedType = 'visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildCardTypeOption('Visa', 'visa', selectedType, (type) => setSheetState(() => selectedType = type)),
                  const SizedBox(width: 12),
                  _buildCardTypeOption('Mastercard', 'mastercard', selectedType, (type) => setSheetState(() => selectedType = type)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Card Number', hintText: '1234 5678 9012 3456'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: holderController, decoration: const InputDecoration(labelText: 'Cardholder Name'), textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 16),
              TextField(controller: expiryController, decoration: const InputDecoration(labelText: 'Expiry Date', hintText: 'MM/YY')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (numberController.text.isEmpty || holderController.text.isEmpty || expiryController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
                      return;
                    }
                    final lastFour = numberController.text.length >= 4 ? numberController.text.substring(numberController.text.length - 4) : numberController.text;
                    final success = await SupabaseService.addCard(
                      cardType: selectedType,
                      cardNumber: '**** **** **** $lastFour',
                      cardHolderName: holderController.text.toUpperCase(),
                      expiryDate: expiryController.text,
                    );
                    Navigator.pop(context);
                    if (success) {
                      await _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card added!')));
                    }
                  },
                  child: const Text('Add Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeOption(String label, String value, String selected, Function(String) onSelect) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primary.withAlpha(26) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColor.primary, width: 2) : null,
          ),
          child: Center(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
        ),
      ),
    );
  }

  void _showTopUp() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Top Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '\$ ', hintText: 'Enter amount'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(spacing: 12, children: ['100', '500', '1000'].map((amt) => ActionChip(label: Text('\$$amt'), onPressed: () => controller.text = amt)).toList()),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(controller.text);
                  if (amount == null || amount <= 0) return;
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

  void _showRemoveCard() {
    if (_cards.isEmpty) return;
    final card = _cards[_selectedCardIndex];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Card?'),
        content: Text('Remove ${card['card_type']?.toString().toUpperCase() ?? 'card'} ending in ${(card['card_number'] ?? '').toString().substring((card['card_number'] ?? '').toString().length - 4)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.deleteCard(card['id']);
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card removed')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
