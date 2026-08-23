# TaskFlow — Technical Architecture & Implementation Plan

## Project Overview

TaskFlow is a lightweight project management mobile application built with Flutter. Users belong to organizations, create/manage projects, view/update tasks, assign work, and receive notifications. The app runs entirely against local mock JSON data, structured so the data layer can be swapped for real HTTP calls with minimal changes.

---

## Technology Stack

| Category | Choice | Justification |
|----------|--------|---------------|
| Framework | Flutter 3.6+ | Required |
| Language | Dart 3.6+ | Required |
| State Management | **flutter_bloc (Cubit)** | Mature, testable, clear separation of UI/logic, built-in state pattern (initial/loading/success/error) |
| Dependency Injection | **get_it + injectable** | Clean service locator with code-gen, easy to swap implementations |
| Routing | **go_router** | Declarative routing, deep-link support, auth redirect guards |
| Local Storage | **flutter_secure_storage** (tokens) + **shared_preferences** (cache) | Secure token persistence, lightweight cache |
| JSON Serialization | **json_serializable + freezed** | Immutable models, union types for states, toJson/fromJson codegen |
| HTTP Abstraction | **dio** (interface only) | Although no real calls are made, structuring around Dio's interceptor pattern allows easy swap later |
| Testing | **flutter_test + bloc_test + mocktail** | Comprehensive mocking, Cubit-specific test utilities |
| Equatable | **equatable** | Value equality for states and models |

---

## Folder Structure

