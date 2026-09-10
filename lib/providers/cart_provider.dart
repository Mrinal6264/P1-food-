import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];
  double subtotal = 0;
  bool isLoading = false;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('cart.php', auth: true);
      items = (res['items'] as List).map((e) => CartItem.fromJson(e)).toList();
      subtotal = (res['subtotal'] as num).toDouble();
    } catch (_) {
      items = [];
      subtotal = 0;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(int foodId, {String portion = 'full', int qty = 1}) async {
    await ApiService.post('cart-action.php', {'action': 'add', 'food_id': foodId, 'portion': portion, 'qty': qty}, auth: true);
    await load();
  }

  Future<void> increase(int cartId) async {
    await ApiService.post('cart-action.php', {'action': 'increase', 'cart_id': cartId}, auth: true);
    await load();
  }

  Future<void> decrease(int cartId) async {
    await ApiService.post('cart-action.php', {'action': 'decrease', 'cart_id': cartId}, auth: true);
    await load();
  }

  Future<void> remove(int cartId) async {
    await ApiService.post('cart-action.php', {'action': 'remove', 'cart_id': cartId}, auth: true);
    await load();
  }

  void clearLocal() {
    items = [];
    subtotal = 0;
    notifyListeners();
  }
}
