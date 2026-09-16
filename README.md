<div align="center">

# My Restaurant

A production-grade, multi-tenant restaurant management system built with Flutter.

Real-time orders · Role-based access · Offline-first · Bluetooth/USB printing

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.16-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-22b8cf.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-343a40.svg)](#contributing)

<br/>

<img src="assets/icons/my%20Restaurant.png" width="96" alt="App Logo"/>

</div>

---

## Contents

- [Highlights](#highlights)
- [Feature Modules](#feature-modules)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
- [Project Layout](#project-layout)
- [Contributing](#contributing)
- [License](#license)

---

## Highlights

- **Multi-tenant SaaS** — per-restaurant data isolation enforced by row-level security
- **Real-time** — live order updates via Supabase Realtime with auto-reconnect and polling fallback
- **Offline-first** — local SQLite (Drift) when the network drops, with a connectivity banner
- **Role-based access** — Waiter, Kitchen, Admin; each role signs in with its own per-account PIN, auto-provisioned on first login. Roles are stored **per device**, so multiple devices on the same account can run different roles at the same time (each install sends its own `x-device-id` header)
- **Responsive** — phone (liquid glass nav), tablet, and desktop (navigation rail) layouts
- **Multi-language** — English, Kurdish (Sorani), Arabic with full RTL support
- **Printing ready** — Bluetooth & USB receipt and kitchen tickets (ESC/POS)

---

## Feature Modules

13 isolated modules, each owning its own `data`, `domain`, and `presentation` layers.

### Order Management

- Live order flow: Pending → Preparing → Served → Cancelled
- Cancel with confirmation, tracking codes with urgency timers
- Add items to existing orders, "order again" to restore a past order to cart
- Order timeline with status history; scrollable 2-column history grid (number, table, status, total)

### Kitchen & Tables

- Kitchen board with Active / Served / To-clean tabs (cancelled orders excluded from revenue & stats)
- Configurable table count, names, and reservation states with a cleanup workflow

### Printing

- Receipt and kitchen tickets over **Bluetooth** or **USB** (ESC/POS)
- Dedicated settings screen with connection tests
- Unified API over `flutter_blue_plus` and `unified_esc_pos_printer` (vendored USB driver)

### Menu & Cart

- Dishes with image upload, pricing, and descriptions
- Categories with emoji icons; availability toggle from management and menu screens
- Menu search, item notes, and a live-total cart with draft persistence across restarts

### Reports & Analytics

- Daily revenue, order/item counts
- Weekly bar charts (fl_chart), most-ordered dishes ranking
- Order history with calendar view and daily stats

### Auth & Onboarding

- Google Sign-In for account creation; promo code activation with admin management
- Role PIN login (Waiter / Kitchen / Admin), PINs persisted per account
- Guided onboarding: welcome → language/theme → menu → kitchen → reports → management & roles

### Infrastructure

- Push notifications via Firebase Cloud Messaging (edge function) + local notifications
- Drift offline fallback with connectivity detection banner
- Crash-safe global error handlers

---

## Architecture

Feature-first Clean Architecture: each feature is a self-contained module with its layers kept together, and the app composition root wires everything up.

```
lib/
├── app/                      # Composition root
│   ├── domain/               #   DataRepository interface
│   └── data/                 #   Supabase & app repository implementations
│       └── datasources/local/  # Drift database (schema, queries, seed)
├── core/                     # Cross-cutting, feature-agnostic
│   ├── config/               #   Supabase credentials
│   ├── constants/
│   ├── helpers/              #   Responsive, network, error helpers
│   ├── l10n/                 #   Tr.get() — en, ku, ar (full RTL)
│   ├── router/               #   go_router — stateful shell + role redirects
│   └── theme/                #   AppColors, AppRadius, AppTheme (light/dark)
├── features/                 # 13 feature modules
│   ├── admin/                #   ─┐
│   ├── auth/                 #    │ each feature has its own
│   ├── cart/                 #    │
│   ├── menu/                 #    │   data/        repositories, services, storage
│   ├── onboarding/           #    │   domain/      entities, repository interfaces
│   ├── orders/               #    │   presentation/ cubits, pages, widgets
│   ├── permissions/          #    │
│   ├── printer/              #    │
│   ├── profile/              #    │
│   ├── reports/              #    │
│   ├── settings/             #    │
│   ├── setup/                #    │
│   └── shell/                #   ─┘   layout, liquid glass nav, side rail
├── shared/                   # Genuinely shared widgets (shimmer kit, pressable scale, …)
├── firebase_options.dart
└── main.dart
```

**Pattern:** `domain` defines interfaces and entities, `data` implements them with Supabase/Drift/SharedPreferences, `presentation` consumes them via BLoC cubits. Feature modules never import each other — shared contracts live in `core/` and `shared/`.

`third_party/usb_serial/` — locally vendored USB serial driver (linked via `dependency_overrides`).

---

## Tech Stack

| Layer                | Technology                                                         | Version |
| -------------------- | ------------------------------------------------------------------ | ------- |
| Framework            | Flutter                                                            | 3.47    |
| Language             | Dart                                                               | 3.12+   |
| State Management     | flutter_bloc                                                       | 9.1     |
| Routing              | go_router                                                          | 17.3    |
| Backend              | Supabase (Auth, Postgres, Storage, Realtime, Edge Functions)       | 2.16    |
| Local Database       | Drift (SQLite)                                                     | 2.24    |
| Local Storage        | shared_preferences                                                 | 2.5     |
| Notifications        | flutter_local_notifications, firebase_messaging                    | 18.0 / 15.2 |
| Charts               | fl_chart                                                           | 1.2     |
| Images               | image_picker, image_cropper, file_picker, flutter_image_compress  | 1.1 / 12.2 / 8.1 / 2.4 |
| Auth                 | google_sign_in + Supabase Auth                                     | 7.1     |
| Connectivity         | connectivity_plus                                                  | 7.3     |
| Caching              | cached_network_image                                                | 3.4     |
| Printing             | unified_esc_pos_printer, flutter_blue_plus, usb_serial (vendored)  | 3.4 / 2.3 / local |
| Permissions          | permission_handler                                                  | 12.0    |
| UI Extras            | glass_liquid_navbar, shimmer                                       | 0.2 / 3.0 |
| i18n                 | Custom `Tr.get()` — en, ku, ar with full RTL                       | —       |

---

## Quick Start

### Prerequisites

- [Flutter 3.47+](https://docs.flutter.dev/get-started/install)
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

Or paste the SQL from `supabase/*.sql` into the [SQL Editor](https://supabase.com/dashboard/project/_/sql/new) in order:

1. `migration.sql` — core schema (profiles, categories, dishes, tables, orders, RLS)
2. `device_roles.sql` — per-device roles (`device_sessions` + device-aware `current_role()`/`set_role()`)
3. `security_hardening.sql` — hardening views, policies, security definer functions
4. `security_hardening_v2.sql` — lock admin stock tables behind `is_admin()`, gate stock RPCs, metadata-based admin detection, profiles.email sync
5. `admin_app.sql` — admin dashboard functions (role, stats, multi-restaurant reports)
6. `device_tokens.sql` — push-notification device tokens
7. `storage_recipe_images.sql` — recipe image storage bucket + policies
8. `upsert_passcodes.sql` — per-account PIN auto-save (UPSERT)

### Push Notifications

1. Add `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
2. Ensure `lib/firebase_options.dart` matches your Firebase project
3. Deploy the edge function:

```bash
supabase functions deploy notify-manager
```

---

## Building

```bash
# Android (APK / App Bundle)
flutter build apk --release
flutter build appbundle --release

# iOS / Web / Windows
flutter build ios --release
flutter build web --release
flutter build windows --release
```

> **Release signing:** Android builds are signed with `android/app/upload-keystore.jks` via `android/key.properties` (both gitignored). Application id: `com.apollo.my_restaurant`.

---

## Environment Variables

| Key                 | Required | Description                                |
| ------------------- | -------- | ------------------------------------------ |
| `SUPABASE_URL`      | Yes      | Your Supabase project URL                  |
| `SUPABASE_ANON_KEY` | Yes      | Your Supabase publishable API key          |
| `WEB_CLIENT_ID`     | Optional | OAuth 2.0 Web Client ID (Google Sign-In)   |

Loaded at startup via `flutter_dotenv` (`.env` is gitignored).

---

## Project Layout

| Path             | Purpose                                  |
| ---------------- | ---------------------------------------- |
| `lib/app/`       | Composition root + Drift database        |
| `lib/core/`      | Config, helpers, l10n, router, theme     |
| `lib/features/`  | 13 feature modules (data/domain/presentation) |
| `lib/shared/`    | Shared widgets and shimmer kit           |
| `supabase/`      | SQL migrations and edge functions        |
| `third_party/`   | Vendored USB serial driver (printer)     |
| `assets/`        | Fonts, app icons, category icons, images |
| `.env`           | Environment variables (not committed)    |

---

## Contributing

Contributions are welcome:

1. **Fork** the repository
2. **Create** a feature branch — `git checkout -b feature/amazing-feature`
3. **Commit** your changes — `git commit -m 'feat: add amazing feature'`
4. **Push** to the branch — `git push origin feature/amazing-feature`
5. **Open** a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/).

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file.

---

<div align="center">

**Built with care for restaurant owners everywhere.**

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.16-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)

</div>