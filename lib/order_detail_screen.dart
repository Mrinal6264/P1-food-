import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderDetail? _order;
  bool _loading = true;
  String? _error;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.get('order-detail.php?id=${widget.orderId}', auth: true);
      setState(() => _order = OrderDetail.fromJson(res['order']));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not load this order.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _cancelOrder() async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: TextField(controller: reasonCtrl, decoration: const InputDecoration(hintText: 'Reason (optional)', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, cancel')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _cancelling = true);
    try {
      await ApiService.post('order-cancel.php', {'order_id': widget.orderId, 'reason': reasonCtrl.text.trim()}, auth: true);
      _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_order!.orderStatusLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(_order!.paymentMethodLabel, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              if (_order!.cancelReason != null && _order!.cancelReason!.isNotEmpty)
                                Padding(padding: const EdgeInsets.only(top: 6), child: Text('Reason: ${_order!.cancelReason}', style: const TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_order!.name), Text(_order!.phone), Text(_order!.address),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ..._order!.items.map((it) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text('${it.foodName} x${it.quantity}')),
                                        Text('₹${it.lineTotal.toStringAsFixed(0)}'),
                                      ],
                                    ),
                                  )),
                              const Divider(),
                              _priceRow('Subtotal', _order!.totalAmount),
                              if (_order!.discountAmount > 0) _priceRow('Discount', -_order!.discountAmount, color: Colors.green),
                              _priceRow('Delivery Fee', _order!.deliveryFee),
                              const Divider(),
                              _priceRow('Total', _order!.finalAmount, bold: true),
                            ],
                          ),
                        ),
                      ),
                      if (_order!.canCancel) ...[
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: _cancelling ? null : _cancelOrder,
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: _cancelling ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cancel Order'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _priceRow(String label, double value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('₹${value.toStringAsFixed(0)}', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
