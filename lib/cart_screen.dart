import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoCtrl = TextEditingController();
  double? _discount;
  String? _promoMessage;
  bool _promoValid = false;
  bool _applyingPromo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CartProvider>().load());
  }

  Future<void> _applyPromo(double subtotal) async {
    if (_promoCtrl.text.trim().isEmpty) return;
    setState(() { _applyingPromo = true; _promoMessage = null; });
    try {
      final res = await ApiService.post('promo-apply.php', {'code': _promoCtrl.text.trim()}, auth: true);
      setState(() {
        _promoValid = res['valid'] == true;
        _promoMessage = res['message'];
        _discount = _promoValid ? (res['discount'] as num).toDouble() : null;
      });
    } catch (_) {
      setState(() { _promoValid = false; _promoMessage = 'Could not validate promo code.'; });
    } finally {
      setState(() => _applyingPromo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading) return const Center(child: CircularProgressIndicator());
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Your cart is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          final finalTotal = cart.subtotal - (_promoValid ? (_discount ?? 0) : 0);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  itemBuilder: (context, i) {
                    final item = cart.items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 60, height: 60,
                                child: item.image != null
                                    ? CachedNetworkImage(imageUrl: item.image!, fit: BoxFit.cover)
                                    : Container(color: Colors.grey.shade200, child: const Icon(Icons.fastfood)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  if (item.portion == 'half') const Text('Half Plate', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('₹${item.unitPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.read<CartProvider>().decrease(item.cartId),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  onPressed: () => context.read<CartProvider>().increase(item.cartId),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))]),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoCtrl,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(hintText: 'Promo code', isDense: true, border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _applyingPromo ? null : () => _applyPromo(cart.subtotal),
                            child: _applyingPromo ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Apply'),
                          ),
                        ],
                      ),
                      if (_promoMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(_promoMessage!, style: TextStyle(color: _promoValid ? Colors.green : Colors.red, fontSize: 13)),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'), Text('₹${cart.subtotal.toStringAsFixed(0)}'),
                        ],
                      ),
                      if (_promoValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [const Text('Discount'), Text('-₹${(_discount ?? 0).toStringAsFixed(0)}', style: const TextStyle(color: Colors.green))],
                          ),
                        ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total (excl. delivery)', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₹${finalTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CheckoutScreen(promoCode: _promoValid ? _promoCtrl.text.trim() : null),
                        )),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
