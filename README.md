# reru-android

RERU Android client — Flutter app for household waste collection management.

Part of the [RERU platform](https://github.com/oquidave/reru). The REST API lives in that repo; this app is purely a client that calls it.

**API reference:** [reru/docs/api.md](https://github.com/oquidave/reru/blob/main/docs/api.md)  
**Design system:** [reru/docs/design-system](https://github.com/oquidave/reru/blob/main/docs/design-system/)

---

## What it does

- **Login** with email and password (Bearer token auth)
- **Dashboard** — account status, next collection date, pending invoices
- **Collections** — full history with status filter (scheduled / completed / missed)
- **Invoices** — list and detail view with payment instructions

---

## Prerequisites

- [Flutter 3.41+](https://docs.flutter.dev/get-started/install)
- Android Studio (for emulator) or a physical Android device
- Access to the RERU API at `https://reru.odukar.com`

---

## Setup

### 1. Install Flutter

```bash
# Linux (download SDK)
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.41.7-stable.tar.xz
tar xf flutter_linux_3.41.7-stable.tar.xz
export PATH="$PATH:$HOME/development/flutter/bin"

# macOS (Homebrew)
brew install --cask flutter

# Verify
flutter doctor
```

### 2. Clone and bootstrap

```bash
git clone https://github.com/oquidave/reru-android
cd reru-android

# Generate the native Android (and iOS) directories.
# This is safe on an existing repo — it will NOT overwrite lib/ files.
flutter create . --project-name reru --org com.odukar

# Install Dart dependencies
flutter pub get
```

### 3. Run

```bash
# List connected devices / emulators
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Run on the first available device
flutter run
```

---

## Project structure

```
lib/
├── main.dart               ← App entry point (ProviderScope + MaterialApp.router)
├── theme/
│   ├── app_colors.dart     ← Color tokens (from reru design system)
│   ├── app_text_styles.dart← Typography (Outfit font)
│   └── app_theme.dart      ← MaterialTheme wired to color/type tokens
├── models/
│   ├── client.dart         ← Client domain model
│   ├── collection.dart     ← Collection domain model
│   ├── invoice.dart        ← Invoice domain model
│   └── dashboard_data.dart ← Aggregated dashboard response
├── services/
│   ├── api_client.dart     ← HTTP client (Bearer token, standard response unwrapping)
│   ├── auth_service.dart   ← Login, logout, token refresh, secure storage
│   └── user_service.dart   ← Dashboard, collections, invoices API calls
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── collections_screen.dart
│   ├── invoices_screen.dart
│   └── invoice_detail_screen.dart
├── widgets/
│   ├── status_badge.dart   ← Coloured status pill (paid, overdue, scheduled…)
│   └── reru_card.dart      ← Themed card container
└── utils/
    ├── providers.dart      ← Riverpod providers (auth token, data fetchers)
    ├── router.dart         ← GoRouter config + bottom nav shell
    └── formatters.dart     ← Currency, date, relative-date helpers
```

---

## Architecture

- **State management:** Riverpod (`FutureProvider` for async data, `StateProvider` for auth token)
- **Navigation:** GoRouter with a `ShellRoute` for the bottom nav tabs
- **Auth:** Bearer tokens stored in Android Keystore via `flutter_secure_storage`. Token refresh is handled automatically before each request when the stored token is within 60 seconds of expiry
- **API base URL:** `https://reru.odukar.com` (configured in `lib/services/api_client.dart`)

---

## Build (release APK)

```bash
# Generate a keystore (first time only)
keytool -genkey -v -keystore android/app/reru.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias reru

# Create android/key.properties
cat > android/key.properties <<EOF
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=reru
storeFile=reru.jks
EOF

# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

---

## Adding a new screen

1. Create `lib/screens/your_screen.dart`
2. Add a `FutureProvider` in `lib/utils/providers.dart` if new data is needed
3. Add a `GoRoute` in `lib/utils/router.dart`
4. Add a nav item to `_AppShell` in `router.dart` if it's a top-level screen
