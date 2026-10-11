enum BackendMode { firebase, demo }

class AppConfig {
  const AppConfig({required this.backend});

  final BackendMode backend;

  bool get isDemo => backend == BackendMode.demo;
}
