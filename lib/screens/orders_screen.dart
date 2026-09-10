import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  final bool embedded;
  const OrdersScreen({super.key, this.embedded = false});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderSummary> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.get('orders.php', auth: true);
      setState(() => _orders = (res['orders'] as List).map((e) => OrderSummary.fromJson(e)).toList());
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not load orders.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'out_for_delivery': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ListView(children: [Padding(padding: const EdgeInsets.all(40), child: Center(child: Text(_error!)))])
              : _orders.isEmpty
                  ? ListView(children: const [
                      Padding(
                        padding: EdgeInsets.all(60),
                        child: Center(child: Column(children: [Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey), SizedBox(height: 12), Text('No orders yet', style: TextStyle(color: Colors.grey))])),
                      )
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _orders.length,
                      itemBuilder: (context, i) {
                        final o = _orders[i];
                        DateTime? date;
                        try { date = DateTime.parse(o.createdAt); } catch (_) {}
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id))).then((_) => _load()),
                            title: Text('Order #${o.id} · ₹${o.finalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(date != null ? DateFormat('d MMM yyyy, h:mm a').format(date) : o.createdAt),
                            trailing: Chip(
                              label: Text(o.orderStatusLabel, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              backgroundColor: _statusColor(o.orderStatus),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        );
                      },
                    ),
    );

    if (widget.embedded) {
      return Scaffold(appBar: AppBar(title: const Text('My Orders'), automaticallyImplyLeading: false), body: SafeArea(child: body));
    }
    return Scaffold(appBar: AppBar(title: const Text('My Orders')), body: body);
  }
}
