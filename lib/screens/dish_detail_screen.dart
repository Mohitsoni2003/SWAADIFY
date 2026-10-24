import 'package:flutter/material.dart';

class DishDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dish;

  const DishDetailScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: Text(dish["name"]),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  dish["image"] ?? "",
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: Color(0xFF2E7D32),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              dish["name"],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              dish["description"],
              style: const TextStyle(fontSize: 16, color: Color(0xFF6D4C41)),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                infoBox(Icons.timer, dish["time"]),
                const SizedBox(width: 10),
                infoBox(Icons.local_fire_department, dish["spice"]),
                const SizedBox(width: 10),
                infoBox(Icons.restaurant, dish["meal"]),
              ],
            ),

            const SizedBox(height: 25),

            sectionTitle("Ingredients"),
            ...List<String>.from(dish["ingredients"]).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• $item", style: const TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 22),

            sectionTitle("Cooking Steps"),
            ...List<String>.from(dish["steps"]).asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "${entry.key + 1}. ${entry.value}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget infoBox(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
