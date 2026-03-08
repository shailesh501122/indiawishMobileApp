import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';

/// Allows users to verify their phone number to earn a "Phone Verified" badge.
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _apiService = ApiService();

  bool _otpSent = false;
  bool _loading = false;
  String? _statusMessage;
  String? _debugOtp; // Shown in dev mode

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _statusMessage = 'Enter a valid 10-digit number');
      return;
    }
    setState(() { _loading = true; _statusMessage = null; });

    final res = await _apiService.sendPhoneOtp('+91$phone');
    if (!mounted) return;

    if (res != null) {
      setState(() {
        _otpSent = true;
        _loading = false;
        _statusMessage = 'OTP sent! Check your phone.';
        _debugOtp = res['debug_otp']?.toString(); // dev only
      });
    } else {
      setState(() { _loading = false; _statusMessage = 'Failed to send OTP. Try again.'; });
    }
  }

  Future<void> _confirmOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    setState(() { _loading = true; _statusMessage = null; });

    final res = await _apiService.confirmPhoneOtp('+91$phone', otp);
    if (!mounted) return;

    if (res != null) {
      setState(() { _loading = false; _statusMessage = '✅ Phone verified! Badge earned.'; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true); // Return true = success
    } else {
      setState(() { _loading = false; _statusMessage = '❌ Invalid OTP. Try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Phone Number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF002F5A), Color(0xFF0052A0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text('Get Your Phone Verified Badge', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'Verified sellers get 3x more responses from buyers.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                    color: AppColors.accent,
                  ),
                  child: const Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    enabled: !_otpSent,
                    decoration: const InputDecoration(
                      hintText: '9876543210',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(8))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            if (_otpSent) ...[
              const SizedBox(height: 20),
              const Text('Enter OTP', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText)),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: '123456',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              if (_debugOtp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('🛠 Dev OTP: $_debugOtp', style: const TextStyle(color: Colors.orange, fontSize: 12)),
                ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : (_otpSent ? _confirmOtp : _sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_otpSent ? 'Verify OTP' : 'Send OTP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(_statusMessage!, style: TextStyle(color: _statusMessage!.startsWith('✅') ? Colors.green : Colors.red, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}
