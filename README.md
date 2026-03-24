# Vittalo — AI-Powered Resale Price Estimator

> **Sell smarter, not cheaper.**

Vittalo is a production-ready Flutter mobile app that estimates the fair resale price of used goods using on-device machine learning — no internet required. It combines a TFLite regression model with a BERT-Tiny NLP model to analyse both structured product data and the seller's own description, delivering a confident price range in seconds.

---

## Table of Contents

- [Features](#features)
- [Supported Categories](#supported-categories)
- [Architecture](#architecture)
- [ML Pipeline](#ml-pipeline)
- [Project Structure](#project-structure)
- [Screens & Flow](#screens--flow)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Generating ML Models](#generating-ml-models)
  - [Running the App](#running-the-app)
- [Debug Logging](#debug-logging)
- [Configuration](#configuration)
- [Platform Support](#platform-support)

---

## Features

- **100% Offline** — all inference runs on-device via TensorFlow Lite
- **AI Price Range** — min / max / suggested price with a confidence score
- **NLP Text Analysis** — BERT-Tiny reads your selling reason and condition description to detect urgency, condition sentiment, and confidence
- **Brand Premium** — Apple, Royal Enfield, Samsung Ultra etc. command appropriate premiums; budget brands are discounted accordingly
- **Category-Specific Inputs** — storage & battery health for mobiles; km driven, fuel type & documents for bikes; star rating & capacity for appliances
- **Isolate-Based Inference** — both models run in Dart isolates so the UI never freezes
- **Heuristic Fallback** — exponential depreciation + brand / condition multipliers kick in if the TFLite model fails to load
- **Estimation History** — last 20 results persisted locally via SharedPreferences
- **Dark Fintech UI** — Material 3 dark theme with custom purple / teal / gold palette

---

## Supported Categories

| Category | Key Extras |
|---|---|
| Mobile Phone | Storage, RAM, Color, Battery Health |
| Bike / Scooter | KM Driven, Fuel Type, Insurance, RC |
| Bicycle | KM Ridden, Gear Type |
| Home Appliance | Energy Star Rating (1–5), Capacity |

---

## Architecture

Vittalo follows **Clean Architecture** with a feature-first folder layout.

```
UI Layer  (Flutter Widgets)
      ↕  Riverpod StateNotifier
Logic Layer  (Providers + Repository Interface)
      ↕  Repository Implementation
Data Layer  (ML Service + NLP Service + Local Storage)
      ↕  TFLite Isolates + SharedPreferences
```

**Unidirectional data flow:**
1. User fills the 5-step input wizard
2. `EstimatorNotifier` calls `PriceEstimatorRepository.estimatePrice()`
3. Repository runs NLP analysis → regression inference → persists result
4. State updates to `EstimationSuccess` → UI navigates to Result screen

---

## ML Pipeline

### Step 1 — NLP Analysis (`NlpService`)

| Property | Value |
|---|---|
| Model file | `bert_tiny.tflite` (~1.1 MB, float32) |
| Vocabulary | `bert_vocab.json` (29 char-level tokens) |
| Input shape | `[1, 64]` int32 — char token IDs with `[CLS]` / `[SEP]` / `[PAD]` |
| Output shape | `[1, 3]` float32 — `[urgency_score, condition_score, confidence]` |

The combined seller text (`reason for selling` + `condition description`) is tokenised at character level and fed through the model. All three output scores feed directly into Step 2 as features.

### Step 2 — Price Regression (`MlService`)

| Property | Value |
|---|---|
| Model file | `regression_model.tflite` (~15 KB, float32) |
| Input shape | `[1, 9]` float32 feature vector |
| Output shape | `[1, 1]` float32 — predicted price ratio (0–1) |

**Feature vector:**

| # | Feature | Normalisation |
|---|---|---|
| 0 | Original purchase price | ÷ 200,000 |
| 1 | Age in months | ÷ 120 |
| 2 | Condition percent | ÷ 100 |
| 3 | Physical damage flag | 0 or 1 |
| 4 | Functional issues flag | 0 or 1 |
| 5 | Accessories included flag | 0 or 1 |
| 6 | Category encoded (0–3) | ÷ 3 |
| 7 | NLP urgency score | 0–1 |
| 8 | NLP condition score | 0–1 |

The model outputs a ratio which is multiplied by the original price, then clamped to `[originalPrice × 0.85, originalPrice × 1.15]`.

### Heuristic Fallback

If either TFLite model fails to load, a rule-based engine takes over:

- **Depreciation** — exponential decay per category (Mobile 4%/mo → Appliance 1.2%/mo)
- **Brand premium** — Apple +22%, Royal Enfield +18%, KTM +15%, budget Android −6%
- **Condition multiplier** — blends condition % and NLP condition score
- **Extras multiplier** — storage tier, battery health %, km driven, star rating
- **Market anchoring** — optional current market price shifts the estimate
- **Penalty/bonus** — physical damage −12%, functional issues −18%, accessories +4%

---

## Project Structure

```
vittalo/
├── assets/
│   ├── images/
│   │   └── vittalo_logo.png
│   └── models/
│       ├── regression_model.tflite    # Price regression (9-input → 1-output)
│       ├── bert_tiny.tflite           # BERT-Tiny NLP model (char-level)
│       └── bert_vocab.json            # 29-token char vocabulary
│
├── lib/
│   ├── main.dart                      # Entry point — ProviderScope + portrait lock
│   │
│   ├── core/
│   │   ├── constants/app_constants.dart   # Paths, multipliers, durations, enums
│   │   ├── router/app_router.dart         # GoRouter — 5 named routes
│   │   └── theme/app_theme.dart           # VittaloColors, gradients, ThemeData
│   │
│   ├── services/
│   │   ├── ml_service.dart            # Regression inference in Isolate.run()
│   │   └── nlp_service.dart           # BERT-Tiny inference in Isolate.run()
│   │
│   └── features/
│       ├── splash/
│       ├── category_selection/
│       ├── image_upload/
│       └── price_estimator/
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── product_input.dart       # All user inputs
│           │   │   ├── category_extras.dart     # Category-specific fields
│           │   │   ├── price_result.dart        # Final price + insights
│           │   │   └── nlp_scores.dart          # NLP output scores
│           │   └── repositories/
│           │       └── price_estimator_repository.dart
│           ├── data/
│           │   ├── repositories/
│           │   │   └── price_estimator_repository_impl.dart
│           │   └── local/
│           │       └── estimator_storage.dart   # SharedPreferences persistence
│           └── presentation/
│               ├── providers/
│               │   └── estimator_provider.dart  # Riverpod StateNotifier
│               ├── screens/
│               │   ├── input_wizard_screen.dart # 5-step form
│               │   └── result_screen.dart       # Price display
│               └── widgets/
│                   ├── condition_slider_widget.dart
│                   ├── price_range_card.dart
│                   ├── toggle_option_widget.dart
│                   └── wizard_progress_indicator.dart
│
├── ios/
│   └── Podfile                        # platform :ios, '14.0'
│
└── android/
    └── app/build.gradle.kts           # minSdk 21, compileSdk 34, Java 17
```

---

## Screens & Flow

```
Splash Screen
    Loads ML + NLP models concurrently (Future.wait)
    Navigates to Category Selection after 2.8 s
         │
         ▼
Category Selection
    2×2 animated grid — Mobile / Bike / Cycle / Appliance
         │
         ▼
Image Upload  (optional)
    Camera or gallery — skippable
         │
         ▼
Input Wizard  (5 steps)
    Step 1 — Product Details     (price, date, brand, model)
    Step 2 — Category Extras     (storage / km / stars etc.)
    Step 3 — Condition           (slider, damage flags)
    Step 4 — Market Reference    (optional current price)
    Step 5 — Tell the AI         (reason for selling, description)
         │
         ▼
Result Screen
    Suggested price  (gold gradient hero card)
    Price range bar
    Confidence score
    AI insights list
    NLP urgency & condition chips
```

---

## Tech Stack

| Layer | Library | Version |
|---|---|---|
| UI framework | Flutter | 3.x |
| State management | flutter_riverpod | ^2.5.1 |
| Navigation | go_router | ^13.2.0 |
| ML inference | tflite_flutter | ^0.12.1 |
| Animations | flutter_animate | ^4.5.0 |
| Typography | google_fonts (Inter) | ^6.2.1 |
| Local storage | shared_preferences | ^2.3.2 |
| Image picker | image_picker | ^1.1.2 |
| Date formatting | intl | ^0.19.0 |

---

## Getting Started

### Prerequisites

- Flutter SDK **3.22+**
- Dart SDK **3.5+**
- Xcode **15+** (iOS builds)
- Android Studio with Android SDK **34** (Android builds)
- Python **3.10+** with TensorFlow **2.12–2.16** (model generation only)

### Setup

```bash
# Clone the repository
git clone https://github.com/your-username/vittalo.git
cd vittalo

# Install Flutter dependencies
flutter pub get

# iOS — install CocoaPods
cd ios && pod install && cd ..
```

### Generating ML Models

The TFLite model files are **not** committed to the repository. Generate them once with the Python training scripts:

```bash
# Install Python dependencies
pip install tensorflow numpy scikit-learn

# Generate regression model  →  assets/models/regression_model.tflite
python scripts/train_regression.py

# Generate NLP model + vocab  →  assets/models/bert_tiny.tflite
#                              →  assets/models/bert_vocab.json
python scripts/train_nlp.py
```

> **Important:** Do **not** set `converter.optimizations = [Optimize.DEFAULT]` in the conversion scripts. DEFAULT quantization produces FULLY_CONNECTED op version 12 which is unsupported by the bundled TFLiteC 2.12.0. Always convert as float32 (no quantization).

### Running the App

```bash
# Debug — iOS Simulator
flutter run -d ios

# Debug — Android Emulator / Device
flutter run -d android

# List available devices
flutter devices

# Release build
flutter build ios --release
flutter build apk --release
```

---

## Debug Logging

All ML and NLP activity is logged with `debugPrint` (visible in the Flutter debug console, silent in release builds). Filter by tag to trace exactly what's happening:

| Tag | What it shows |
|---|---|
| `[Repository]` | Orchestration — service load status, step timing |
| `[NlpService]` | Model load result, input text, final NLP scores |
| `[NlpIsolate]` | TFLite vs heuristic path, raw model output, token IDs |
| `[MlService]` | Feature vector sent to model, final price range |
| `[MlIsolate]` | TFLite vs heuristic path, raw ratio, all multipliers |

**Example — successful TFLite run:**

```
[Repository] ── estimatePrice START ──────────────────────
[Repository] nlpService.isModelLoaded  = true
[Repository] mlService.isModelLoaded   = true
[NlpIsolate] model bytes present (1107.8 KB) — attempting TFLite inference
[NlpIsolate] Interpreter.fromBuffer() succeeded
[NlpIsolate] raw TFLite output → [0.38, 0.74, 0.81]
[NlpIsolate] TFLite inference complete ✓
[MlIsolate] TFLite feature vector: [0.425, 0.1, 0.7, 0.0, 0.0, 1.0, 0.0, 0.38, 0.74]
[MlIsolate] TFLite raw output ratio=0.52  clamped=0.52
[MlIsolate] TFLite inference complete ✓  basePrice=₹44200.0
[Repository] ── estimatePrice END ────────────────────────
```

**If you see `*** HEURISTIC ... ACTIVE ***`** the model didn't load. Check:
1. `assets/models/` files are present and declared in `pubspec.yaml` under `flutter: assets:`
2. Run `flutter pub get` after adding any new assets
3. Regenerate models without quantization (see [Generating ML Models](#generating-ml-models))

---

## Configuration

Key values in `lib/core/constants/app_constants.dart`:

```dart
// Price band around the suggested price
static const double minPriceMultiplier = 0.85;   // suggested × 0.85 = lower bound
static const double maxPriceMultiplier = 1.15;   // suggested × 1.15 = upper bound

// Asset paths
static const String regressionModelPath = 'assets/models/regression_model.tflite';
static const String bertTinyModelPath   = 'assets/models/bert_tiny.tflite';
```

---

## Design System

| Token | Value | Usage |
|---|---|---|
| `background` | `#0A0B14` | App background |
| `surface` | `#13141F` | Cards |
| `primary` | `#7C5CFC` | Buttons, accents |
| `secondary` | `#00D4A0` | Success, CTA |
| `gold` | `#F5C842` | Suggested price hero |
| `error` | `#FF5757` | Damage / issues |
| `warning` | `#FFB74D` | Moderate states |

Font: **Inter** via Google Fonts. Material 3 dark theme only.

---

## Platform Support

| Platform | Min Version | Status |
|---|---|---|
| iOS | 14.0 | Supported |
| Android | API 21 (Android 5.0) | Supported |
| Web | — | Not supported (TFLite) |
| Desktop | — | Not supported |

---

## License

MIT — see [LICENSE](LICENSE) for details.
