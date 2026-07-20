<div align="center">

# My Restaurant

**A modern, multi-tenant SaaS restaurant management system**

Built with **Flutter** & **Supabase** — real-time orders, role-based access, and full offline support.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase--green?logo=supabase)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## Features

| Feature                | Description                                                |
| ---------------------- | ---------------------------------------------------------- |
| **Multi-Tenant SaaS**  | Fully isolated data per restaurant with row-level security |
| **Role-Based Access**  | Waiter, Kitchen, Admin — each with PIN-based login         |
| **Real-Time Orders**   | Live order updates via Supabase Realtime                   |
| **Menu Management**    | Image upload, categories, pricing, descriptions            |
| **Order Workflow**     | Pending → Preparing → Served, with tracking codes          |
| **Table Management**   | Configurable tables with reservation and cleaning states   |
| **Daily Reports**      | Revenue, item counts, most-ordered dishes                  |
| **Promo Codes**        | Activation system for new restaurant onboarding            |
| **Multi-Language**     | Kurdish (Sorani), Arabic, English — full RTL support       |
| **Responsive**         | Phone, tablet, and desktop layouts                         |
| **Offline Fallback**   | Local SQLite via Drift when network is unavailable         |
| **Push Notifications** | Role-based Firebase Cloud Messaging alerts                 |

## Architecture

```
lib/
├── core/           # Config, theme, router, notifications, i18n
├── data/           # Supabase repositories, local DB, services
├── domain/         # Entities, repository interfaces
└── presentation/   # Pages, widgets, cubits (BLoC)
```

## Tech Stack

| Layer            | Technology                                   |
| ---------------- | -------------------------------------------- |
| UI Framework     | Flutter 3.12+                                |
| State Management | flutter_bloc                                 |
| Routing          | go_router                                    |
| Backend          | Supabase (Auth, Postgres, Storage, Realtime) |
| Local Database   | Drift (SQLite)                               |
| Notifications    | flutter_local_notifications + Firebase       |
| Image Handling   | image_picker + flutter_image_compress        |
| i18n             | Custom `Tr.get()` with 3 locales             |

## Getting Started

### Prerequisites

- Flutter 3.12+
- A [Supabase](https://supabase.com) project
- (Optional) Firebase project for push notifications

### Setup

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

### Database

Apply the migration to your Supabase project:

```bash
supabase db push
```

Or paste `supabase/migration.sql` into the Supabase SQL Editor.

## Building

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

## Environment Variables

| Key                 | Required           | Description                               |
| ------------------- | ------------------ | ----------------------------------------- |
| `SUPABASE_URL`      | Yes                | Your Supabase project URL                 |
| `SUPABASE_ANON_KEY` | Yes                | Your Supabase publishable API key         |
| `WEB_CLIENT_ID`     | For Google Sign-In | OAuth 2.0 Web Client ID from Google Cloud |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with care for restaurant owners everywhere**

</div>
