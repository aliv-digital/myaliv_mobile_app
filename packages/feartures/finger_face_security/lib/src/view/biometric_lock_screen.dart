import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finger_face_security/src/bloc/finger_face_security_cubit.dart';
import 'package:finger_face_security/src/bloc/finger_face_security_state.dart';
import 'package:finger_face_security/src/services/biometric_auth_service.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({
    super.key,
    this.onAuthSuccess,
    this.onAuthError,
    this.appName = 'MyAliv',
    this.appIcon,
    this.lockSubtitle,
  });

  final VoidCallback? onAuthSuccess;
  final VoidCallback? onAuthError;
  final String appName;
  final Widget? appIcon;
  final String? lockSubtitle;

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isAuthenticating = false;
  String _statusMessage = 'Touch the sensor to unlock';
  String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndAuthenticate();
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  Future<void> _loadAndAuthenticate() async {
    final cubit = context.read<FingerFaceSecurityCubit>();
    await cubit.loadBiometricStatus();
    if (mounted) {
      final type = cubit.state.data?.biometricTypeDescription ?? 'Biometric';
      setState(() {
        _biometricType = type;
        _statusMessage = _getStatusMessage(type);
      });
      await cubit.authenticate(reason: 'Unlock ${widget.appName} to continue');
    }
  }

  Future<void> _retryAuthentication() async {
    if (_isAuthenticating) return;
    final cubit = context.read<FingerFaceSecurityCubit>();
    await cubit.authenticate(reason: 'Unlock ${widget.appName} to continue');
  }

  String _getStatusMessage(String type) => switch (type.toLowerCase()) {
        'fingerprint' => 'Place any registered finger on the sensor',
        'face id' => 'Look directly at the front camera',
        'iris' => 'Look at the camera for iris scan',
        _ => 'Use your registered biometric',
      };

  IconData _getBiometricIcon(String type) => switch (type.toLowerCase()) {
        'fingerprint' => Icons.fingerprint_rounded,
        'face id' => Icons.face_rounded,
        _ => Icons.security_rounded,
      };

  void _handleState(BuildContext context, FingerFaceSecurityState state) {
    switch (state.status) {
      case FingerFaceSecurityStatus.authenticating:
        setState(() {
          _isAuthenticating = true;
          _statusMessage = 'Authenticating...';
        });
      case FingerFaceSecurityStatus.authenticated:
        HapticFeedback.lightImpact();
        setState(() {
          _isAuthenticating = false;
          _statusMessage = 'Authentication successful!';
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onAuthSuccess?.call();
        });
      case FingerFaceSecurityStatus.failure:
        HapticFeedback.heavyImpact();
        setState(() {
          _isAuthenticating = false;
          _statusMessage = state.errorMessage ?? 'Authentication failed. Please try again.';
        });
        if (state.lastAuthResult == BiometricAuthResult.deviceNotSupported ||
            state.lastAuthResult == BiometricAuthResult.biometricsNotAvailable) {
          widget.onAuthError?.call();
        }
      default:
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<FingerFaceSecurityCubit, FingerFaceSecurityState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerLowest,
                ],
              ),
            ),
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: widget.appIcon ??
                          Icon(
                            Icons.lock_rounded,
                            size: 48,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      widget.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.lockSubtitle ?? 'Your app is locked',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Biometric icon with pulse + ripple
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, _) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.5,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getBiometricIcon(_biometricType),
                                size: 52,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _statusMessage,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_biometricType.toLowerCase().contains('fingerprint') &&
                        !_isAuthenticating)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Try any of your registered fingers',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    if (_isAuthenticating)
                      Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 48),

                    if (!_isAuthenticating)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _retryAuthentication,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getBiometricIcon(_biometricType)),
                              const SizedBox(width: 8),
                              Text('Try $_biometricType Again'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
