# 🍲 SWAADIFY: Zero-Waste AI Culinary Assistant

**SWAADIFY** is a cross-platform mobile application developed as an MSc Computer Science final project at the University of Greenwich. It leverages generative AI to transform available pantry ingredients and kitchen leftovers into delicious, zero-waste vegetarian recipes while enforcing rigorous micro-dietary constraints (such as pure vegetarian and strict Jain requirements).

---

## ✨ Key Features

* **AI-Driven Recipe Generation:** Powered by the **Gemini 2.5 Flash API**, generating structured, deterministic JSON recipe arrays from arbitrary pantry items and leftover staples.
* **Strict Dietary Enforcement:** Features client-side keyword sanitization and defensive regex validation to instantly intercept and reject unauthorized non-vegetarian inputs.
* **Jain Dietary Constraints:** Strict negative constraint handling to suppress root vegetables (potatoes, onions, garlic, etc.) for authentic Jain culinary alignment.
* **Temporal Context Detection:** Automatically detects the time of day using the device hardware clock/OS to suggest appropriate meal types (Breakfast, Lunch, Snack, Dinner).
* **Interactive Flame Timers:** Parses bracketed step instructions to render visual time and flame intensity badges.
* **Offline Preferences Storage:** Persists default spice levels, dietary choices, and allergen exclusions locally using `SharedPreferences`.

---

## 📱 Tech Stack & Architecture

* **Frontend Framework:** Flutter & Dart (Cross-platform mobile UI)
* **Generative AI Engine:** Google Gemini 2.5 Flash API (`google_generative_ai`)
* **Local Persistence:** `SharedPreferences` for key-value offline caching
* **Architecture Pattern:** Client-server interaction with modular subprocess decoupling (Temporal Context Detector, Dietary Sanitizer, AI Gateway, and JSON UI Renderer).

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (v3.0 or higher)
* Dart SDK
* Android Studio / Xcode (for emulator execution)
* A valid Gemini API Key from [Google AI Studio](https://aistudio.google.com/)

### Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/your-username/swaadify.git](https://github.com/your-username/swaadify.git)
   cd swaadify
