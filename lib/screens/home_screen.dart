import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_services.dart';
import 'dish_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'favourites_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'suggested_meals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _loadDefaultPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDiet = prefs.getString('default_diet') ?? 'Regular';
    });
  }

  List<String> selectedLeftovers = [];

  final List<Map<String, dynamic>> leftoverOptions = [
    {"name": "Leftover Roti", "icon": Icons.bakery_dining},
    {"name": "Leftover Rice", "icon": Icons.rice_bowl},
    {"name": "Leftover Dal", "icon": Icons.soup_kitchen},
    {"name": "Leftover Potatoes", "icon": Icons.egg_alt},
  ];

  final ingredientController = TextEditingController();
  final List<String> _forbiddenNonVegKeywords = [
    'chicken',
    'mutton',
    'meat',
    'beef',
    'pork',
    'fish',
    'egg',
    'eggs',
    'prawn',
    'prawns',
    'shrimp',
    'seafood',
    'lamb',
    'turkey',
    'bacon',
    'crab',
    'duck',
  ];
  final ImagePicker _picker = ImagePicker();

  String selectedMeal = "Lunch";
  String selectedDiet = "Regular";
  String selectedTime = "30 min";
  String selectedCuisine = "North Indian";

  final Set<String> likedDishes = {};
  List<Map<String, dynamic>> displayedDishes = [];

  // Master Pool of all items
  final List<Map<String, dynamic>> dishes = [
    {
      "name": "Paneer Butter Masala",
      "description":
          "A rich North Indian paneer curry cooked with tomato, butter, cream and spices.",
      "time": "25 min",
      "spice": "Medium",
      "meal": "Lunch",
      "image":
          "https://www.ruchiskitchen.com/wp-content/uploads/2020/12/Paneer-butter-masala-recipe-3-500x500.jpg",
      "ingredients": [
        "100g Paneer (cubed)",
        "1.5 medium Tomatoes (pureed)",
        "1 tbsp Butter",
        "1 tbsp Fresh Cream",
        "1/2 tsp Garam Masala",
        "1/2 tsp Kasuri Methi (crushed)",
        "1/2 tsp Ginger-Garlic paste",
        "1/2 tsp Red Chilli powder",
        "1/4 tsp Salt (to taste)",
        "50ml Warm Water",
      ],
      "steps": [
        "[Prep - 5 min] Blend 1.5 medium tomatoes into a fine puree and cut 100g paneer into bite-sized cubes.",
        "[Medium Flame - 4 min] Melt 1 tbsp butter in a non-stick pan, add 1/2 tsp ginger-garlic paste and the fresh tomato puree. Cook until moisture evaporates and butter begins to leave the sides.",
        "[Low Flame - 3 min] Stir in 1/2 tsp red chilli powder, 1/2 tsp garam masala, and 1/4 tsp salt. Cook the spices gently for 1–2 minutes without burning.",
        "[Medium-Low Flame - 5 min] Pour in 50ml warm water and 1 tbsp fresh cream. Mix into a smooth gravy and let it come to a gentle simmer.",
        "[Low Flame - 4 min] Add 100g paneer cubes, crush 1/2 tsp kasuri methi between your palms into the gravy, cover with a lid, and simmer for 3–4 minutes until paneer is soft.",
        "[Finish - 1 min] Turn off heat, rest for 1 minute, and serve hot with 2 rotis or naan.",
      ],
    },
    {
      "name": "Aloo Paratha",
      "description":
          "Popular Indian breakfast made with wheat dough and spicy potato stuffing.",
      "time": "20 min",
      "spice": "Medium",
      "meal": "Breakfast",
      "image":
          "https://images.pexels.com/photos/33428723/pexels-photo-33428723.jpeg?cs=srgb&dl=pexels-shootsaga-33428723.jpg&fm=jpg",
      "ingredients": [
        "1/2 cup (60g) Whole Wheat Flour",
        "1 medium (120g) Potato (boiled & peeled)",
        "1 small Green Chilli (finely chopped)",
        "1 tbsp Fresh Coriander (chopped)",
        "1/4 tsp Cumin powder",
        "1/4 tsp Garam Masala",
        "1/4 tsp Salt (to taste)",
        "1.5 tbsp Ghee or Oil",
        "35ml Water (for kneading)",
      ],
      "steps": [
        "[Prep & Knead - 5 min] Mix 1/2 cup wheat flour with 35ml water and a pinch of salt. Knead into a smooth, soft dough and divide into 2 equal balls. Rest for 5 minutes.",
        "[Stuffing Prep - 3 min] In a small bowl, thoroughly mash 1 boiled potato. Mix with chopped green chilli, coriander, 1/4 tsp cumin powder, 1/4 tsp garam masala, and 1/4 tsp salt.",
        "[Assembly - 3 min] Roll one dough ball into a 4-inch circle, place half of the potato mixture in the center, pleat the edges to seal completely, dust lightly with dry flour, and roll out gently into a 6–7 inch paratha.",
        "[Medium-High Flame - 4 min] Heat a tawa/pan. Place the rolled paratha and cook for 1 minute until small bubbles appear. Flip, apply 1/2 tsp ghee to both sides, and press gently with a spatula until golden brown spots appear on both sides.",
        "[Repeat & Serve - 4 min] Repeat the rolling and cooking process for the second paratha. Serve hot with 2 tbsp plain yogurt or pickle.",
      ],
    },
    {
      "name": "Veg Pulao",
      "description":
          "Simple Indian rice dish cooked with vegetables and aromatic spices.",
      "time": "25 min",
      "spice": "Mild",
      "meal": "Lunch",
      "image":
          "https://cdn1.foodviva.com/static-content/food-images/rice-recipes/vegetable-pulav-recipe/vegetable-pulav-recipe.jpg",
      "ingredients": [
        "1/2 cup (100g) Basmati Rice",
        "1/2 small Carrot (diced)",
        "2 tbsp Green Peas",
        "1/2 small Onion (sliced thin)",
        "1/2 tsp Cumin Seeds",
        "1 small Bay Leaf",
        "1 small Green Cardamom",
        "1/4 tsp Turmeric powder",
        "1/2 tsp Salt (to taste)",
        "1 tbsp Ghee or Oil",
        "1 cup (200ml) Water",
      ],
      "steps": [
        "[Rinse & Soak - 10 min] Rinse 1/2 cup basmati rice under cold water until clear, then soak in water for 10 minutes. Drain completely.",
        "[Medium Flame - 3 min] Heat 1 tbsp ghee in a small pot or pressure cooker. Add 1/2 tsp cumin seeds, 1 bay leaf, and 1 cardamom pod. Sauté until cumin crackles.",
        "[Medium Flame - 3 min] Add sliced onion and sauté for 2 minutes until translucent. Add diced carrot, green peas, turmeric powder, and salt. Sauté for 1 minute.",
        "[High Flame - 2 min] Add the drained rice and 1 cup (200ml) water. Stir once gently and bring the water to a rolling boil.",
        "[Low Flame - 10 min] Cover tightly with a lid. Reduce flame to ultra-low and simmer undisturbed for 10–12 minutes until all water is absorbed. (If using pressure cooker: 1 whistle on medium flame).",
        "[Rest - 2 min] Turn off heat, let it rest covered for 2 minutes, fluff gently with a fork, and serve.",
      ],
    },
    {
      "name": "Masala Dosa",
      "description":
          "South Indian crispy dosa filled with spiced potato masala.",
      "time": "20 min",
      "spice": "Medium",
      "meal": "Breakfast",
      "image":
          "https://t3.ftcdn.net/jpg/16/60/96/02/360_F_1660960255_41sI73xARaZOc35Dr93TTT8BpYSMccyw.jpg",
      "ingredients": [
        "1/2 cup Fermented Dosa Batter",
        "1 medium Potato (boiled & roughly mashed)",
        "1/2 small Onion (finely chopped)",
        "1/4 tsp Mustard Seeds",
        "4–5 Fresh Curry Leaves",
        "1/4 tsp Turmeric powder",
        "1 Green Chilli (chopped)",
        "1/4 tsp Salt",
        "1.5 tbsp Oil or Ghee",
      ],
      "steps": [
        "[Medium Flame - 4 min] For the potato masala: Heat 1/2 tbsp oil in a small pan. Add 1/4 tsp mustard seeds and let them crackle. Add curry leaves, green chilli, and chopped onion; sauté for 2 minutes until soft.",
        "[Low Flame - 3 min] Add 1/4 tsp turmeric, salt, 2 tbsp water, and the mashed potato. Mix thoroughly into a moist, spreadable masala. Cook for 2 minutes and set aside.",
        "[Medium-High Flame - 2 min] Heat a flat non-stick or cast-iron tawa. Sprinkle a few drops of water to check temperature and wipe clean with a tissue.",
        "[Medium Flame - 3 min] Pour a ladleful (approx. 1/4 cup) of batter into the center. Using the back of the ladle, quickly spread in spiral outward circles into a thin, even crepe.",
        "[Medium-High Flame - 2 min] Drizzle 1 tsp oil/ghee around the edges. Cook until the underside turns golden and edges lift automatically from the pan.",
        "[Assembly & Serve - 1 min] Spread 2–3 tbsp of the prepared potato masala down the center. Fold the dosa from both sides and serve immediately with coconut chutney.",
      ],
    },
    {
      "name": "Chole Bhature",
      "description":
          "Punjabi chickpea curry cooked with onion, tomato and Indian spices.",
      "time": "25 min",
      "spice": "Spicy",
      "meal": "Lunch",
      "image":
          "https://www.shutterstock.com/image-photo/chola-bhatura-delicious-indian-breakfast-600nw-2170557223.jpg",
      "ingredients": [
        "3/4 cup (120g) Boiled Chickpeas (or canned/drained)",
        "1 small Onion (finely chopped)",
        "1 medium Tomato (pureed)",
        "1/2 tsp Ginger-Garlic paste",
        "1 tsp Chole Masala",
        "1/2 tsp Red Chilli powder",
        "1/4 tsp Cumin powder",
        "1/4 tsp Salt",
        "1 tbsp Oil",
        "75ml Water",
        "1 tbsp Fresh Coriander (for garnish)",
      ],
      "steps": [
        "[Prep - 2 min] Drain 3/4 cup boiled chickpeas and lightly mash 1 tablespoon of them with a fork to help thicken the curry.",
        "[Medium Flame - 4 min] Heat 1 tbsp oil in a small saucepan. Add chopped onions and sauté for 3–4 minutes until golden brown.",
        "[Medium Flame - 4 min] Add 1/2 tsp ginger-garlic paste and sauté for 30 seconds. Add tomato puree, 1 tsp chole masala, 1/2 tsp red chilli powder, cumin powder, and salt. Cook until oil separates from the gravy.",
        "[Medium-Low Flame - 8 min] Add boiled chickpeas and 75ml water. Mix well, cover with a lid, and simmer gently for 7–8 minutes so the chickpeas absorb all the spices.",
        "[Low Flame - 2 min] Uncover, adjust consistency with 1–2 tbsp water if too thick, garnish with chopped coriander, and serve hot.",
      ],
    },
    {
      "name": "Dal Makhani",
      "description":
          "Slow-cooked black lentils and kidney beans with butter and rich cream.",
      "time": "30 min",
      "spice": "Mild",
      "meal": "Dinner",
      "image":
          "https://img.taste.com.au/cjPf9_uA/taste/2025/03/dal-makhani-indian-butter-lentils-2-208408-1.jpg",
      "ingredients": [
        "1/2 cup Boiled Black Urad Dal & Rajma mix",
        "1.5 tbsp Butter (salted)",
        "1.5 tbsp Fresh Cream",
        "2 tbsp Tomato Puree",
        "1/2 tsp Ginger-Garlic paste",
        "1/2 tsp Kashmiri Red Chilli powder",
        "1/4 tsp Garam Masala",
        "1/4 tsp Salt",
        "80ml Warm Water",
      ],
      "steps": [
        "[Medium Flame - 3 min] Melt 1 tbsp butter in a small heavy-bottomed pot. Add 1/2 tsp ginger-garlic paste and sauté for 30 seconds until fragrant.",
        "[Medium Flame - 3 min] Stir in 2 tbsp tomato puree, 1/2 tsp Kashmiri chilli powder, and 1/4 tsp salt. Cook for 2–3 minutes until the puree thickens.",
        "[Low Flame - 15 min] Add 1/2 cup cooked black lentils and 80ml warm water. Using the back of your ladle, mash about 25% of the lentils against the side of the pot. Simmer gently on low heat for 12–15 minutes, stirring occasionally.",
        "[Low Flame - 4 min] Add the remaining 1/2 tbsp butter, 1.5 tbsp fresh cream, and 1/4 tsp garam masala. Stir continuously on low heat for 3–4 minutes until velvety and glossy.",
        "[Finish - 1 min] Turn off flame, garnish with a swirl of cream, and serve warm with steamed basmati rice or flatbread.",
      ],
    },
    {
      "name": "Shahi Paneer",
      "description":
          "A premium preparation of paneer in a thick, aromatic gravy made of almonds, cashews, and curd.",
      "time": "25 min",
      "spice": "Mild",
      "meal": "Dinner",
      "image":
          "https://i0.wp.com/geteasycooking.com/wp-content/uploads/2022/04/EASY-SHAHI-PANEER.00_16_49_21.Still002-1.jpg?resize=1024%2C576&ssl=1",
      "ingredients": [
        "100g Paneer (cubed or sliced)",
        "6 Cashew Nuts & 4 Almonds (soaked in 3 tbsp warm water)",
        "1/2 small Onion (boiled & pureed)",
        "2 tbsp Plain Yogurt (whisked smooth)",
        "1 tbsp Ghee",
        "1 Green Cardamom pod (crushed)",
        "1/4 tsp Cardamom powder",
        "A pinch of Saffron strands (soaked in 1 tbsp warm milk)",
        "1/4 tsp White/Black Pepper powder",
        "1/4 tsp Salt",
        "50ml Warm Water",
      ],
      "steps": [
        "[Nut Paste Prep - 3 min] Blend soaked cashews, almonds, and boiled onion with 2 tbsp water into an ultra-smooth white paste.",
        "[Medium-Low Flame - 3 min] Heat 1 tbsp ghee in a saucepan. Add 1 crushed cardamom pod, then add the nut-onion paste. Sauté gently for 2–3 minutes without browning the paste.",
        "[Ultra-Low Flame - 3 min] Lower the flame completely. Slowly stir in 2 tbsp whisked yogurt while stirring continuously in one direction to prevent curdling.",
        "[Low Flame - 5 min] Pour in 50ml warm water, saffron milk, 1/4 tsp pepper powder, and 1/4 tsp salt. Mix smoothly and simmer for 4–5 minutes until the gravy is glossy.",
        "[Low Flame - 4 min] Gently slide in 100g paneer cubes and sprinkle 1/4 tsp cardamom powder. Cover and simmer for 3–4 minutes so paneer absorbs the aromatic flavors.",
        "[Finish - 1 min] Turn off flame, rest for 1 minute, and serve with naan or paratha.",
      ],
    },
  ];

  @override
  void initState() {
    super.initState();

    // Set default meals dynamically via local system clock parameters
    _detectMealTypeAutomatically();

    displayedDishes = dishes.take(6).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLikedDishes();
      _shuffleDishesInstantly();
    });
  }

  // Dynamic Clock according to Device Time
  void _detectMealTypeAutomatically() {
    final int currentHour = DateTime.now().hour;

    setState(() {
      if (currentHour >= 4 && currentHour < 11) {
        selectedMeal = "Breakfast";
      } else if (currentHour >= 11 && currentHour < 16) {
        selectedMeal = "Lunch";
      } else {
        selectedMeal = "Dinner";
      }
    });
  }

  void _shuffleDishesInstantly() {
    final randomDeck = List<Map<String, dynamic>>.from(dishes)
      ..shuffle(Random());
    setState(() {
      displayedDishes = randomDeck.take(4).toList();
    });
  }

  // Complete Camera Logic with context detection parsing rules
  Future<void> _scanIngredientsWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 15),
                Text("SWAADIFY AI scanning fridge context..."),
              ],
            ),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );

        final bytes = await photo.readAsBytes();

        final model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: const String.fromEnvironment(
            'GEMINI_API_KEY',
          ), // Put your Key here
        );

        final prompt = TextPart(
          "Analyze the context of this image carefully. "
          "If the user has taken a photo of clothes, furniture, empty walls, people, animals, or non-kitchen objects, "
          "classify it as invalid context and return strictly the single word 'none'. "
          "If the image contains real raw cooking ingredients (like vegetables, dairy, grains, spices), extract them. "
          "Return ONLY a lowercase, comma-separated list of those clean ingredients (e.g., 'onion, potato, tomato'). "
          "Do not include ambient clutter or container descriptions.",
        );

        final imagePart = DataPart('image/jpeg', bytes);
        final response = await model.generateContent([
          Content.multi([prompt, imagePart]),
        ]);

        final cleanedResult = response.text?.trim().toLowerCase() ?? "";

        setState(() {
          if (cleanedResult == "none" || cleanedResult.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Context rejection alert: No valid cooking ingredients detected in this image.",
                ),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            String currentIngredients = ingredientController.text.trim();
            if (currentIngredients.isEmpty) {
              ingredientController.text = cleanedResult;
            } else {
              if (currentIngredients.endsWith(',')) {
                ingredientController.text =
                    "$currentIngredients $cleanedResult";
              } else {
                ingredientController.text =
                    "$currentIngredients, $cleanedResult";
              }
            }
          }
        });
      }
    } catch (e) {
      String errMessage = "AI Analysis Error: $e";
      if (e.toString().contains("quota") || e.toString().contains("429")) {
        errMessage =
            "SWAADIFY AI rate limit hit. Please wait 15 seconds before scanning again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errMessage), backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> _shuffleAndRefreshDishes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _shuffleDishesInstantly();
  }

  Future<void> loadLikedDishes() async {
    final favourites = await FirebaseServices.getFavouriteDishNames();
    if (!mounted) return;
    setState(() {
      likedDishes.clear();
      likedDishes.addAll(favourites);
    });
  }

  Future<void> handleLike(
    BuildContext context,
    Map<String, dynamic> dish,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ).then((_) => loadLikedDishes());
      return;
    }
    try {
      await FirebaseServices.saveFavouriteDish(dish);
      await loadLikedDishes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${dish["name"]} added to favourites"),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not save dish"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      drawer: buildAppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF0B6B1B),
        elevation: 0,
        title: Text(
          "SWAADIFY",
          style: GoogleFonts.mynerve(
            fontStyle: FontStyle.italic,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ).then((_) => loadLikedDishes());
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavouritesScreen(),
                  ),
                ).then((_) => loadLikedDishes());
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0B6B1B),
        backgroundColor: Colors.white,
        onRefresh: _shuffleAndRefreshDishes,
        child: SafeArea(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                user == null ? "What can we cook today?" : "Welcome $userName",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Enter your preferences and explore Indian vegetarian dishes.",
                style: TextStyle(fontSize: 15, color: Color(0xFF6D4C41)),
              ),
              const SizedBox(height: 18),
              buildInputSection(),
              const SizedBox(height: 24),
              const Text(
                "Famous Indian Dishes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 14),
              ...displayedDishes.map((dish) => buildDishCard(dish)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.recycling, color: Color(0xFF2D6A4F), size: 18),
            const SizedBox(width: 6),
            Text(
              "Leftover Magic (Zero-Waste)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: leftoverOptions.map((item) {
            final isSelected = selectedLeftovers.contains(item["name"]);
            return FilterChip(
              avatar: Icon(
                item["icon"],
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF1B4332),
              ),
              label: Text(item["name"]),
              selected: isSelected,
              selectedColor: const Color(0xFF2D6A4F),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              backgroundColor: const Color(0xFFF4F6F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF1B4332)
                      : Colors.grey.shade300,
                ),
              ),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedLeftovers.add(item["name"]);
                  } else {
                    selectedLeftovers.remove(item["name"]);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: ingredientController,
            decoration: InputDecoration(
              labelText: "Available Ingredients",
              hintText: "e.g. paneer, tomato, potato",
              prefixIcon: IconButton(
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF2E7D32),
                ),
                tooltip: "Scan ingredients via fridge photo",
                onPressed: _scanIngredientsWithCamera,
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          _buildLeftoverSection(),
          const SizedBox(height: 14),

          buildDropdown(
            label: "Meal Type (Auto-suggested)",
            value: selectedMeal,
            items: ["Breakfast", "Lunch", "Dinner"],
            onChanged: (value) => setState(() => selectedMeal = value!),
          ),
          const SizedBox(height: 14),
          buildDropdown(
            label: "Dietary Preference (Optional)",
            value: selectedDiet,
            items: ["Regular", "Jain"],
            onChanged: (value) => setState(() => selectedDiet = value!),
          ),
          const SizedBox(height: 14),
          buildDropdown(
            label: "Cooking Time (Optional)",
            value: selectedTime,
            items: ["15 min", "30 min", "45 min", "60 min"],
            onChanged: (value) => setState(() => selectedTime = value!),
          ),
          const SizedBox(height: 14),
          buildDropdown(
            label: "Cuisine Type (Optional)",
            value: selectedCuisine,
            items: [
              "North Indian",
              "South Indian",
              "Gujarati",
              "Punjabi",
              "Indian Snacks",
              "Festival Specials",
            ],
            onChanged: (value) => setState(() => selectedCuisine = value!),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // 1. Combine typed ingredients + leftover chips
                String typedText = ingredientController.text.trim();
                List<String> combined = [];
                if (typedText.isNotEmpty) {
                  combined.add(typedText);
                }
                combined.addAll(selectedLeftovers);

                // 2. Validate: Error ONLY if BOTH are empty
                if (combined.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Validation Error: Please specify ingredients or select a leftover item!",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                // Check for non-vegetarian items before navigating
                final textInput = ingredientController.text
                    .trim()
                    .toLowerCase();
                bool containsNonVeg = false;
                for (final keyword in _forbiddenNonVegKeywords) {
                  if (textInput.split(RegExp(r'[, \s]+')).contains(keyword) ||
                      textInput.contains(keyword)) {
                    containsNonVeg = true;
                    break;
                  }
                }

                if (containsNonVeg) {
                  _showNonVegErrorBottomSheet();
                  return; // Stops here: blocks navigation to SuggestedMealsScreen
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuggestedMealsScreen(
                      rawIngredients: combined.join(", "),
                      selectedMeal: selectedMeal,
                      selectedDiet: selectedDiet,
                      selectedTime: selectedTime,
                      selectedCuisine: selectedCuisine,
                      allDishes: dishes,
                      hasLeftovers: selectedLeftovers.isNotEmpty,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Suggest Meals"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget buildDishCard(Map<String, dynamic> dish) {
    final isLiked = likedDishes.contains(dish["name"]);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DishDetailScreen(dish: dish),
            ),
          ).then((_) => loadLikedDishes());
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  dish["image"] ?? "",
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  cacheWidth: 150,
                  cacheHeight: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 75,
                      height: 75,
                      color: const Color(0xFFE8F5E9),
                      child: const Icon(
                        Icons.broken_image,
                        size: 30,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish["name"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dish["description"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF6D4C41)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 17, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(dish["time"]),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.local_fire_department,
                          size: 17,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(dish["spice"]),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => handleLike(context, dish),
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "Guest User";
    final userEmail = user?.email ?? "Login to save recipes";

    return Drawer(
      child: Container(
        color: const Color(0xFFFFF8E7),
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final currentUser = FirebaseAuth.instance.currentUser;

                ImageProvider? drawerAvatar;
                if (currentUser?.photoURL != null &&
                    currentUser!.photoURL!.startsWith('/')) {
                  drawerAvatar = FileImage(File(currentUser.photoURL!));
                } else if (currentUser?.photoURL != null &&
                    currentUser!.photoURL!.startsWith('http')) {
                  drawerAvatar = NetworkImage(currentUser.photoURL!);
                }

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF0B6B1B)),
                  accountName: Text(
                    currentUser != null
                        ? (currentUser.displayName ?? "Swaadify User")
                        : "Guest User",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    currentUser?.email ?? "Log in to save recipes",
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: drawerAvatar,
                    child: drawerAvatar == null
                        ? const Icon(
                            Icons.person,
                            size: 45,
                            color: Color(0xFF0B6B1B),
                          )
                        : null,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.account_circle,
                color: Color(0xFF0B6B1B),
              ),
              title: const Text(
                "Profile",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                Navigator.pop(context);

                if (FirebaseAuth.instance.currentUser == null) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                  return;
                }

                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
                if (updated == true) {
                  setState(() {});
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFF0B6B1B)),
              title: const Text(
                "Favourites",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);

                if (FirebaseAuth.instance.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please login to view your favourites"),
                    ),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavouritesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF0B6B1B)),
              title: const Text(
                "Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                Navigator.pop(context);
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
                if (updated == true) {
                  _loadDefaultPreferences();
                }
              },
            ),

            const Spacer(),
            const Divider(),

            // DYNAMIC LOGIN / LOGOUT SELECTION TILES
            FirebaseAuth.instance.currentUser != null
                ? ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  )
                : ListTile(
                    leading: const Icon(Icons.login, color: Color(0xFF0B6B1B)),
                    title: const Text(
                      "Login / Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B6B1B),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);

                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (!mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      });
                    },
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6D4C41),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showNonVegErrorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFDF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.no_meals_outlined,
                  color: Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Vegetarian Ingredients Only",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "SWAADIFY is a strictly pure vegetarian platform. Please remove any non-vegetarian ingredients from your list and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Got It",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
