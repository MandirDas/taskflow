# TaskFlow

A modern, polished project management mobile application built with Flutter. Users belong to organizations, create and manage projects, view and update tasks, assign work, and receive task-related notifications.

Built against **local mock JSON data** — the architecture is structured so the data layer can be swapped for real HTTP calls with minimal changes elsewhere in the app.

---

## Quick Start

```bash
# Prerequisites: Flutter 3.6+, Dart 3.6+

# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Build release APK
flutter build apk --release
```

---

## Test Credentials

| Email | Password | Org | Role |
|-------|----------|-----|------|
| `ava.admin@nimbusdigital.test` | `Password123!` | Nimbus Digital | org_admin |
| `marcus.member@nimbusdigital.test` | `Password123!` | Nimbus Digital | member |
| `daniel.admin@harborlightstudios.test` | `Password123!` | Harborlight Studios | org_admin |
| `elena.member@harborlightstudios.test` | `Password123!` | Harborlight Studios | member |

Use **admin** accounts to test delete/manage operations. **Member** accounts can view and edit but cannot delete projects.

---

## Architecture

### Clean Architecture (3-Layer)

```
┌──────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                       │
│  Screens · Widgets · Cubits (UI logic only)          │
└──────────────────────────┬───────────────────────────┘
                           │ depends on
┌──────────────────────────▼───────────────────────────┐
│               DOMAIN LAYER                            │
│  Entities · Repository Interfaces                     │
│  Pure Dart — no Flutter imports                       │
└──────────────────────────┬───────────────────────────┘
                           │ implements
┌──────────────────────────▼───────────────────────────┐
│                DATA LAYER                             │
│  Models (JSON) · DataSources · Repository Impls       │
└──────────────────────────────────────────────────────┘
```

**Dependency Rule:** Presentation → Domain ← Data. Domain never depends on outer layers.

### State Management: flutter_bloc (Cubit)

Every feature uses Cubit with consistent state patterns: `Initial → Loading → Success/Empty/Error`

### Dependency Injection: get_it

Service locator pattern. All repositories are registered as interfaces for easy swap.

### Navigation: go_router

Declarative routing with auth redirect guards, `StatefulShellRoute.indexedStack` for tab state retention, and deep-link support.

---

## Features

### Core
- Simulated JWT authentication with token refresh (15-min access / 7-day refresh)
- Secure token storage (FlutterSecureStorage)
- Project CRUD with org-scoped access and role-based authorization
- Task CRUD with status, priority, assignee, due dates, and comments
- Task filtering: status, priority, assignee, date range
- Task assignment with org membership validation in business logic
- Notifications inbox with mark-read and task navigation
- Dashboard with workspace progress, focus tasks, and recent projects
- Pull-to-refresh on all list screens
- Confirmation dialogs for destructive actions
- Form validation with meaningful error messages

### UI/UX
- Material 3 design with custom indigo→violet brand identity
- Full light and dark mode (persisted preference)
- Responsive layouts (phone + tablet with NavigationRail)
- Modern floating glassmorphic bottom navigation bar
- Animated bottom offline pill indicator (circle → expand → text → shrink → disappear)
- Skeleton shimmer loading states
- Motion system with reduced-motion support
- Semantic accessibility labels and screen-reader announcements

### Bonus Features
- **Biometric unlock** — Face ID / fingerprint via `local_auth` to unlock existing sessions
- **Session timeout** — Configurable inactivity timer (1/5/15/30 min) that locks the app
- **Offline-first queue** — Mutations queued when offline, auto-replayed on reconnect with retry logic
- **i18n** — English, Hindi (हिन्दी), and Spanish (Español) with `flutter_localizations` and ARB files
- **Request cancellation** — `CancellationToken` pattern cancels superseded in-flight requests
- **Accessibility** — Semantic headers, live region announcements, ExcludeSemantics on decorative elements

---

## Mock Data Layer

### How It Works

1. Single JSON asset (`assets/mock_data/`) is bundled with the app
2. `MockDataSource` reads and caches the JSON in memory on first access
3. Repository implementations call MockDataSource and convert models → entities
4. Mutations update in-memory state and cache to SharedPreferences
5. Artificial delay (300–800ms) on every data access simulates network latency

### Simulated Errors & Offline

| Trigger | How to Activate |
|---------|----------------|
| **Offline mode** | Settings → Developer & Demo → "Simulate Offline" toggle |
| **Force server errors** | Settings → Developer & Demo → "Force Server Errors" toggle |
| **Force timeout** | Settings → Developer & Demo → "Force Timeout" toggle |
| **404 Not Found** | Use ID `error_404` in any task/project reference |
| **Network timeout** | Use ID `error_timeout` |
| **Validation error** | Use ID `error_validation` |

