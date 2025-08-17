import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartphone_mobile_client/providers/cart_manager_provider.dart';
import 'package:smartphone_mobile_client/screens/cart_screen.dart';

class CartFAB extends StatelessWidget {
  const CartFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartManagerProvider>(
      builder: (context, cartManager, child) {
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
          },
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          child: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              if (cartManager.itemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cartManager.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
