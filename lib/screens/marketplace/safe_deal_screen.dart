import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class SafeDealScreen extends StatefulWidget {
  final Listing listing;

  const SafeDealScreen({super.key, required this.listing});

  @override
  State<SafeDealScreen> createState() => _SafeDealScreenState();
}

class _SafeDealScreenState extends State<SafeDealScreen> {
  bool _isProcessing = false;
  final _apiService = ApiService();

  Future<void> _initiateSafeDeal() async {
    final userProvider = context.read<UserProvider>();
    if (!userProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Simulate UPI payment delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, we would get a UPI ref from the payment gateway
      final upiRef = 'UPI${DateTime.now().millisecondsSinceEpoch}';

      final response = await _apiService.post('/escrow/init', data: {
        'listing_id': widget.listing.id,
        'buyer_id': userProvider.currentUser!.id,
        'seller_id': widget.listing.userId,
        'amount': widget.listing.price,
        'upi_ref': upiRef,
      });

      if (mounted) {
        setState(() => _isProcessing = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Safe Deal Initiated!'),
            content: const Text(
              'Your payment is now held securely in escrow. '
              'The seller has been notified. '
              'Once you receive the item, please confirm receipt in your orders to release the funds.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to listing
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Deal Protection'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.security, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text(
              'How Safe Deal Works',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildStep(
              '1',
              'Pay Securely',
              'You pay ₹${widget.listing.price.toInt()} via our secure in-app UPI system.',
            ),
            _buildStep(
              '2',
              'Money Held in Escrow',
              'IndiaWish holds your money safely. The seller cannot access it yet.',
            ),
            _buildStep(
              '3',
              'Meet & Collect',
              'Meet the seller and inspect your item. Never pay outside the app.',
            ),
            _buildStep(
              '4',
              'Confirm Receipt',
              'Once you have the item, confirm it in the app to release funds to the seller.',
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _initiateSafeDeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.swiggyOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Pay via UPI (Safe Deal)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '100% Refundable if the deal doesn\'t happen.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