```
lib/
├── main.dart                          # App entry point, DI init, runApp
├── app/
│   ├── app.dart                       # MaterialApp / GoRouter setup
│   ├── theme/
│   │   ├── app_theme.dart             # Light & dark ThemeData
│   │   ├── app_colors.dart            # Color constants
│   │   └── app_typography.dart        # TextStyles
│   └── routes/
│       ├── app_router.dart            # GoRouter configuration
│       └── route_names.dart           # Route path constants
│
├── core/
│   ├── di/
│   │   └── injection.dart             # get_it setup & registration
│   ├── error/
│   │   ├── exceptions.dart            # Custom exceptions (ServerException, CacheException, etc.)
│   │   └── failures.dart              # Failure classes for Either return types
│   ├── network/
│   │   ├── network_info.dart          # Connectivity abstraction (simulated)
│   │   └── api_client.dart            # Abstract API client interface
│   ├── utils/
│   │   ├── constants.dart             # App-wide constants
│   │   ├── validators.dart            # Form validation helpers
│   │   └── date_utils.dart            # Date formatting helpers
│   └── widgets/
│       ├── loading_widget.dart        # Reusable loading indicator
│       ├── error_widget.dart          # Reusable error display with retry
│       ├── empty_state_widget.dart    # Reusable empty state
│       └── confirmation_dialog.dart   # Reusable confirmation dialog
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart      # Secure storage read/write
│   │   │   │   └── auth_mock_datasource.dart       # Mock credential validation
│   │   │   ├── models/
│   │   │   │   ├── auth_credentials_model.dart     # JSON model for credentials
│   │   │   │   └── token_response_model.dart       # JSON model for token response
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart       # Implements AuthRepository
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user_session.dart               # Domain entity
│   │   │   │   └── auth_token.dart                 # Token with expiry
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart            # Abstract interface
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       ├── check_session_usecase.dart
│   │   │       └── refresh_token_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   │
│   ├── projects/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── project_mock_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── project_model.dart
│   │   │   └── repositories/
│   │   │       └── project_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── project.dart
│   │   │   ├── repositories/
│   │   │   │   └── project_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_projects_usecase.dart
│   │   │       ├── create_project_usecase.dart
│   │   │       ├── update_project_usecase.dart
│   │   │       └── delete_project_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── project_list_cubit.dart
│   │       │   └── project_list_state.dart
│   │       └── screens/
│   │           ├── project_list_screen.dart
│   │           └── project_detail_screen.dart
│   │
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── task_mock_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── task_model.dart
│   │   │   └── repositories/
│   │   │       └── task_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── task_entity.dart
│   │   │   │   └── task_filter.dart
│   │   │   ├── repositories/
│   │   │   │   └── task_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_tasks_usecase.dart
│   │   │       ├── create_task_usecase.dart
│   │   │       ├── update_task_usecase.dart
│   │   │       ├── delete_task_usecase.dart
│   │   │       └── assign_task_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── task_list_cubit.dart
│   │       │   ├── task_list_state.dart
│   │       │   ├── task_detail_cubit.dart
│   │       │   └── task_detail_state.dart
│   │       ├── screens/
│   │       │   ├── task_list_screen.dart
│   │       │   ├── task_detail_screen.dart
│   │       │   └── task_form_screen.dart
│   │       └── widgets/
│   │           ├── task_card.dart
│   │           ├── task_filter_bar.dart
│   │           └── priority_badge.dart
│   │
│   ├── users/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── user_mock_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart
│   │   │   │   └── org_member_model.dart
│   │   │   └── repositories/
│   │   │       └── user_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── user.dart
│   │   │   │   └── org_member.dart
│   │   │   ├── repositories/
│   │   │   │   └── user_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_org_members_usecase.dart
│   │   │       └── validate_assignment_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── user_cubit.dart
│   │       └── widgets/
│   │           └── user_avatar.dart
│   │
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── notification_mock_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── notification_model.dart
│   │   │   └── repositories/
│   │   │       └── notification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_notification.dart
│   │   │   └── repositories/
│   │   │       └── notification_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── notification_cubit.dart
│   │       └── screens/
│   │           └── notification_screen.dart
│   │
│   ├── settings/
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   └── settings_cubit.dart
│   │       └── screens/
│   │           └── settings_screen.dart
│   │
│   └── dashboard/
│       └── presentation/
│           └── screens/
│               └── dashboard_screen.dart
│
├── data/
│   └── mock/
│       └── mock_data_source.dart       # Central reader for mock-data.json asset
│
assets/
└── mock_data/
    └── mock-data.json                  # The provided mock data file
│
test/
├── unit/
│   ├── auth/
│   │   ├── auth_cubit_test.dart
│   │   ├── login_usecase_test.dart
│   │   └── token_refresh_test.dart
│   ├── tasks/
│   │   ├── task_filter_test.dart
│   │   └── task_cubit_test.dart
│   ├── projects/
│   │   └── project_cubit_test.dart
│   └── validators/
│       └── form_validators_test.dart
├── widget/
│   ├── login_form_test.dart
│   ├── task_list_test.dart
│   └── task_status_update_test.dart
└── integration/
    ├── login_flow_test.dart
    ├── project_listing_test.dart
    ├── task_listing_test.dart
    ├── task_crud_test.dart
    └── task_assignment_test.dart
```

---

## Layered Architecture (Clean Architecture)

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                           │
│  Screens, Widgets, Cubits (UI logic only)                       │
│  Receives states, dispatches events                             │
└────────────────────────────┬────────────────────────────────────┘
                             │ depends on
┌────────────────────────────▼────────────────────────────────────┐
│                      DOMAIN LAYER                                │
│  Entities, Repository Interfaces, Use Cases                     │
│  Pure Dart — no Flutter imports, no external deps               │
└────────────────────────────┬────────────────────────────────────┘
                             │ implements
