<div align="center">

# 🍽️ My Restaurant

**A production-grade, multi-tenant SaaS restaurant management system**

Real-time orders · Role-based access · Offline-first · Fully responsive

[![Flutter](https://img.shields.io/badge/Flutter-3.29-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.x-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

<br/>

<img src="assets/icons/my%20Restaurant.png" width="96" alt="App Logo"/>

</div>

---

## ✨ Highlights

- **Multi-Tenant SaaS** — Fully isolated data per restaurant with row-level security
- **Real-Time** — Live order updates via Supabase Realtime with auto-reconnect and polling fallback
- **Offline-First** — Local SQLite (Drift) when the network is unavailable, with connectivity banner
- **Role-Based Access** — Waiter, Kitchen, Admin — each with its own PIN login and PIN change screens
- **Responsive** — Phone (liquid glass nav), tablet, and desktop (navigation rail) layouts
- **Multi-Language** — Kurdish (Sorani), Arabic, English — full RTL support

---

## 🚀 Features

<details>
<summary><strong>Order Management</strong></summary>

- Real-time order flow: Pending → Preparing → Served
- Tracking codes with urgency timers
- Add items to existing orders from the detail screen
- "Order again" to restore past orders to cart
- Order timeline with status history

</details>

<details>
<summary><strong>Kitchen & Table Operations</strong></summary>

- Kitchen board with Active / Served / To-clean tabs
- Table management with configurable count, names, and reservation states
- Table cleanup workflow with status tracking

</details>

<details>
<summary><strong>Menu & Inventory</strong></summary>

- Dish management with image upload, pricing, and descriptions
- Categories with custom icons
- Toggle dish availability from a dedicated screen
- Search across the menu

</details>

<details>
<summary><strong>Reports & Analytics</strong></summary>

- Daily revenue, order/item counts
- Weekly bar charts (fl_chart)
- Most-ordered dishes ranking
- Order history with calendar view and daily stats

</details>

<details>
<summary><strong>Authentication & Onboarding</strong></summary>

- Google Sign-In for restaurant account creation
- Promo code activation system with admin management
- Role-based PIN login (Waiter / Kitchen / Admin)
- Guided onboarding: Welcome → language/theme → account → restaurant setup

</details>

<details>
<summary><strong>Infrastructure</strong></summary>

- Push notifications via Firebase Cloud Messaging (edge function)
- Local notifications for order alerts
- Offline fallback with Drift (SQLite)
- Connectivity detection with visual banner

</details>

---

## 🏗️ Architecture

```
lib/
├── core/               # Config, theme, router, notifications, i18n
│   ├── config/
│   ├── constants/
│   ├── helpers/        # Responsive helpers (R.fontSm, R.padding, etc.)
│   ├── l10n/           # Custom Tr.get() — 3 locales
│   ├── notifications/
│   ├── router/         # go_router — stateful shell + role redirects
│   └── theme/          # AppColors, AppRadius, AppTheme (light/dark)
├── data/               # Supabase repos, local DB, services
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/             # Entities, repository interfaces
│   ├── entities/
│   └── repositories/
├── presentation/       # Pages, widgets, cubits (BLoC)
│   ├── cubits/
│   ├── pages/
│   └── widgets/
├── shared/             # Reusable UI components (nav bar, dialogs, etc.)
├── firebase_options.dart
└── main.dart
```

**Pattern:** Clean Architecture — `domain` defines interfaces, `data` implements them with Supabase/Drift, `presentation` consumes via BLoC cubits.

---

## 🛠️ Tech Stack

| Layer                | Technology                                                       | Version                 |
| -------------------- | ---------------------------------------------------------------- | ----------------------- |
| **Framework**        | Flutter                                                          | 3.29                    |
| **Language**         | Dart                                                             | 3.12                    |
| **State Management** | flutter_bloc                                                     | 9.1                     |
| **Routing**          | go_router                                                        | 17.3                    |
| **Backend**          | Supabase (Auth, Postgres, Storage, Realtime, Edge Functions)     | 2.16                    |
| **Local Database**   | Drift (SQLite)                                                   | 2.24                    |
| **Local Storage**    | shared_preferences                                               | 2.5                     |
| **Notifications**    | flutter_local_notifications + Firebase Messaging                 | 18.0 / 15.2             |
| **Charts**           | fl_chart                                                         | 1.2                     |
| **Images**           | image_picker, image_cropper, file_picker, flutter_image_compress | —                       |
| **Auth**             | google_sign_in + Supabase Auth                                   | 7.1                     |
| **Connectivity**     | connectivity_plus                                                | 7.3                     |
| **Caching**          | cached_network_image                                             | 3.4                     |
| **i18n**             | Custom `Tr.get()`                                                | 3 locales (ckb, ar, en) |

---

## ⚡ Quick Start

### Prerequisites

- [Flutter 3.29+](https://docs.flutter.dev/get-started/install)
- A [Supabase](https://supabase.com) project
- (Optional) A [Firebase](https://firebase.google.com) project for push notifications

### Clone & Run

```bash
git clone https://github.com/apollocked/my_resturant.git
cd my_resturant
```

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
WEB_CLIENT_ID=your-google-oauth-web-client-id
```

Then:

```bash
flutter pub get
flutter run
```

### Database Setup

Apply migrations to your Supabase project:

```bash
supabase db push
```

Or paste the contents of `supabase/migration.sql` into the [Supabase SQL Editor](https://supabase.com/dashboard/project/_/sql/new).

### Push Notifications

1. Add `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) for Firebase
2. Deploy the edge function:

```bash
supabase functions deploy notify-manager
```

---

## 🔨 Building

```bash
# Android (APK)
flutter build apk --release

# Android (App Bundle)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## 🔐 Environment Variables

| Key                 | Required | Description                                  |
| ------------------- | -------- | -------------------------------------------- |
| `SUPABASE_URL`      | ✅       | Your Supabase project URL                    |
| `SUPABASE_ANON_KEY` | ✅       | Your Supabase publishable API key            |
| `WEB_CLIENT_ID`     | 🔑       | OAuth 2.0 Web Client ID (for Google Sign-In) |

---

## 📂 Key Directories

| Path             | Purpose                               |
| ---------------- | ------------------------------------- |
| `supabase/`      | SQL migrations and edge functions     |
| `assets/icons/`  | App icons and category icons          |
| `assets/images/` | Onboarding and placeholder images     |
| `assets/fonts/`  | NRT font family                       |
| `.env`           | Environment variables (not committed) |

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. **Fork** the repository
2. **Create** a feature branch — `git checkout -b feature/amazing-feature`
3. **Commit** your changes — `git commit -m 'feat: add amazing feature'`
4. **Push** to the branch — `git push origin feature/amazing-feature`
5. **Open** a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with care for restaurant owners everywhere**

[![Flutter](https://img.shields.io/badge/Flutter-3.29-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.x-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)

</div>
