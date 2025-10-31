import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'screens/landing_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/auth/pending_approval_page.dart';
import 'screens/member/member_dashboard.dart';
import 'screens/officer/officer_dashboard.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const NeighbourhoodWatchApp());
}

class NeighbourhoodWatchApp extends StatelessWidget {
  const NeighbourhoodWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neighbourhood Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Inter',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(kButtonBorderRadius)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kButtonBorderRadius),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kButtonBorderRadius),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LandingPage(),
        '/login': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/pending': (ctx) => const PendingApprovalPage(),
        '/member': (ctx) => const MemberDashboardPage(),
        '/officer': (ctx) => const OfficerDashboardPage(),
      },
    );
  }
}

// Role-based route helper
class RouteHelper {
  static String getInitialRoute() {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) return '/';

    if (user.isActive) {
      if (user.isMember) return '/member';
      if (user.isOfficer) return '/officer';
    } else if (user.isPending) {
      return '/pending';
    }

    return '/';
  }
}