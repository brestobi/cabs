import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class WalletService {
  final _supabase = SupabaseClientConfig.client;

  Future<void> topUpWallet(String userId, double amount) async {
    final profile = await _supabase.from('profiles').select('wallet_balance').eq('id', userId).single();
    final double currentBalance = profile['wallet_balance'] ?? 0.0;
    
    await _supabase.from('profiles').update({
      'wallet_balance': currentBalance + amount,
    }).eq('id', userId);
  }

  Future<void> processPayment({
    required String passengerId,
    required String driverId,
    required double amount,
  }) async {
    // 1. Deduct from passenger
    final passengerProfile = await _supabase.from('profiles').select('wallet_balance').eq('id', passengerId).single();
    final double pBalance = passengerProfile['wallet_balance'] ?? 0.0;
    
    await _supabase.from('profiles').update({
      'wallet_balance': pBalance - amount,
    }).eq('id', passengerId);

    // 2. Credit to driver
    final driverProfile = await _supabase.from('profiles').select('total_earnings').eq('id', driverId).single();
    final double dEarnings = driverProfile['total_earnings'] ?? 0.0;

    await _supabase.from('profiles').update({
      'total_earnings': dEarnings + amount,
    }).eq('id', driverId);
  }
}
