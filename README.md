# My Restaurant

A multi-tenant SaaS restaurant management system built with Flutter and Supabase.

## Features

- Multi-tenant SaaS with isolated data per restaurant
- Role-based access (Waiter, Kitchen, Admin) with PIN login
- Real-time order tracking via Supabase Realtime
- Menu management with image upload and categories
- Order workflow: pending, preparing, served
- Configurable table management
- Daily reports and revenue stats
- Responsive design (phone, tablet, desktop)
- 3 languages: Kurdish, Arabic, English
- Offline fallback with local SQLite

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter, BLoC, GoRouter |
| Backend | Supabase (Auth, Postgres, Storage, Realtime) |
| Local DB | Drift (SQLite) |
| Auth | Email/password + role-based PIN system |

## Getting Started

1. Clone the repo
2. Create a `.env` file with your Supabase credentials:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-key
```

3. Run `flutter pub get`
4. Run `flutter run`

## Building

```
flutter build apk --release
flutter build ios --release
flutter build web --release
flutter build windows --release
```

## License

MIT
