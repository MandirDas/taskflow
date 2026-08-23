/// Centralized route path constants.
library;

class RouteNames {
  RouteNames._();

  // Auth routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String lock = '/lock';

  // Main routes
  static const String home = '/home';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/:id';
  static const String createTask = '/tasks/create';
  static const String editTask = '/tasks/:id/edit';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  // Helper methods for dynamic paths
  static String projectDetailPath(String id) => '/projects/$id';
  static String taskDetailPath(String id) => '/tasks/$id';
  static String editTaskPath(String id) => '/tasks/$id/edit';
  static String createTaskForProject(String projectId) =>
      '/tasks/create?projectId=$projectId';
}
