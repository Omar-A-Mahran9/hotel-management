/// Route names and paths.
///
/// Phase 0 registers only [foundation]. Feature routes (auth, discovery,
/// availability, reservations, …) are added here as each mobile phase lands, so
/// there is one place to see the navigation surface.
abstract final class AppRoutes {
  static const String foundation = '/';
  static const String foundationName = 'foundation';
}
