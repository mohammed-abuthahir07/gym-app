# Gym Management Mobile Application

A complete, professional, production-ready Gym Management mobile application built with **Flutter** and powered natively by **Firebase** (Firebase Authentication, Cloud Firestore, Firebase Storage, and Cloud Messaging).

---

## 1. Project Specifications

- **Application ID:** `com.zayith.gymmanagement`
- **Firebase Project ID:** `gym-management-app-9b49c`
- **Frontend Framework:** Flutter (Dart 3.x)
- **Backend Infrastructure:** Firebase (Authentication, Cloud Firestore, Storage, Messaging)
- **State Management:** Provider
- **Design System:** Dynamic Material 3 with customizable theme palettes, hex color picker, light/dark mode, and persistence via `shared_preferences`.

---

## 2. Admin Account Setup and Access

### Default Test & Administrative Credentials

Per the functional specification , the default accounts configured for development and testing are:

| Role | Email | Password | Access Level |
|---|---|---|---|
| **Administrator** | `admin@gmail.com` | `Admin@123` | Full Admin Portal & System Management |
| **Trainer** | `ahmed@gmail.com` | `Trainer@123` | Trainer Hub, Member Assignment & Workouts |
| **Member** | `mohammed@gmail.com` | `Member@123` | Member Portal, Diets, Progress & Schedules |
noor@gmail.com
noor123  

> **Security Note:** In production, remember to change these default passwords or reset credentials via the Firebase Authentication Console.

### Architecture of Role-Based Access Control (RBAC)
When an administrator logs in:
1. **Firebase Authentication** verifies the administrator's email and password.
2. The app's `AuthService` queries Cloud Firestore at `users/{uid}` using the authenticated user's unique `uid`.
3. If `role` is equal to `'ADMIN'` (case-insensitive: `'ADMIN'` or `'admin'`), the application routes the user immediately to `AdminDashboardScreen`.
4. The security rules in `firestore.rules` mirror this check server-side, ensuring only users with `get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'ADMIN'` can access administrative collections.

### How to Provision or Verify an Admin User

Follow these steps in the [Firebase Console](https://console.firebase.google.com/project/gym-management-app-9b49c):

1. **Create the Authentication Account:**
   - Navigate to **Build > Authentication > Users**.
   - Click **Add User**.
   - Enter the Admin email: `admin@gmail.com` (or your custom admin address).
   - Enter the password: `Admin@123` (or your secure password).
   - Click **Add User** and copy the generated **User UID** (e.g., `abc123XYZ...`).

2. **Create the Firestore User Profile Document:**
   - Navigate to **Build > Firestore Database > Data**.
   - Select or create the `users` collection.
   - Click **Add Document** and set the **Document ID** to the exact **User UID** copied from Step 1.
   - Add the following document fields:
     ```json
     {
       "id": "<User UID>",
       "name": "Super Admin",
       "email": "admin@gmail.com",
       "role": "ADMIN",
       "phone": "+1234567890",
       "status": "active",
       "createdAt": "2026-10-20T10:00:00Z"
     }
     ```
   - Click **Save**.

3. **Log In to the Mobile Application:**
   - Launch the application on an emulator or physical device.
   - On the Public Landing Page, tap **Member / Staff Login** (or the lock icon in the top bar).
   - Enter:
     - **Email:** `admin@gmail.com`
     - **Password:** `Admin@123`
   - The app validates credentials, reads the `role: "ADMIN"` document, and launches the full **Admin Portal**.

---

## 3. Core Features & Navigation

### A. First-Open Commercial Landing Page
- First-time visitors and logged-out users land on the rich **Public Landing Page**.
- Showcases the gym's brand identity, live metrics, facility photos (Weight Floor, Cardio Zone, Group Classes, Personal Training), membership plans, and ongoing challenges.
- Features an interactive **Public Enquiry / Contact Form** that saves submissions directly to Firestore (`contacts` collection) for staff follow-up.
- Quick navigation to Theme Appearance Settings and Login.

### B. Dynamic Theme Engine & Appearance Customization
- **Theme Modes:** Light, Dark, or System Adaptive.
- **5 Handcrafted Presets:**
  - Gym Red (Crimson & Coral)
  - Electric Blue (Cyan & Slate)
  - Emerald Power (Mint & Forest)
  - Gold Championship (Amber & Orange)
  - Clean Light (Minimalist White & Slate)
- **Custom Color Picker:** Users can customize primary, secondary, and accent colors with real-time hex input (`#RRGGBB`).
- **Persistence:** All selections are saved to local device storage using `SharedPreferences`.

### C. Role-Based Dashboards & Portals
- **Admin Portal:**
  - Member management (list, search, filter, approve, assign trainers, activate/deactivate).
  - Trainer management (view trainers, assign members, track workloads).
  - Membership plans & pricing tiers.
  - Financial fee management & payment reconciliation.
  - Push notifications broadcast center.
  - Website content management (classes, challenges, testimonials).
  - Real-time business analytics and charts (`fl_chart`).
- **Trainer Portal:**
  - Assigned member roster and quick profile inspection.
  - Workout plan builder (exercises, sets, reps, rest periods).
  - Diet plan creator (meals, macros, dietary restrictions).
  - Member progress logging (weight, body measurements).
  - Trainer class schedule & member attendance tracker.
  - Member-Trainer real-time direct messaging (`chats` collection).
- **Member Portal:**
  - Personalized workout and nutrition tracker.
  - Cheat meal logger with weekly allowance tracking.
  - Class schedule & one-tap reservation.
  - Exercise library with search, category filtering, and video links.
  - Challenge participation & leaderboard progress.
  - Fee dues, receipt downloads, and payment history.
  - Direct 1-on-1 chat with assigned trainer.

---

## 4. Local Firestore Rules & Indexes

The project includes production-ready security rules and index definitions:
- **`firestore.rules`:** Strict role-based security rules enforcing authenticated reads/writes based on user roles (`ADMIN`, `TRAINER`, `MEMBER`) and preventing unauthorized privilege escalation.
- **`firestore.indexes.json`:** Compound index definitions for optimized queries across `fees`, `notifications`, `workouts`, `progress`, and `classes`.

*Note: In accordance with project safety guidelines, live rules and indexes are not deployed automatically and must be deployed manually or with explicit approval via `firebase deploy --only firestore:rules,firestore:indexes`.*

---

## 5. Development & Testing Commands

### Prerequisites
- Flutter SDK 3.29.0 or higher
- Android SDK (API 34/35 compatible)
- Java 17 / OpenJDK

### Run Locally
```bash
# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run all test suites
flutter test

# Build Android Debug APK
flutter build apk --debug
```

APK output location:
`build/app/outputs/flutter-apk/app-debug.apk`
