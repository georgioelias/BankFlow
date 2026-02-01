import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://wlbiionatiacgvsyljqq.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsYmlpb25hdGlhY2d2c3lsanFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5NTQwMzUsImV4cCI6MjA4NTUzMDAzNX0.2GaXe9vOdwfRhvvExDtijtlaWss5NEMOZ5epwDRjGIs',
    );
  }

  // ============ AUTH ============

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      await _createUserProfile(response.user!.id, email, fullName);
    }

    return response;
  }

  static Future<void> _createUserProfile(String id, String email, String fullName) async {
    try {
      await client.from('users').upsert({
        'id': id,
        'email': email,
        'full_name': fullName,
        'balance': 10000.0,
        'is_verified': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Profile creation: $e');
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ============ USER PROFILE ============

  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    try {
      final data = await client
          .from('users')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();
      return data;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final data = await client
          .from('users')
          .select('id, email, full_name')
          .neq('id', currentUser?.id ?? '')
          .order('full_name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Get users error: $e');
      return [];
    }
  }

  // Find user by email
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final data = await client
          .from('users')
          .select('id, email, full_name')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();
      return data;
    } catch (e) {
      print('Find user error: $e');
      return null;
    }
  }

  // ============ TRANSACTIONS ============

  static Future<List<Map<String, dynamic>>> getTransactions({int limit = 50}) async {
    if (currentUser == null) return [];

    try {
      // Get transactions where user is sender OR recipient
      final data = await client
          .from('transactions')
          .select()
          .or('user_id.eq.${currentUser!.id},recipient_id.eq.${currentUser!.id}')
          .order('created_at', ascending: false)
          .limit(limit);

      // Fetch recipient names for each transaction
      final transactions = List<Map<String, dynamic>>.from(data);
      
      for (var tx in transactions) {
        if (tx['recipient_id'] != null) {
          final recipient = await client
              .from('users')
              .select('full_name, email')
              .eq('id', tx['recipient_id'])
              .maybeSingle();
          tx['recipient_name'] = recipient?['full_name'] ?? 'Unknown';
          tx['recipient_email'] = recipient?['email'] ?? '';
        }
        if (tx['user_id'] != null && tx['user_id'] != currentUser!.id) {
          final sender = await client
              .from('users')
              .select('full_name, email')
              .eq('id', tx['user_id'])
              .maybeSingle();
          tx['sender_name'] = sender?['full_name'] ?? 'Unknown';
        }
      }

      return transactions;
    } catch (e) {
      print('Get transactions error: $e');
      return [];
    }
  }

  static Future<bool> sendMoney({
    required String recipientId,
    required double amount,
    String? description,
  }) async {
    if (currentUser == null) return false;

    try {
      final profile = await getUserProfile();
      if (profile == null) return false;

      final currentBalance = (profile['balance'] as num).toDouble();
      if (currentBalance < amount) return false;

      // Create transaction record
      await client.from('transactions').insert({
        'user_id': currentUser!.id,
        'recipient_id': recipientId,
        'amount': amount,
        'type': 'send',
        'status': 'completed',
        'description': description ?? 'Transfer',
        'category': 'Transfer',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update sender balance
      await client
          .from('users')
          .update({'balance': currentBalance - amount})
          .eq('id', currentUser!.id);

      // Update recipient balance
      final recipientProfile = await client
          .from('users')
          .select('balance')
          .eq('id', recipientId)
          .maybeSingle();

      if (recipientProfile != null) {
        final recipientBalance = (recipientProfile['balance'] as num).toDouble();
        await client
            .from('users')
            .update({'balance': recipientBalance + amount})
            .eq('id', recipientId);
      }

      return true;
    } catch (e) {
      print('Send money error: $e');
      return false;
    }
  }

  static Future<bool> addMoney(double amount) async {
    if (currentUser == null) return false;

    try {
      final profile = await getUserProfile();
      if (profile == null) return false;

      final currentBalance = (profile['balance'] as num).toDouble();

      await client.from('transactions').insert({
        'user_id': currentUser!.id,
        'amount': amount,
        'type': 'deposit',
        'status': 'completed',
        'description': 'Deposit',
        'category': 'Deposit',
        'created_at': DateTime.now().toIso8601String(),
      });

      await client
          .from('users')
          .update({'balance': currentBalance + amount})
          .eq('id', currentUser!.id);

      return true;
    } catch (e) {
      print('Add money error: $e');
      return false;
    }
  }

  // ============ CARDS ============

  static Future<List<Map<String, dynamic>>> getCards() async {
    if (currentUser == null) return [];

    try {
      final data = await client
          .from('cards')
          .select()
          .eq('user_id', currentUser!.id)
          .order('is_primary', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Get cards error: $e');
      return [];
    }
  }

  static Future<bool> addCard({
    required String cardType,
    required String cardNumber,
    required String cardHolderName,
    required String expiryDate,
  }) async {
    if (currentUser == null) return false;

    try {
      final existingCards = await getCards();
      final isPrimary = existingCards.isEmpty;

      await client.from('cards').insert({
        'user_id': currentUser!.id,
        'card_type': cardType.toLowerCase(),
        'card_number': cardNumber,
        'card_holder_name': cardHolderName,
        'expiry_date': expiryDate,
        'is_active': true,
        'is_primary': isPrimary,
        'daily_limit': 5000.0,
      });
      return true;
    } catch (e) {
      print('Add card error: $e');
      return false;
    }
  }

  static Future<bool> deleteCard(String cardId) async {
    try {
      await client.from('cards').delete().eq('id', cardId);
      return true;
    } catch (e) {
      print('Delete card error: $e');
      return false;
    }
  }

  // ============ STATISTICS ============

  static Future<Map<String, dynamic>> getStatistics({String filter = 'month'}) async {
    if (currentUser == null) {
      return {'income': 0.0, 'expenses': 0.0, 'transactions': []};
    }

    try {
      DateTime startDate;
      switch (filter) {
        case 'week':
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'year':
          startDate = DateTime.now().subtract(const Duration(days: 365));
          break;
        default:
          startDate = DateTime.now().subtract(const Duration(days: 30));
      }

      final transactions = await client
          .from('transactions')
          .select()
          .or('user_id.eq.${currentUser!.id},recipient_id.eq.${currentUser!.id}')
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false);

      double income = 0;
      double expenses = 0;
      Map<String, double> categorySpending = {};

      for (var tx in transactions) {
        final amount = (tx['amount'] as num).toDouble();
        final type = tx['type'] as String;
        final isIncoming = tx['recipient_id'] == currentUser!.id || type == 'deposit';

        if (isIncoming) {
          income += amount;
        } else {
          expenses += amount;
          final category = tx['category'] as String? ?? 'Other';
          categorySpending[category] = (categorySpending[category] ?? 0) + amount;
        }
      }

      final sortedCategories = categorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return {
        'income': income,
        'expenses': expenses,
        'transactions': List<Map<String, dynamic>>.from(transactions),
        'categories': sortedCategories.take(5).map((e) => {
          'name': e.key,
          'amount': e.value,
          'percentage': expenses > 0 ? e.value / expenses : 0.0,
        }).toList(),
      };
    } catch (e) {
      print('Get statistics error: $e');
      return {'income': 0.0, 'expenses': 0.0, 'transactions': [], 'categories': []};
    }
  }
}