When offline:
- Cached data is served from SharedPreferences
- An animated yellow pill appears at the bottom: "You're offline"
- Mutations show clear error messaging with retry
- When reconnected: pill turns green → "Back online" → shrinks and disappears

---

## Authentication & Security

### Login → Token → Session

1. Validates credentials against `auth_mock.test_credentials` from mock JSON
2. Stores tokens via `FlutterSecureStorage` (Android EncryptedSharedPrefs / iOS Keychain)
3. Access token expires after 15 minutes; auto-refreshes if refresh token (7 days) is valid
4. Passwords never stored; tokens never logged; credentials loaded through data layer

### Biometric Unlock

- Toggle in Settings → Security & Privacy → "Biometric unlock"
- When enabled, app launch shows lock screen requiring Face ID / fingerprint
- Falls back to device PIN/pattern if biometrics fail
- Requires `FlutterFragmentActivity` on Android

### Session Timeout

- Configurable in Settings → Security & Privacy → "Auto-lock after inactivity"
- Options: 1 min, 5 min, 15 min, 30 min, Never
- Tracks user touches via GestureDetector + app lifecycle via WidgetsBindingObserver
- Locks to biometric screen when timer fires (requires biometric enabled)

---

## Authorization

| Action | org_admin | member |
|--------|-----------|--------|
| View projects/tasks | ✓ | ✓ |
| Create projects/tasks | ✓ | ✓ |
| Edit projects/tasks | ✓ | ✓ |
| Delete projects | ✓ | ✗ |

- **UI layer**: Admin-only buttons hidden for members
- **Business logic layer**: Repository validates role + org before mutations (defense in depth)

---

## Internationalization (i18n)

Supported locales: **English** (default), **हिन्दी** (Hindi), **Español** (Spanish)

Change language in Settings → Appearance → Language. Navigation labels, page titles, and key UI strings switch immediately.

Implementation: `flutter_localizations` + ARB files in `lib/l10n/`, generated via `flutter gen-l10n`.

---

## Testing

| Type | Location | Count | Covers |
|------|----------|-------|--------|
| Unit | `test/unit/` | 29 | Auth cubit, token refresh, validators, task filtering |
| Widget | `test/widget/` | 40 | Login form, task list states, task card rendering |
| Integration | `test/integration/` | 20 | Login flow, project listing, task CRUD, assignment |

```bash
flutter test                    # All 89 tests
flutter test --coverage         # With coverage report
flutter test test/unit/         # Unit tests only
```

Tests use `mocktail` for mocking and `bloc_test` for Cubit state verification. No network or execution-order dependencies.

---

## Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Cubit over full Bloc | Less boilerplate; still fully testable |
| get_it for DI | Works at pure Dart level, clean service locator |
| go_router + StatefulShellRoute | Declarative, auth guards, retained tab state |
| local_auth for biometrics | Official Flutter plugin, cross-platform |
| CancellationToken pattern | Prevents stale state from superseded requests |
| In-memory mutations | Simplifies mock; mutations persist only per session |
| Role check in both UI + logic | Defense in depth |
| SharedPreferences for cache | Lightweight offline fallback |
| FlutterSecureStorage for tokens | Platform-native encryption |

---

## Known Limitations

1. Mutations reset on app restart (in-memory only, no backend)
2. Token is a mock string; the flow (store/refresh/expire) is real
3. Offline queue survives the session but not full app kill
4. Register simulates success without persisting new users
5. Avatar URLs use `i.pravatar.cc` (need internet for images)
6. No real push notifications; reads from mock data

---

## Build & Run

```bash
flutter pub get              # Install dependencies
flutter run                  # Debug build
flutter test                 # Run all tests
flutter build apk --release  # Production APK
flutter build apk --debug    # Debug APK
```

**Flutter version:** 3.6+ (stable)  
**Dart version:** 3.6+  
**Tested on:** Android (physical device + emulator), iOS Simulator

---

## Project Structure

```
lib/
├── app/           # App root, theme, routes, shell, cubits (settings, connectivity, sync, inactivity)
├── core/          # DI, errors, network, services (biometric, pending queue), shared widgets
├── data/          # Central mock data source
├── features/      # auth, dashboard, projects, tasks, users, notifications, settings
├── l10n/          # ARB localization files (en, hi, es)
└── main.dart

test/
├── unit/          # Business logic tests
├── widget/        # UI component tests
└── integration/   # End-to-end flow tests
```
