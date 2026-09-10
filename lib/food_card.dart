import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const FoodCard({super.key, required this.food, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  food.image != null
                      ? CachedNetworkImage(imageUrl: food.image!, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200))
                      : Container(color: Colors.grey.shade200, child: const Icon(Icons.fastfood, size: 40, color: Colors.grey)),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border.all(color: food.isVeg ? Colors.green : Colors.red, width: 1.5),
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: food.isVeg ? Colors.green : Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(food.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${food.displayPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      InkWell(
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