┌────────────────────────────▼────────────────────────────────────┐
│                       DATA LAYER                                 │
│  Models (JSON), DataSources (mock reader), Repository Impls     │
│  Converts raw data → domain entities                            │
└─────────────────────────────────────────────────────────────────┘
```

### Dependency Rule
- **Presentation** depends on **Domain** (never on Data).
- **Domain** depends on nothing (pure Dart).
- **Data** implements **Domain** interfaces.
- DI container (get_it) wires Data implementations to Domain interfaces at startup.

---

## State Management Strategy (flutter_bloc / Cubit)

### Why Cubit over full Bloc?
- Less boilerplate (no event classes needed for this scope).
- Still fully testable with `bloc_test`.
- Emits typed states; UI reacts via `BlocBuilder` / `BlocListener`.

### State Pattern (applied to every feature)

```dart
// Using freezed for sealed union types
@freezed
class TaskListState with _$TaskListState {
  const factory TaskListState.initial() = _Initial;
  const factory TaskListState.loading() = _Loading;
  const factory TaskListState.success(List<TaskEntity> tasks) = _Success;
  const factory TaskListState.empty() = _Empty;
  const factory TaskListState.error(String message) = _Error;
}
```

Every Cubit method:
1. Emits `loading`.
2. Calls use case.
3. On success: emits `success(data)` or `empty` if data list is empty.
4. On failure: emits `error(message)`.

---

## Data Layer Architecture

### Mock Data Source (Central Reader)

```dart
abstract class MockDataSource {
  Future<Map<String, dynamic>> loadRawData();
  Future<List<Map<String, dynamic>>> getCollection(String key);
}

class MockDataSourceImpl implements MockDataSource {
  // Reads from bundled asset: assets/mock_data/mock-data.json
  // Caches the parsed Map in memory after first load
  // Adds artificial delay (300–800ms) to simulate network latency
}
```

### Repository Pattern

```dart
// Domain layer — abstract
abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks({required String projectId});
  Future<TaskEntity> getTaskById(String id);
  Future<TaskEntity> createTask(CreateTaskParams params);
  Future<TaskEntity> updateTask(UpdateTaskParams params);
  Future<void> deleteTask(String id);
  Future<TaskEntity> assignTask(String taskId, String? userId);
}

// Data layer — concrete implementation
class TaskRepositoryImpl implements TaskRepository {
  final TaskMockDataSource _dataSource;
  final NetworkInfo _networkInfo;      // Simulated connectivity
  final TaskLocalCache _localCache;    // SharedPreferences cache

  // All methods:
  // 1. Check connectivity (simulated toggle)
  // 2. If online → read from mock data source → cache result → return
  // 3. If offline → read from local cache → return with stale indicator
  // 4. On specific IDs → throw simulated errors (404, timeout, validation)
}
```

### Simulated Error Mechanism

| Trigger | Simulated Error | How to Activate |
|---------|----------------|-----------------|
| Task ID = `"error_404"` | NotFoundException (404) | Create/reference this ID |
| Task ID = `"error_timeout"` | TimeoutException | Create/reference this ID |
| Task ID = `"error_validation"` | ValidationException | Create/reference this ID |
| Debug toggle in Settings | Force offline mode | Switch in Profile/Settings screen |
| Debug toggle in Settings | Force all requests to fail | Switch in Profile/Settings screen |

---

## Authentication Flow

```
┌──────────┐     ┌──────────────┐     ┌───────────────────┐
│  Login   │────▶│  AuthCubit   │────▶│  LoginUseCase     │
│  Screen  │     │              │     │                   │
└──────────┘     └──────────────┘     └─────────┬─────────┘
                                                │
                                    ┌───────────▼───────────┐
                                    │  AuthRepository       │
                                    │  (validates creds     │
                                    │   against mock data)  │
                                    └───────────┬───────────┘
                                                │
                              ┌─────────────────▼─────────────────┐
                              │  SecureStorage                    │
                              │  (stores access_token,            │
                              │   refresh_token, login timestamp) │
                              └───────────────────────────────────┘
```

### Token Refresh Flow
1. On every authenticated request, check `loginTimestamp + 900s < now`.
2. If expired → call `RefreshTokenUseCase` which:
   - Generates a new mock access token string.
   - Updates the stored timestamp.
   - Returns refreshed session.
3. If refresh token also expired (7 days) → force logout.

### Session Check (Splash Screen)
1. Read tokens from secure storage.
2. If no tokens → navigate to Login.
3. If tokens exist and refresh token still valid → refresh access token → navigate to Home.
4. If refresh token expired → clear session → navigate to Login.

---

## Authorization Model

```dart
enum OrgRole { orgAdmin, member }

