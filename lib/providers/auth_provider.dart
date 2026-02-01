import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  Map<String, dynamic>? _user;
  String? _error;

  AuthStatus get status => _status;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  String get userName => _user?['full_name'] ?? 'User';
  String get userEmail => _user?['email'] ?? '';
  double get balance => (_user?['balance'] as num?)?.toDouble() ?? 0.0;
  String get formattedBalance => '\$${_formatNumber(balance)}';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Listen to auth state changes
    SupabaseService.client.auth.onAuthStateChange.listen((data) async {
      if (data.session != null) {
        await loadUserProfile();
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });

    // Check current session
    if (SupabaseService.isAuthenticated) {
      await loadUserProfile();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final profile = await SupabaseService.getUserProfile();
      if (profile != null) {
        _user = profile;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        await loadUserProfile();
        return true;
      } else {
        _error = 'Signup failed. Please try again.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _error = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await loadUserProfile();
        return true;
      } else {
        _error = 'Login failed. Please check your credentials.';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _error = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    await loadUserProfile();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
