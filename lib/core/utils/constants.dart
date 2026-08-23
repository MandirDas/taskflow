/// App-wide constants
library;

class AppConstants {
  AppConstants._();

  // Asset paths
  static const String mockDataAssetPath = 'assets/mock_data/mock-data.json';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenTimestampKey = 'token_timestamp';
  static const String userIdKey = 'user_id';
  static const String orgIdKey = 'org_id';
  static const String userRoleKey = 'user_role';
  static const String cachedProjectsKey = 'cached_projects';
  static const String cachedTasksKey = 'cached_tasks';

  // Simulated network delay range (milliseconds)
  static const int minNetworkDelay = 300;
  static const int maxNetworkDelay = 800;

  // Token expiry
  static const int accessTokenExpirySeconds = 900; // 15 minutes
  static const int refreshTokenExpirySeconds = 604800; // 7 days

  // Error trigger IDs — using these IDs will simulate errors
  static const String errorNotFoundId = 'error_404';
  static const String errorTimeoutId = 'error_timeout';
  static const String errorValidationId = 'error_validation';

  // Pagination (if needed)
  static const int defaultPageSize = 20;
}

/// Task status values
class TaskStatus {
  TaskStatus._();

  static const String todo = 'todo';
  static const String inProgress = 'in_progress';
  static const String review = 'review';
  static const String done = 'done';

  static const List<String> all = [todo, inProgress, review, done];

  static String displayName(String status) {
    switch (status) {
      case todo:
        return 'To Do';
      case inProgress:
        return 'In Progress';
      case review:
        return 'Review';
      case done:
        return 'Done';
      default:
        return status;
    }
  }
}

/// Task priority values
class TaskPriority {
  TaskPriority._();

  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String urgent = 'urgent';

  static const List<String> all = [low, medium, high, urgent];

  static String displayName(String priority) {
    switch (priority) {
      case low:
        return 'Low';
      case medium:
        return 'Medium';
      case high:
        return 'High';
      case urgent:
        return 'Urgent';
      default:
        return priority;
    }
  }

  static int sortOrder(String priority) {
    switch (priority) {
      case urgent:
        return 0;
      case high:
        return 1;
      case medium:
        return 2;
      case low:
        return 3;
      default:
        return 4;
    }
  }
}

/// Organization roles
class OrgRole {
  OrgRole._();

  static const String orgAdmin = 'org_admin';
  static const String member = 'member';
}
