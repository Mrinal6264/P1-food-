import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'order_detail_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final int orderId;
  final double finalAmount;
  const OrderSuccessScreen({super.key, required this.orderId, required this.finalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 84),
                const SizedBox(height: 20),
                const Text('Order Placed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Order #$orderId · ₹${finalAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('You will pay in cash when it arrives.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId))),
                    child: const Text('Track Order'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false),
                    child: const Text('Back to Menu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
