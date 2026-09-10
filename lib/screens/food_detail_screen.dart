import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final int foodId;
  const FoodDetailScreen({super.key, required this.foodId});
  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  String _portion = 'full';
  int _qty = 1;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.get('food-detail.php?id=${widget.foodId}', auth: true);
      final food = res['food'];
      setState(() {
        _data = food;
        _portion = food['has_portion'] && food['half_price'] != null ? 'half' : 'full';
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not load this item.');
    } finally {
      setState(() => _loading = false);
    }
  }

  double get _unitPrice {
    final f = _data!;
    return _portion == 'half' ? (f['half_price'] as num).toDouble() : (f['price'] as num).toDouble();
  }

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    try {
      await context.read<CartProvider>().add(widget.foodId, portion: _portion, qty: _qty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart'), duration: Duration(seconds: 1)));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _showRateDialog() async {
    int rating = (_data?['my_rating']?['rating'] as int?) ?? 5;
    final reviewCtrl = TextEditingController(text: _data?['my_rating']?['review'] ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Rate this dish'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                      icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                      onPressed: () => setDialogState(() => rating = i + 1),
                    )),
              ),
              TextField(
                controller: reviewCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Write a review (optional)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
          ],
        ),
      ),
    );
    if (result != true) return;
    try {
      await ApiService.post('rate-food.php', {'food_id': widget.foodId, 'rating': rating, 'review': reviewCtrl.text.trim()}, auth: true);
      _load();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _data == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error ?? 'Not found')));
    }
    final f = _data!;
    final hasPortion = f['has_portion'] == true && f['half_price'] != null;
    final available = f['is_available'] == true;
    final reviews = (f['reviews'] as List).map((e) => Review.fromJson(e)).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: f['image'] != null
                  ? CachedNetworkImage(imageUrl: f['image'], fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade200, child: const Icon(Icons.fastfood, size: 60)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${f['rating']} / 5', style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (f['review_count'] > 0) Text('  (${f['review_count']} reviews)', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (f['description'] != null) Text(f['description'], style: const TextStyle(color: Colors.black87, height: 1.4)),
                  const SizedBox(height: 16),
                  if (!available)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Text('This item is currently unavailable.', style: TextStyle(color: Colors.red)),
                    ),
                  if (available && hasPortion) ...[
                    const Text('Choose Portion', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text('Half Plate — ₹${(f['half_price'] as num).toStringAsFixed(0)}'),
                            selected: _portion == 'half',
                            onSelected: (_) => setState(() => _portion = 'half'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text('Full Plate — ₹${(f['price'] as num).toStringAsFixed(0)}'),
                            selected: _portion == 'full',
                            onSelected: (_) => setState(() => _portion = 'full'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (available) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${_unitPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(onPressed: () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1), icon: const Icon(Icons.remove_circle_outline)),
                            Text('$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(onPressed: () => setState(() => _qty++), icon: const Icon(Icons.add_circle_outline)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _adding ? null : _addToCart,
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: _adding
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Add to Cart'),
                      ),
                    ),
                  ],
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (f['can_rate'] == true)
                        TextButton(onPressed: _showRateDialog, child: const Text('Rate this dish')),
                    ],
                  ),
                  if (reviews.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No reviews yet.', style: TextStyle(color: Colors.grey))),
                  ...reviews.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Row(children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 14, color: Colors.amber))),
                              ],
                            ),
                            if (r.review != null && r.review!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(r.review!)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
