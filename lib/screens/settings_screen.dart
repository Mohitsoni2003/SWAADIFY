import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Exact App Colors
  static const Color appGreen = Color(0xFF1B5E20); // Authentic Swaadify Green
  static const Color bgCream = Color(0xFFFFFDF6);

  String _defaultDiet = 'Regular';
  String _defaultSpice = 'Medium';
  late final TextEditingController _excludedController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _excludedController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _defaultDiet = prefs.getString('default_diet') ?? 'Regular';
        _defaultSpice = prefs.getString('default_spice') ?? 'Medium';
        _excludedController.text =
            prefs.getString('excluded_ingredients') ?? '';
      });
    } catch (e) {
      debugPrint("Error loading settings: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_diet', _defaultDiet);
      await prefs.setString('default_spice', _defaultSpice);
      await prefs.setString(
        'excluded_ingredients',
        _excludedController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Preferences saved successfully!"),
            backgroundColor: appGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error saving settings: $e");
    }
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_dishes');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Search cache cleared successfully!"),
            backgroundColor: appGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error clearing cache: $e");
    }
  }

  @override
  void dispose() {
    _excludedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: appGreen))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Cooking Preferences",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appGreen,
                  ),
                ),
                const SizedBox(height: 14),

                // Dietary Preference
                DropdownButtonFormField<String>(
                  value: _defaultDiet,
                  decoration: InputDecoration(
                    labelText: "Default Dietary Preference",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Regular", child: Text("Regular")),
                    DropdownMenuItem(value: "Jain", child: Text("Jain")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _defaultDiet = val);
                  },
                ),
                const SizedBox(height: 14),

                // Spice Level
                DropdownButtonFormField<String>(
                  value: _defaultSpice,
                  decoration: InputDecoration(
                    labelText: "Default Spice Level",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Mild", child: Text("Mild")),
                    DropdownMenuItem(value: "Medium", child: Text("Medium")),
                    DropdownMenuItem(value: "Spicy", child: Text("Spicy")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _defaultSpice = val);
                  },
                ),
                const SizedBox(height: 14),

                // Excluded Ingredients
                TextField(
                  controller: _excludedController,
                  decoration: InputDecoration(
                    labelText: "Excluded Ingredients / Allergies",
                    hintText: "e.g. peanuts, brinjal, mushrooms",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Preferences",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                const Text(
                  "Storage & App Info",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appGreen,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        title: const Text("Clear Search Cache"),
                        subtitle: const Text(
                          "Clears temporary meal recommendations",
                        ),
                        onTap: _clearCache,
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.info_outline, color: appGreen),
                        title: Text("App Version"),
                        subtitle: Text("1.0.0 (SWAADIFY Beta)"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
