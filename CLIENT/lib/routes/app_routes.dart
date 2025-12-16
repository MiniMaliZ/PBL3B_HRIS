import 'package:go_router/go_router.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/schedule/screens/schedule_page.dart';
import '../features/schedule/screens/schedule_add_page.dart';
import '../features/absensi/screens/attendance_screen.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/schedule', builder: (ctx, state) => const SchedulePage()),
      GoRoute(
        path: '/schedule/add',
        builder: (ctx, state) => const ScheduleAddPage(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
    ],
  );
}
