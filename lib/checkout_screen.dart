import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String? promoCode;
  const CheckoutScreen({super.key, this.promoCode});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _address;
  bool _placing = false;
  bool _sharingLocation = false;
  double? _lat, _lng;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.address ?? '');
  }

  Future<void> _shareLocation() async {
    setState(() => _sharingLocation = true);
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Location services are off.');
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() { _lat = pos.latitude; _lng = pos.longitude; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location shared — delivery fee will be calculated accurately.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _sharingLocation = false);
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _placing = true; _error = null; });
    try {
      final res = await ApiService.post('checkout.php', {
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        if (widget.promoCode != null) 'promo_code': widget.promoCode,
        if (_lat != null) 'latitude': _lat,
        if (_lng != null) 'longitude': _lng,
      }, auth: true);
      if (!mounted) return;
      context.read<CartProvider>().clearLocal();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: res['order_id'], finalAmount: (res['final_amount'] as num).toDouble())),
        (route) => route.isFirst,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not reach the server. Please try again.');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(_error!, style: TextStyle(color: Colors.red.shade800)),
                  ),
                const Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _sharingLocation ? null : _shareLocation,
                  icon: Icon(_lat != null ? Icons.check_circle : Icons.my_location, size: 18, color: _lat != null ? Colors.green : null),
                  label: Text(_lat != null ? 'Location shared' : 'Share my location (for accurate delivery fee)'),
                ),
                const SizedBox(height: 20),
                const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.payments_outlined),
                      SizedBox(width: 10),
                      Text('Cash on Delivery'),
                      Spacer(),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _placing ? null : _placeOrder,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _placing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Place Order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