class AuthorizationService {
  final UserSession currentSession;

  bool canDeleteProject() => currentSession.role == OrgRole.orgAdmin;
  bool canManageMembers() => currentSession.role == OrgRole.orgAdmin;
  bool canCreateTask() => true; // All members can create
  bool canAssignTask() => true; // All members can assign

  // Throws UnauthorizedException if role check fails
  void assertAdmin() {
    if (currentSession.role != OrgRole.orgAdmin) {
      throw UnauthorizedException('Admin access required');
    }
  }
}
```

- UI hides admin-only buttons for members (UX convenience).
- Business logic layer **also** validates role before executing mutations (security enforcement).

---

## Offline Awareness (Simulated)

```dart
abstract class NetworkInfo {
  bool get isConnected;
  Stream<bool> get onConnectivityChanged;
  void setOffline(bool offline); // Debug toggle
}

class SimulatedNetworkInfo implements NetworkInfo {
  // Backed by a BehaviorSubject / ValueNotifier
  // Default: connected = true
  // User can toggle via Settings screen debug switch
}
```

### Offline Behavior
1. **On load**: If offline, serve cached data + show "You're offline — data may be stale" banner.
2. **On mutation**: Queue operation in `PendingOperationsQueue` (local list). Show "Saved offline — will sync when connected."
3. **On reconnect**: Process pending queue, refresh data, dismiss banner.

---

## Navigation (go_router)

```dart
GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final isLoggedIn = authCubit.state is Authenticated;
    final isAuthRoute = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthRoute) return '/auth/login';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_,__) => SplashScreen()),
    GoRoute(path: '/auth/login', builder: (_,__) => LoginScreen()),
    GoRoute(path: '/auth/register', builder: (_,__) => RegisterScreen()),
    ShellRoute(
      builder: (_,__, child) => MainShell(child: child), // Bottom nav
      routes: [
        GoRoute(path: '/home', builder: (_,__) => DashboardScreen()),
        GoRoute(path: '/projects', builder: (_,__) => ProjectListScreen()),
        GoRoute(path: '/projects/:id', builder: (_,state) => ProjectDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/tasks', builder: (_,__) => TaskListScreen()),
        GoRoute(path: '/tasks/:id', builder: (_,state) => TaskDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/tasks/create', builder: (_,__) => TaskFormScreen()),
        GoRoute(path: '/tasks/:id/edit', builder: (_,state) => TaskFormScreen(taskId: state.pathParameters['id'])),
        GoRoute(path: '/notifications', builder: (_,__) => NotificationScreen()),
        GoRoute(path: '/settings', builder: (_,__) => SettingsScreen()),
      ],
    ),
  ],
);
```

---

## Key Dependencies (pubspec.yaml additions)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  # DI
  get_it: ^7.7.0
  injectable: ^2.4.4
  # Routing
  go_router: ^14.3.0
  # Models & Serialization
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  # Local Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.2
  # Utilities
  intl: ^0.19.0
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  # Code Generation
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  injectable_generator: ^2.6.2
  # Testing
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## Mock Data Entities (from mock-data.json)

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| Organization | id, name, created_at | Two orgs: Nimbus Digital, Harborlight Studios |
| User | id, name, email, avatar_url | 5 users across 2 orgs |
| OrgMember | org_id, user_id, role | Roles: org_admin / member |
| Project | id, org_id, name, description, task_count, status, created_at | 3 projects |
| Task | id, project_id, title, description, status, priority, assignee_id, due_date, created_at | 15 tasks |
| Comment | id, task_id, author_id, body, created_at | 4 comments |
| Notification | id, user_id, type, task_id, message, read, created_at | 3 notifications |
| AuthMock | test_credentials[], mock_login_response | 4 test accounts |

### Test Credentials

| Email | Password | Org | Role |
|-------|----------|-----|------|
| ava.admin@nimbusdigital.test | Password123! | Nimbus Digital | org_admin |
| marcus.member@nimbusdigital.test | Password123! | Nimbus Digital | member |
| daniel.admin@harborlightstudios.test | Password123! | Harborlight Studios | org_admin |
| elena.member@harborlightstudios.test | Password123! | Harborlight Studios | member |

---

## Screens & UI Flow

```
Splash ──▶ Login ──▶ Dashboard (Home)
              │           │
              ▼           ├── Projects List ──▶ Project Detail ──▶ Tasks for project
          Register        │
                          ├── Tasks List ──▶ Task Detail
                          │                      │
                          │                      ├── Edit Task
                          │                      └── Assign User
                          │
                          ├── Notifications (bonus)
                          │
                          └── Profile / Settings
                                    │
                                    ├── Logout
                                    ├── Debug: Offline Toggle
                                    └── Debug: Force Error Toggle
