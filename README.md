# Neighbourhood Watch - Officer & Member Mobile App

A comprehensive Flutter-based mobile application for community safety management, designed for security officers and community members to collaborate on neighborhood security.

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Application entry point
├── constants/
│   └── app_constants.dart    # API URLs and design constants
├── models/
│   ├── user.dart            # User data model
│   ├── patrol.dart          # Patrol logging model
│   └── checkpoint.dart      # Checkpoint location model
├── services/
│   ├── auth_service.dart    # Authentication & user management
│   ├── patrol_service.dart  # Patrol operations
│   └── checkpoint_service.dart # Checkpoint management
├── screens/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── pending_approval_page.dart
│   ├── member/
│   │   ├── member_dashboard.dart
│   │   └── edit_profile_dialog.dart
│   └── officer/
│       ├── officer_dashboard.dart
│       ├── checkpoint_selection_page.dart
│       ├── log_patrol_page.dart
│       ├── patrol_history_page.dart
│       └── qr_scanner_page.dart
└── widgets/
    └── shared/
        ├── neumorphic_card.dart
        └── gradient_button.dart
```

## 👥 User Roles & Features

### 🔐 Authentication Flow
- **Registration**: Users can register as Members or Officers
- **Approval System**: New accounts require admin approval before activation
- **Role-based Access**: Automatic routing to appropriate dashboard based on user role

### 👨‍💼 Member Features
- **Member Dashboard**: Personalized welcome with user information
- **Emergency SOS**: Prominent red SOS button for immediate emergency alerts
- **Profile Management**: Edit personal details (name, email, phone)
- **Patrol Statistics**: View community patrol metrics and security activity
- **Safety Tools**: Quick access to safety tips and neighborhood information

### 👮 Officer Features
- **Officer Dashboard**: Professional interface with duty status
- **Patrol Logging**: 
  - Checkpoint selection from available locations
  - GPS-automated location capture
  - Contextual patrol comments
  - Anomaly reporting for suspicious activities
- **Patrol History**: Complete log of all patrol activities with timestamps
- **QR Code Scanning**: Mobile-optimized checkpoint scanning (manual entry available on web)
- **Performance Metrics**: Patrol statistics and completion rates

## 🛠️ Technical Implementation

### Backend Integration
- **RESTful API** communication with neighborhood watch backend
- **JWT-based authentication** for secure user sessions
- **Real-time data synchronization** for patrol logs and user status

### Design System
- **Neumorphic UI Design**: Modern, tactile interface elements
- **Responsive Layout**: Optimized for both mobile and tablet devices
- **Consistent Branding**: Green/blue color scheme with clear visual hierarchy
- **Accessibility**: WCAG-compliant contrast ratios and touch targets

### Security Features
- **GPS Verification**: All patrols include location validation
- **Role-based Permissions**: Strict separation between member and officer functionalities
- **Data Validation**: Input sanitization and format verification
- **Secure Storage**: Protected credential and session management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 2.17+
- Backend API running on `http://localhost:8080`

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Update API configuration in `constants/app_constants.dart`
4. Run the application:
   ```bash
   flutter run
   ```

### Environment Setup
```dart
// Update in constants/app_constants.dart
const String API_BASE_URL = 'http://your-backend-url:8080/api';
```

## 📱 Key User Flows

### Member Journey
1. **Register/Login** → **Pending Approval** → **Member Dashboard**
2. **View Security Stats** → **Access Safety Resources**
3. **Emergency Situations** → **Trigger SOS Alert**

### Officer Workflow
1. **Register/Login** → **Officer Dashboard**
2. **Start Patrol** → **Select Checkpoint** → **Log Observations**
3. **Review History** → **Monitor Patrol Metrics**

## 🔌 API Endpoints Used

### Authentication
- `POST /auth/register/{role}` - User registration
- `POST /auth/login` - User authentication
- `GET /auth/check/{email}` - User existence check

### User Management
- `PUT /users/{userUUID}` - Profile updates
- `GET /users` - User listing (admin)

### Patrol Operations
- `POST /patrols/{officerUUID}/{checkpointUUID}` - Create patrol log
- `GET /patrols` - Retrieve all patrols
- `GET /patrols/officer/{officerUUID}` - Officer-specific patrol history

### Checkpoint Management
- `GET /checkpoints` - List all available checkpoints
- `GET /checkpoints/{checkpointUUID}` - Specific checkpoint details
- `GET /checkpoints/code/{code}` - Checkpoint by code

## 🎨 UI/UX Features

### Design Principles
- **Intuitive Navigation**: Clear hierarchy and predictable interactions
- **Visual Feedback**: Immediate response to user actions
- **Progressive Disclosure**: Information revealed as needed
- **Consistent Patterns**: Reusable components and interaction models

### Responsive Behavior
- **Mobile-First**: Optimized for handheld devices
- **Tablet Adaptation**: Enhanced layouts for larger screens
- **Web Fallbacks**: Graceful degradation for browser environments

## 🔒 Security & Privacy

### Data Protection
- Secure credential storage
- HTTPS API communication
- Minimal data collection
- GDPR-compliant practices

### Access Control
- Role-based feature access
- Session timeout handling
- Secure logout functionality
- Approval workflow enforcement

## 📈 Performance Optimizations

- Efficient state management
- Optimized image assets
- Lazy loading for lists
- Minimal API calls with caching
- Smooth animations and transitions

## 🐛 Troubleshooting

### Common Issues
1. **API Connection Failed**: Verify backend server is running
2. **Permission Denied**: Ensure camera/location permissions are granted
3. **QR Scanning Issues**: Use manual entry on web browsers
4. **Login Failures**: Check account approval status with administrator

### Support
For technical support, contact your system administrator or refer to the backend API documentation.

## 📄 License

This application is part of the Neighbourhood Watch System. All rights reserved.

---

**Version**: 1.0  
**Last Updated**: October, 2025  
**Compatibility**: iOS 13+, Android 8+, Web Browsers
