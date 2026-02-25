# 🔥 HW_32 — Firebase Auth Flutter App

A Flutter application built as part of a mobile development course, implementing full Firebase Authentication flow with BLoC state management and Clean Architecture.

---

## 📱 Features

- ✅ Email/Password Registration & Login
- ✅ Google Sign-In
- ✅ Auto screen switching via `authStateChanges()`
- ✅ Route protection (unauthorized → Login screen)
- ✅ Forgot Password (email reset link)
- ✅ Error handling (wrong password, user not found, etc.)
- ✅ Loading indicators on all auth screens
- ✅ User profile display (displayName, photoURL) on Home screen
- ✅ Sign Out

---

## 🏗️ Architecture

```
lib/
├── main.dart
├── firebase_options.dart
│
├── core/
│   └── router/
│       └── app_router.dart         # GoRouter + route protection
│
├── data/
│   └── repositories/
│       └── auth_repository.dart    # All Firebase Auth logic
│
├── bloc/
│   └── auth/
│       ├── auth_bloc.dart
│       ├── auth_event.dart
│       └── auth_state.dart
│
└── presentation/
    └── screens/
        ├── login_screen.dart
        ├── register_screen.dart
        ├── forgot_password_screen.dart
        └── home_screen.dart
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `google_sign_in` | Google Sign-In |
| `flutter_bloc` | State management |
| `bloc` | BLoC core |
| `go_router` | Navigation + route guards |
| `equatable` | State/event comparison |

---

## 🚀 Getting Started

### 1. Clone the repo
```bash
git clone <your-repo-url>
cd firebase_32
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Setup Firebase
```bash
# Install Firebase CLI (once)
npm install -g firebase-tools

# Install FlutterFire CLI (once)
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for this project
flutterfire configure
```

### 4. Enable Auth in Firebase Console
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Select your project → **Authentication** → **Get started**
3. Enable **Email/Password**
4. Enable **Google** (for Google Sign-In)

### 5. Run the app
```bash
flutter run
```

---

## 🔐 Auth Flow

```
App Start
   │
   ▼
authStateChanges() listener (BLoC)
   │
   ├── User logged in  ──► Home Screen
   │
   └── No user  ──► Login Screen
                         │
                ┌────────┼────────┐
                ▼        ▼        ▼
           Register   Google   Forgot
                              Password
```

---

## 🛠️ Tech Stack

- **Flutter** — UI framework
- **Dart** — Language
- **Firebase Auth** — Authentication backend
- **BLoC** — State management pattern
- **GoRouter** — Declarative navigation
- **Clean Architecture** — Project structure

---

## 👨‍💻 Author

Built as HW_32 for DataGroup Flutter Course.# auth_firebase_32
