import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import 'dish_detail_screen.dart';

class SuggestedMealsScreen extends StatefulWidget {
  final String rawIngredients;
  final String selectedMeal;
  final String selectedDiet;
  final String selectedTime;
  final String selectedCuisine;
  final List<Map<String, dynamic>> allDishes;
  final bool hasLeftovers;

  const SuggestedMealsScreen({
    super.key,
    required this.rawIngredients,
    required this.selectedMeal,
    required this.selectedDiet,
    required this.selectedTime,
    required this.selectedCuisine,
    required this.allDishes,
    this.hasLeftovers = false,
  });

  @override
  State<SuggestedMealsScreen> createState() => _SuggestedMealsScreenState();
}

class _SuggestedMealsScreenState extends State<SuggestedMealsScreen> {
  List<Map<String, dynamic>> _aiGeneratedDishes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });

    _fetchRealWorldDishesWithAI();
  }

  Future<String> fetchDishImage(String dishName) async {
    try {
      // Search query formatted specifically for Indian recipes
      final String query = Uri.encodeComponent("$dishName indian food");

      const String apiKey = "YOUR_UNSPLASH_API_KEY";

      final response = await http.get(
        Uri.parse(
          'https://api.unsplash.com/search/photos?page=1&per_page=1&query=$query&client_id=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          return data['results'][0]['urls']['small'];
        }
      }
    } catch (e) {
      print("Error fetching dish image: $e");
    }

    return "https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=500";
  }

  Future<void> _fetchRealWorldDishesWithAI() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: const String.fromEnvironment(
          'GEMINI_API_KEY',
        ), // Gemini API Key
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final cleanInput = widget.rawIngredients.replaceAll(
        RegExp(r'Leftover \w+|Boiled Potatoes|,|\s'),
        '',
      );
      final bool isExclusiveLeftoverMode =
          widget.hasLeftovers && cleanInput.isEmpty;

      String leftoverRules = "";
      if (isExclusiveLeftoverMode) {
        leftoverRules =
            """
CRITICAL REQUIREMENT - EXHAUSTIVE GUJARATI LEFTOVER TRANSFORMATION LIST:
The user selected cooked leftovers: [${widget.rawIngredients}].
- Output AT LEAST 6 to 8 distinct dishes transforming these exact leftovers.
- ALL dish names MUST be authentic Gujarati/Indian household names in Roman script (NEVER invent generic English titles like "Masala Roti Crumble" or "Spiced Moistened Roti Pulao").

Dish Catalog Reference by Leftover:
* If 'Leftover Roti' / 'Rotli':
  1. "Vaghareli Rotli (Chaas / Dahi Vala)" - Spiced yogurt/buttermilk tempered rotli
  2. "Rotli no Chevdo" - Dry spiced tempered crumbled rotli
  3. "Rotli na Ladoo" - Sweet jaggery & ghee crumbled rotli balls
  4. "Masala Rotli Roll / Frankie" - Rolled spiced tiffin roll
  5. "Rotli na Cutlet / Tikki" - Pan-fried spiced roti patties
  6. "Rotli no Poha Style Nashto" - Mustard, peanut, turmeric breakfast style

* If 'Leftover Rice' / 'Bhaat':
  1. "Vagharelo Bhaat" - Classic Gujarati mustard, cumin, curry leaves, hing tempering
  2. "Dahi Vagharelo Bhaat (Curd Rice)" - Tempered creamy curd rice
  3. "Bhaat na Muthiya" - Steamed and pan-fried spiced rice dumplings
  4. "Bhaat na Cutlet / Crispy Tikki" - Crispy shallow-fried leftover rice patties
  5. "Masala Bhaat Poha Style" - With peanuts, onions/cabbage, turmeric
  6. "Rice Pancake / Chilla" - Quick blended rice savoury pancake

* If 'Leftover Dal':
  1. "Dal Paratha / Dal na Thepla" - Kneaded into spiced paratha/thepla dough
  2. "Dal Dhokli (Quick Pot Style)" - Wheat dumplings simmered in tempered dal
  3. "Dal Khichdi" - Combined with rice for quick comfort meal
  4. "Dal Tikki" - Thickened with flour/oats and pan-fried

* If 'Boiled Potatoes':
  1. "Sukhi Bhaji (Bateta nu Shaak)"
  2. "Bateta Vada"
  3. "Aloo Paratha"
  4. "Bateta Poha"
  5. "Crispy Bateta Chaat"
  - Keep prep time fast (under 15 minutes) and single-serving (1 person).
""";
      } else if (widget.hasLeftovers) {
        leftoverRules = """
AUTHENTIC GUJARATI LEFTOVER VARIETY:
Provide a wide selection (5 to 7 dishes) utilizing the provided leftovers with authentic Gujarati names (e.g., 'Vaghareli Rotli', 'Rotli no Chevdo', 'Vagharelo Bhaat', 'Bhaat na Muthiya').
""";
      }

      final String prompt =
          '''
You are an expert strict-inventory culinary instructor for the app SWAADIFY.

TARGET AUDIENCE:
- College students and working professionals with 0 prior cooking experience.
- PORTION SIZE: Exactly 1 Person / 1 Serving.

USER AVAILABLE MAIN INGREDIENTS: [${widget.rawIngredients}]
MEAL TYPE: ${widget.selectedMeal}
DIETARY PREFERENCE: ${widget.selectedDiet}
COOKING TIME LIMIT: ${widget.selectedTime}
CUISINE TYPE: ${widget.selectedCuisine}

NAMING RULE:
All dish names MUST be the traditional, authentic names in Roman script (e.g., "Vaghareli Rotli", "Sev Tameta nu Shaak", "Dal Tadka", "Poha"), followed by a simple 1-line English subtitle in the description.

INVENTORY RULES (SMART PANTRY STAPLES):
1. MAIN INGREDIENTS (STRICT SUBSET): Main components (veggies, paneer, meats, grains, dals) MUST strictly come from [${widget.rawIngredients}]. Do NOT add unlisted main vegetables, flours, or proteins.
2. ALLOWED PANTRY STAPLES: You MAY assume standard household staples are available even if unlisted: Cooking Oil, Ghee, Butter, Water, Salt, and basic Indian dry spices (turmeric, chili powder, cumin, garam masala).
3. VARIETY REQUIREMENT: Suggest AT LEAST 6 to 8 distinct Indian recipes by combining the available main ingredients in different ways (e.g., curry style, dry stir-fry style, gravy style, or mash).

PRECISE BEGINNER STEP RULES:
- PORTION: strictly calibrated for 1 PERSON / 1 SERVING.
- MEASUREMENTS: Use precise, human-readable quantities (e.g., "1 tbsp oil", "1/2 tsp red chili powder", "100g paneer cubes", "1 medium onion").
- TIMINGS & HEAT: Every step must include exact heat levels (Low/Medium/High) and exact timer minutes (e.g., "Heat oil on Medium for 2 mins", "Sauté onions on Medium for 4 mins until golden brown").

OUTPUT FORMAT:
Do not include the app name or prefix "SWAADIFY" inside the dish "name" field. Return natural Indian dish titles like "Masala Paneer Fry" or "Jeera Rice".s
Return strictly raw JSON format without markdown wrappers.
A JSON object with key "meals" containing a list of recipes.
Each recipe MUST contain: "name", "description", "time", "portion", "spice", "meal", "image", "ingredients" (list of strings with 1-person quantities), and "steps" (list of strings with step-by-step beginner instructions, heat levels, and timings).
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final String rawJsonString = response.text?.trim() ?? "[]";

      final dynamic decodedJson = jsonDecode(rawJsonString);

      List<dynamic> decodedList = [];

      if (decodedJson is Map<String, dynamic>) {
        if (decodedJson.containsKey('meals') && decodedJson['meals'] is List) {
          decodedList = decodedJson['meals'];
        } else if (decodedJson.containsKey('dishes') &&
            decodedJson['dishes'] is List) {
          decodedList = decodedJson['dishes'];
        } else {
          decodedList = [];
        }
      } else if (decodedJson is List) {
        decodedList = decodedJson;
      }

      List<Map<String, dynamic>> tempDishes = decodedList
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      for (Map<String, dynamic> dish in tempDishes) {
        String name = (dish["name"] ?? "Indian Food").toString().replaceAll(
          " ",
          ",",
        );
        dish["image"] =
            "https://source.unsplash.com/featured/500x500/?$name,indianfood";
      }

      setState(() {
        _aiGeneratedDishes = tempDishes;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      // ignore: avoid_print
      print("❌ GEMINI SYSTEM ERROR: $e");

      setState(() {
        _errorMessage = "System Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: const Text("Dishes For You"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    SizedBox(height: 16),
                    Text(
                      "SWAADIFY AI searching food dishes for you...",
                      style: TextStyle(
                        color: Color(0xFF6D4C41),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : _aiGeneratedDishes.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_food_rounded,
                        size: 70,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No Strict Matches Found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "No dishes can be prepared using only: '${widget.rawIngredients}'. Try adding basic ingredients like oil, flour or spices to expand possibilities!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _aiGeneratedDishes.length,
                itemBuilder: (context, index) {
                  final dish = _aiGeneratedDishes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DishDetailScreen(dish: dish),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                dish["image"] ??
                                    "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?q=80&w=500",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF0B6B1B),
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: const Color(0xFFE8F5E9),
                                    child: const Icon(
                                      Icons.restaurant,
                                      color: Color(0xFF2E7D32),
                                      size: 32,
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
                                    dish["name"] ?? "Indian Dish",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    dish["description"] ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF6D4C41),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer,
                                        size: 17,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(dish["time"] ?? widget.selectedTime),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.local_fire_department,
                                        size: 17,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(dish["spice"] ?? "Medium"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
