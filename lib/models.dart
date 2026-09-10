class Category {
  final int id;
  final String name;
  final String? image;
  Category({required this.id, required this.name, this.image});
  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: j['id'], name: j['name'], image: j['image']);
}

class Food {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final double price;
  final double? halfPrice;
  final bool hasPortion;
  final bool isVeg;
  final double rating;
  final int reviewCount;
  final String? image;
  final bool isAvailable;

  Food({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    required this.price,
    this.halfPrice,
    required this.hasPortion,
    required this.isVeg,
    required this.rating,
    this.reviewCount = 0,
    this.image,
    this.isAvailable = true,
  });

  factory Food.fromJson(Map<String, dynamic> j) => Food(
        id: j['id'],
        categoryId: j['category_id'] ?? 0,
        categoryName: j['category_name'] ?? '',
        name: j['name'],
        description: j['description'],
        price: (j['price'] as num).toDouble(),
        halfPrice: j['half_price'] != null ? (j['half_price'] as num).toDouble() : null,
        hasPortion: j['has_portion'] ?? false,
        isVeg: j['is_veg'] ?? true,
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: j['review_count'] ?? 0,
        image: j['image'],
        isAvailable: j['is_available'] ?? true,
      );

  double get displayPrice => hasPortion && halfPrice != null ? halfPrice! : price;
}

class Review {
  final String userName;
  final int rating;
  final String? review;
  final String createdAt;
  Review({required this.userName, required this.rating, this.review, required this.createdAt});
  factory Review.fromJson(Map<String, dynamic> j) => Review(
        userName: j['user_name'] ?? 'Anonymous',
        rating: j['rating'] ?? 0,
        review: j['review'],
        createdAt: j['created_at'] ?? '',
      );
}

class CartItem {
  final int cartId;
  final int foodId;
  final String name;
  final String? image;
  final bool isVeg;
  final String portion;
  final double unitPrice;
  final int quantity;

  CartItem({
    required this.cartId,
    required this.foodId,
    required this.name,
    this.image,
    required this.isVeg,
    required this.portion,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        cartId: j['cart_id'],
        foodId: j['food_id'],
        name: j['name'],
        image: j['image'],
        isVeg: j['is_veg'] ?? true,
        portion: j['portion'] ?? 'full',
        unitPrice: (j['unit_price'] as num).toDouble(),
        quantity: j['quantity'],
      );
}

class OrderSummary {
  final int id;
  final double finalAmount;
  final String paymentMethodLabel;
  final String orderStatus;
  final String orderStatusLabel;
  final bool canCancel;
  final String createdAt;

  OrderSummary({
    required this.id,
    required this.finalAmount,
    required this.paymentMethodLabel,
    required this.orderStatus,
    required this.orderStatusLabel,
    required this.canCancel,
    required this.createdAt,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> j) => OrderSummary(
        id: j['id'],
        finalAmount: (j['final_amount'] as num).toDouble(),
        paymentMethodLabel: j['payment_method_label'] ?? '',
        orderStatus: j['order_status'] ?? '',
        orderStatusLabel: j['order_status_label'] ?? '',
        canCancel: j['can_cancel'] ?? false,
        createdAt: j['created_at'] ?? '',
      );
}

class OrderItem {
  final String foodName;
  final double price;
  final int quantity;
  OrderItem({required this.foodName, required this.price, required this.quantity});
  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        foodName: j['food_name'],
        price: (j['price'] as num).toDouble(),
        quantity: j['quantity'],
      );
  double get lineTotal => price * quantity;
}

class OrderDetail {
  final int id;
  final String name;
  final String phone;
  final String address;
  final double totalAmount;
  final double discountAmount;
  final double deliveryFee;
  final double finalAmount;
  final String? promoCode;
  final String paymentMethodLabel;
  final String orderStatusLabel;
  final bool canCancel;
  final String? cancelReason;
  final String createdAt;
  final List<OrderItem> items;

  OrderDetail({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.totalAmount,
    required this.discountAmount,
    required this.deliveryFee,
    required this.finalAmount,
    this.promoCode,
    required this.paymentMethodLabel,
    required this.orderStatusLabel,
    required this.canCancel,
    this.cancelReason,
    required this.createdAt,
    required this.items,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> j) => OrderDetail(
        id: j['id'],
        name: j['name'] ?? '',
        phone: j['phone'] ?? '',
        address: j['address'] ?? '',
        totalAmount: (j['total_amount'] as num).toDouble(),
        discountAmount: (j['discount_amount'] as num).toDouble(),
        deliveryFee: (j['delivery_fee'] as num).toDouble(),
        finalAmount: (j['final_amount'] as num).toDouble(),
        promoCode: j['promo_code'],
        paymentMethodLabel: j['payment_method_label'] ?? '',
        orderStatusLabel: j['order_status_label'] ?? '',
        canCancel: j['can_cancel'] ?? false,
        cancelReason: j['cancel_reason'],
        createdAt: j['created_at'] ?? '',
        items: (j['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      );
}

class AppUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  AppUser({required this.id, required this.name, required this.email, required this.phone, this.address});
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        phone: j['phone'],
        address: j['address'],
      );
}