```

---

## Implementation Order (Recommended)

| Phase | Tasks | Priority |
|-------|-------|----------|
| 1 | Project setup, folder structure, DI, theme, router, mock data source | Critical |
| 2 | Models & serialization (all entities) | Critical |
| 3 | Auth feature (login, session, token refresh, secure storage) | Critical |
| 4 | Projects feature (list, detail, CRUD) | Critical |
| 5 | Tasks feature (list, detail, CRUD, filters) | Critical |
| 6 | Task assignment & user management | Critical |
| 7 | State management refinement (loading/empty/error across all) | Critical |
| 8 | Offline simulation & error simulation | Required |
| 9 | UI polish (responsive, dark mode, animations) | Important |
| 10 | Notifications (bonus) | Bonus |
| 11 | Testing (unit, widget, integration) | Critical |
| 12 | Documentation (README, architecture doc) | Critical |
| 13 | Build verification & cleanup | Critical |

---

## Testing Strategy

### Unit Tests
- **Auth Cubit**: login success/failure, token refresh, logout.
- **Task filtering logic**: filter by status, priority, assignee, date range.
- **Validation logic**: email format, password strength, required fields.
- **Authorization service**: admin vs member role checks.

### Widget Tests
- **Login form**: validation messages, submit button state, error display.
- **Task list**: loading shimmer, empty state, error state with retry, populated list.
- **Task status update**: status chips, tap to change, confirmation.

### Integration Tests
- **Login flow**: enter credentials → validate → navigate to dashboard.
- **Project listing**: load projects for logged-in user's org.
- **Task listing**: load tasks, apply filters, verify results.
- **Create/update task**: fill form → save → verify in list.
- **Task assignment**: open picker → assign user → verify assignee displayed.

---

## Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Cubit over full Bloc | Less boilerplate for this scope; still fully testable |
| Freezed for states & models | Immutability, sealed unions, auto-generated equality/copyWith |
| get_it over Riverpod | Works at pure Dart level (good for domain layer DI), familiar pattern |
| go_router over Navigator 2.0 raw | Declarative, auth guards built-in, deep-link ready |
| Single JSON file as asset | As specified; parsed once into in-memory collections |
| Artificial delay in data source | Makes loading states visible for demo/testing |
| Role check in both UI and logic layer | Defense in depth — UI hides, logic enforces |

---

## Known Limitations & Trade-offs

1. **No real persistence for mutations** — create/edit/delete only update in-memory state; restarting the app resets data.
2. **Token is not cryptographically valid** — it's a mock string; the flow (store/refresh/expire/clear) is real.
3. **Offline queue does not survive app restart** — pending ops are in-memory only (sufficient for demo).
4. **Single JSON asset** — in production this would be multiple API endpoints; the repository interface abstracts this cleanly.
5. **No real push notifications** — notification screen reads from mock data.

---

## Commands Reference

```bash
# Install dependencies
flutter pub get

# Run code generation (models, DI)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run all tests
flutter test

# Build release APK
flutter build apk --release
```

---

## File: assets/mock_data/mock-data.json

The provided `mock-data.json` is bundled as a Flutter asset and loaded via `rootBundle.loadString()` in the `MockDataSourceImpl`. It is **never** read directly in widgets.
