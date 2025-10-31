import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/patrol_service.dart';
import '../../widgets/shared/neumorphic_card.dart';
import '../../widgets/shared/gradient_button.dart';
import 'edit_profile_dialog.dart';

class MemberDashboardPage extends StatefulWidget {
  const MemberDashboardPage({super.key});

  @override
  State<MemberDashboardPage> createState() => _MemberDashboardPageState();
}

class _MemberDashboardPageState extends State<MemberDashboardPage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PatrolService _patrolService = PatrolService();

  Map<String, dynamic> _patrolStats = {};
  bool _isLoading = true;
  bool _sosLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatrolStats();
  }

  Future<void> _loadPatrolStats() async {
    try {
      final stats = await _patrolService.getPatrolStats();
      setState(() {
        _patrolStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Silently fail for stats loading
    }
  }

  void _showEditProfile() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        user: _authService.currentUser!,
        onProfileUpdated: (updatedUser) {
          // Update the current user in auth service
          // In a real app, you might want to refresh the user data
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _triggerSOS() async {
    setState(() => _sosLoading = true);

    // Simulate SOS API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _sosLoading = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 12),
            Text('Emergency Alert Sent'),
          ],
        ),
        content: const Text(
          'Your SOS alert has been sent to nearby officers and emergency services. Help is on the way!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    _authService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      _logout();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultMargin),
          child: Column(
            children: [
              // Welcome Header
              NeumorphicCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue[300]!, width: 2),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue[700],
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: _showEditProfile,
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SOS Emergency Button
              NeumorphicCard(
                padding: const EdgeInsets.all(24),
                color: Colors.red[50],
                child: Column(
                  children: [
                    const Icon(
                      Icons.emergency,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Emergency SOS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use this button only in case of emergencies to alert nearby officers and emergency services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: _sosLoading ? 'SENDING ALERT...' : 'SOS EMERGENCY',
                        onPressed: _sosLoading ? null : _triggerSOS,
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Patrol Statistics
              const Text(
                'Community Patrol Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    title: 'Total Patrols',
                    value: _patrolStats['totalPatrols']?.toString() ?? '0',
                    icon: Icons.directions_walk,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Today\'s Patrols',
                    value: _patrolStats['todayPatrols']?.toString() ?? '0',
                    icon: Icons.today,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Anomalies',
                    value: _patrolStats['anomalies']?.toString() ?? '0',
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Completion Rate',
                    value: '${_patrolStats['completionRate']?.toString() ?? '0'}%',
                    icon: Icons.analytics,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    title: 'My Profile',
                    icon: Icons.person,
                    color: Colors.blue,
                    onTap: _showEditProfile,
                  ),
                  _buildActionCard(
                    title: 'Safety Tips',
                    icon: Icons.security,
                    color: Colors.green,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Safety Tips - Coming Soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Neighborhood Info',
                    icon: Icons.map,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Neighborhood Info - Coming Soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Contact Officers',
                    icon: Icons.contact_phone,
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact Officers - Coming Soon')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return NeumorphicCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}