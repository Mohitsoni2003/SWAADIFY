import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firebase_services.dart';
import 'dish_detail_screen.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),

      appBar: AppBar(
        title: const Text("My Favourites"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseServices.getFavouriteDishes(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          final favourites = snapshot.data?.docs ?? [];

          if (favourites.isEmpty) {
            return const Center(
              child: Text(
                "No favourite dishes yet",
                style: TextStyle(fontSize: 18, color: Color(0xFF6D4C41)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favourites.length,

            itemBuilder: (context, index) {
              final dish = favourites[index].data();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),

                  // FIX: SWAPPED OUT OLD RESTAURANT ICON CONTAINER FOR CORNER-CLIPPED NETWORK IMAGE
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      dish["image"] ?? "",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      cacheWidth:
                          120, // Prevents list scrolling framerate stutter lag
                      cacheHeight:
                          120, // Keeps runtime engine layout memory completely optimized
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFE8F5E9),
                          child: const Icon(
                            Icons.broken_image,
                            size: 24,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
                  ),

                  title: Text(
                    dish["name"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    dish["description"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  trailing: const Icon(Icons.favorite, color: Colors.red),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DishDetailScreen(dish: dish),
                      ),
                    );
                  },

                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Remove from favourites?"),
                          content: Text(
                            "Do you want to remove ${dish["name"]} from your favourites?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseServices.removeFavouriteDish(
                                  dish["name"],
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Removed from favourites"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                "Remove",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
