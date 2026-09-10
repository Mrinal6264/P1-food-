import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../widgets/food_card.dart';
import 'food_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CartProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const _MenuTab(), const OrdersScreen(embedded: true), const AccountScreen(embedded: true)];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: 'Menu'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? Consumer<CartProvider>(
              builder: (context, cart, _) => cart.itemCount > 0
                  ? FloatingActionButton.extended(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                      icon: const Icon(Icons.shopping_cart),
                      label: Text('View Cart (${cart.itemCount})'),
                    )
                  : const SizedBox.shrink(),
            )
          : null,
    );
  }
}

class _MenuTab extends StatefulWidget {
  const _MenuTab();
  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  List<Category> _categories = [];
  List<Food> _foods = [];
  List<Map<String, dynamic>> _banners = [];
  int? _selectedCategory;
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.get('categories.php'),
        ApiService.get('foods.php'),
        ApiService.get('banners.php'),
      ]);
      setState(() {
        _categories = (results[0]['categories'] as List).map((e) => Category.fromJson(e)).toList();
        _foods = (results[1]['foods'] as List).map((e) => Food.fromJson(e)).toList();
        _banners = List<Map<String, dynamic>>.from(results[2]['banners']);
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Could not reach the server. Check your connection and the app\'s configured domain.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _search(String q) async {
    setState(() { _loading = true; _selectedCategory = null; });
    try {
      final res = await ApiService.get('foods.php?search=${Uri.encodeQueryComponent(q)}');
      setState(() => _foods = (res['foods'] as List).map((e) => Food.fromJson(e)).toList());
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _selectCategory(int? id) async {
    setState(() { _selectedCategory = id; _loading = true; });
    try {
      final res = await ApiService.get(id == null ? 'foods.php' : 'foods.php?category_id=$id');
      setState(() => _foods = (res['foods'] as List).map((e) => Food.fromJson(e)).toList());
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _addToCart(Food food) async {
    try {
      await context.read<CartProvider>().add(food.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${food.name} added to cart'), duration: const Duration(seconds: 1)));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: const Text('FoodieHub', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search for dishes...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: _search,
                ),
              ),
            ),
            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off, size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: _loadAll, child: const Text('Retry')),
                    ],
                  ),
                ),
              ),
            if (_banners.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _banners.length,
                    itemBuilder: (_, i) => Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
                      child: _banners[i]['image'] != null
                          ? CachedNetworkImage(imageUrl: _banners[i]['image'], fit: BoxFit.cover)
                          : Container(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
            if (_categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 92,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _CategoryChip(label: 'All', image: null, selected: _selectedCategory == null, onTap: () => _selectCategory(null)),
                      ..._categories.map((c) => _CategoryChip(
                            label: c.name,
                            image: c.image,
                            selected: _selectedCategory == c.id,
                            onTap: () => _selectCategory(c.id),
                          )),
                    ],
                  ),
                ),
              ),
            if (_loading)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())))
            else if (_error == null && _foods.isEmpty)
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No dishes found.'))))
            else
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FoodCard(
                      food: _foods[i],
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FoodDetailScreen(foodId: _foods[i].id))),
                      onAdd: () => _addToCart(_foods[i]),
                    ),
                    childCount: _foods.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? image;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, this.image, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 2 : 1),
                color: Colors.grey.shade100,
              ),
              clipBehavior: Clip.antiAlias,
              child: image != null
                  ? CachedNetworkImage(imageUrl: image!, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.fastfood))
                  : Icon(Icons.apps, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
