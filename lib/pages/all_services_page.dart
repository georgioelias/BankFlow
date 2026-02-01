import 'package:flutter/material.dart';
import '../data/json.dart';
import '../theme/colors.dart';
import 'send_money_page.dart';
import 'request_money_page.dart';

class AllServicesPage extends StatelessWidget {
  const AllServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: AppBar(
        backgroundColor: AppColor.appBgColor,
        title: const Text('All Services'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Money Transfer', [
              _ServiceItem(
                icon: Icons.send,
                title: 'Send Money',
                subtitle: 'Transfer to anyone',
                color: AppColor.green,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendMoneyPage())),
              ),
              _ServiceItem(
                icon: Icons.download,
                title: 'Request Money',
                subtitle: 'Ask for payment',
                color: AppColor.yellow,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestMoneyPage())),
              ),
              _ServiceItem(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR',
                subtitle: 'Pay with QR code',
                color: AppColor.pink,
                onTap: () => _showComingSoon(context, 'QR Scanner'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection(context, 'Payments', [
              _ServiceItem(
                icon: Icons.receipt_long,
                title: 'Pay Bills',
                subtitle: 'Utilities & more',
                color: AppColor.purple,
                onTap: () => _showBillsPage(context),
              ),
              _ServiceItem(
                icon: Icons.phone_android,
                title: 'Mobile Recharge',
                subtitle: 'Top up your phone',
                color: AppColor.appBgColorSecondary,
                onTap: () => _showComingSoon(context, 'Mobile Recharge'),
              ),
              _ServiceItem(
                icon: Icons.shopping_bag,
                title: 'Online Shopping',
                subtitle: 'Shop & pay',
                color: AppColor.yellow,
                onTap: () => _showComingSoon(context, 'Online Shopping'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection(context, 'Banking', [
              _ServiceItem(
                icon: Icons.add_card,
                title: 'Top Up',
                subtitle: 'Add money',
                color: AppColor.appBgColorPrimary,
                onTap: () => _showTopUp(context),
              ),
              _ServiceItem(
                icon: Icons.account_balance,
                title: 'Bank Transfer',
                subtitle: 'To bank account',
                color: AppColor.green,
                onTap: () => _showComingSoon(context, 'Bank Transfer'),
              ),
              _ServiceItem(
                icon: Icons.atm,
                title: 'Withdraw',
                subtitle: 'Cash out',
                color: AppColor.red,
                onTap: () => _showComingSoon(context, 'Withdraw'),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSection(context, 'More Services', [
              _ServiceItem(
                icon: Icons.savings,
                title: 'Savings',
                subtitle: 'Grow your money',
                color: AppColor.green,
                onTap: () => _showComingSoon(context, 'Savings'),
              ),
              _ServiceItem(
                icon: Icons.trending_up,
                title: 'Investments',
                subtitle: 'Stocks & crypto',
                color: AppColor.appBgColorSecondary,
                onTap: () => _showComingSoon(context, 'Investments'),
              ),
              _ServiceItem(
                icon: Icons.card_giftcard,
                title: 'Gift Cards',
                subtitle: 'Buy & send',
                color: AppColor.pink,
                onTap: () => _showComingSoon(context, 'Gift Cards'),
              ),
              _ServiceItem(
                icon: Icons.flight,
                title: 'Travel',
                subtitle: 'Book flights & hotels',
                color: AppColor.yellow,
                onTap: () => _showComingSoon(context, 'Travel'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_ServiceItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: items.map((item) => _buildServiceCard(context, item)).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, _ServiceItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              item.subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  void _showBillsPage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pay Bills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: billCategories.length,
                itemBuilder: (context, index) {
                  final bill = billCategories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(bill['color'] as int).withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(bill['icon'] as String),
                          color: Color(bill['color'] as int),
                        ),
                      ),
                      title: Text(bill['name'] as String),
                      subtitle: Text(bill['provider'] as String),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${bill['amount']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Due: ${bill['dueDate']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showPayBillDialog(context, bill);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayBillDialog(BuildContext context, Map<String, dynamic> bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pay ${bill['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Provider: ${bill['provider']}'),
            const SizedBox(height: 8),
            Text(
              'Amount: \$${bill['amount']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Due: ${bill['dueDate']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${bill['name']} bill paid successfully!')),
              );
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _showTopUp(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Top Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: 'Enter amount',
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: ['\$50', '\$100', '\$200', '\$500'].map((amount) {
                return ActionChip(
                  label: Text(amount),
                  onPressed: () {
                    controller.text = amount.replaceAll('\$', '');
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('\$${controller.text} added successfully!')),
                  );
                },
                child: const Text('Add Money'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'water_drop':
        return Icons.water_drop;
      case 'wifi':
        return Icons.wifi;
      case 'phone_android':
        return Icons.phone_android;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'shield':
        return Icons.shield;
      default:
        return Icons.receipt;
    }
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
