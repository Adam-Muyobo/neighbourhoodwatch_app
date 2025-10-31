import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants/app_constants.dart';
import '../../services/patrol_service.dart';
import '../../services/auth_service.dart';
import '../../services/checkpoint_service.dart'; // Add this import
import '../../models/checkpoint.dart'; // Add this import
import '../../widgets/shared/neumorphic_card.dart';
import '../../widgets/shared/gradient_button.dart';
import 'log_patrol_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final CheckpointService _checkpointService = CheckpointService(); // Add this
  String? scannedData;
  bool _isLoading = false;
  final bool _isWebOrDesktop = kIsWeb || (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  void initState() {
    super.initState();
    if (!_isWebOrDesktop) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (!mounted) return;

    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;

    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
    if (!locationStatus.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> _processScannedData(String data) async {
    if (scannedData != null) return; // Prevent multiple scans

    setState(() {
      scannedData = data;
      _isLoading = true;
    });

    // Validate if it's a UUID format
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);

    if (!uuidRegex.hasMatch(data)) {
      _showError('Invalid QR Code: Not a valid checkpoint UUID');
      return;
    }

    try {
      // Get the checkpoint details
      final checkpoint = await _checkpointService.getCheckpoint(data);

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Navigate to patrol logging page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LogPatrolPage(
              checkpoint: checkpoint, // Changed from checkpointUUID to checkpoint
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to load checkpoint: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );

    // Reset scanner after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          scannedData = null;
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildWebFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Checkpoint Entry',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'QR scanning is optimized for mobile devices. '
                      'Please use the manual entry option below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Processing checkpoint...',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: 'ENTER CHECKPOINT MANUALLY',
                    onPressed: _isLoading ? null : () {
                      showDialog(
                        context: context,
                        builder: (context) => ManualEntryDialog(
                          onCheckpointEntered: (uuid) {
                            if (uuid.isNotEmpty) {
                              _processScannedData(uuid);
                            }
                          },
                        ),
                      );
                    },
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileScanner() {
    return Column(
      children: [
        // Instructions
        NeumorphicCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan Checkpoint QR Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Point your camera at the QR code located at the checkpoint to log your patrol.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Processing QR code...',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Mobile Scanner Placeholder (since we removed the package)
        Expanded(
          child: NeumorphicCard(
            padding: const EdgeInsets.all(2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Mobile QR Scanner',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'QR scanning functionality would be available on mobile devices',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'USE MANUAL ENTRY INSTEAD',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ManualEntryDialog(
                        onCheckpointEntered: (uuid) {
                          if (uuid.isNotEmpty) {
                            _processScannedData(uuid);
                          }
                        },
                      ),
                    );
                  },
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Manual Entry Option
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ManualEntryDialog(
                onCheckpointEntered: (uuid) {
                  if (uuid.isNotEmpty) {
                    _processScannedData(uuid);
                  }
                },
              ),
            );
          },
          child: const Text(
            'Enter Checkpoint UUID Manually',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Checkpoint QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultMargin),
          child: _isWebOrDesktop ? _buildWebFallback() : _buildMobileScanner(),
        ),
      ),
    );
  }
}

class ManualEntryDialog extends StatefulWidget {
  final Function(String) onCheckpointEntered;

  const ManualEntryDialog({super.key, required this.onCheckpointEntered});

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Manual Checkpoint Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter the checkpoint UUID found at the patrol location:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Checkpoint UUID',
                border: OutlineInputBorder(),
                hintText: 'Enter the 36-character checkpoint UUID',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientButton(
                    text: 'Continue',
                    onPressed: () {
                      final uuid = _controller.text.trim();
                      if (uuid.isNotEmpty) {
                        // Validate UUID format
                        final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
                        if (uuidRegex.hasMatch(uuid)) {
                          Navigator.of(context).pop();
                          widget.onCheckpointEntered(uuid);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid UUID format'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    },
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}