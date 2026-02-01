import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';
import '../theme/colors.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedPeriod = 'month';
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    final stats = await SupabaseService.getStatistics(filter: _selectedPeriod);
    
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadStats,
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
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildChart(),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdown(),
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: AppColor.shadowColor.withAlpha(26), blurRadius: 1)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        underline: const SizedBox(),
        isDense: true,
        items: const [
          DropdownMenuItem(value: 'week', child: Text('This Week')),
          DropdownMenuItem(value: 'month', child: Text('This Month')),
          DropdownMenuItem(value: 'year', child: Text('This Year')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedPeriod = value);
            _loadStats();
          }
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    final income = (_stats['income'] as num?)?.toDouble() ?? 0.0;
    final expenses = (_stats['expenses'] as num?)?.toDouble() ?? 0.0;
    final netFlow = income - expenses;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Income', income, AppColor.green, Icons.arrow_downward)),
              const SizedBox(width: 16),
              Expanded(child: _buildSummaryCard('Expenses', expenses, AppColor.red, Icons.arrow_upward)),
            ],
          ),
          const SizedBox(height: 16),
          _buildNetFlowCard(netFlow),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${_formatNumber(amount)}',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildNetFlowCard(double netFlow) {
    final isPositive = netFlow >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [AppColor.primary, AppColor.primary.withAlpha(200)]
              : [AppColor.red, AppColor.red.withAlpha(200)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Net Flow', style: TextStyle(color: Colors.white.withAlpha(200))),
              const SizedBox(height: 8),
              Text(
                '${isPositive ? '+' : ''}\$${_formatNumber(netFlow.abs())}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final transactions = _stats['transactions'] as List<dynamic>? ?? [];
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('No data to display')),
        ),
      );
    }

    // Group transactions by day
    final Map<String, double> dailyIncome = {};
    final Map<String, double> dailyExpense = {};
    final currentUserId = SupabaseService.currentUser?.id;

    for (var tx in transactions) {
      final date = DateTime.tryParse(tx['created_at'] ?? '');
      if (date == null) continue;
      
      final dayKey = '${date.month}/${date.day}';
      final amount = (tx['amount'] as num).toDouble();
      final type = tx['type'] as String;
      final isIncoming = tx['recipient_id'] == currentUserId || type == 'deposit';

      if (isIncoming) {
        dailyIncome[dayKey] = (dailyIncome[dayKey] ?? 0) + amount;
      } else {
        dailyExpense[dayKey] = (dailyExpense[dayKey] ?? 0) + amount;
      }
    }

    // Get last 7 days
    final days = <String>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      days.add('${date.month}/${date.day}');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
              children: [
                _buildLegendItem('Income', AppColor.green),
                const SizedBox(width: 16),
                _buildLegendItem('Expenses', AppColor.red),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(dailyIncome, dailyExpense, days),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(days[index], style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(days.length, (index) {
                    final day = days[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: dailyIncome[day] ?? 0,
                          color: AppColor.green,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: dailyExpense[day] ?? 0,
                          color: AppColor.red,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  double _getMaxY(Map<String, double> income, Map<String, double> expense, List<String> days) {
    double max = 100;
    for (var day in days) {
      final i = income[day] ?? 0;
      final e = expense[day] ?? 0;
      if (i > max) max = i;
      if (e > max) max = e;
    }
    return max * 1.2;
  }

  Widget _buildCategoryBreakdown() {
    final categories = _stats['categories'] as List<dynamic>? ?? [];
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spending by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...categories.map((cat) => _buildCategoryItem(cat)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(dynamic category) {
    final name = category['name'] as String? ?? 'Other';
    final amount = (category['amount'] as num?)?.toDouble() ?? 0.0;
    final percentage = (category['percentage'] as num?)?.toDouble() ?? 0.0;
    final color = _getCategoryColor(name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getCategoryIcon(name), color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${(percentage * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return AppColor.yellow;
      case 'shopping': return AppColor.pink;
      case 'transfer': return AppColor.primary;
      case 'housing': return AppColor.green;
      case 'entertainment': return AppColor.purple;
      case 'transportation': return Colors.orange;
      default: return AppColor.appBgColorSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'shopping': return Icons.shopping_bag;
      case 'transfer': return Icons.swap_horiz;
      case 'housing': return Icons.home;
      case 'entertainment': return Icons.movie;
      case 'transportation': return Icons.directions_car;
      default: return Icons.category;
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
