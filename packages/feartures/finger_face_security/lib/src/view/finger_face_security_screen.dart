import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finger_face_security/src/bloc/finger_face_security_cubit.dart';
import 'package:finger_face_security/src/bloc/finger_face_security_state.dart';

class FingerFaceSecurityScreen extends StatefulWidget {
  const FingerFaceSecurityScreen({super.key});

  @override
  State<FingerFaceSecurityScreen> createState() =>
      _FingerFaceSecurityScreenState();
}

class _FingerFaceSecurityScreenState extends State<FingerFaceSecurityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FingerFaceSecurityCubit>().loadBiometricStatus();
    });
  }

  Future<void> _handleToggle(bool value) async {
    final cubit = context.read<FingerFaceSecurityCubit>();
    if (value) {
      await cubit.enableBiometric();
    } else {
      await cubit.disableBiometric();
    }
  }

  void _handleStateChange(BuildContext context, FingerFaceSecurityState state) {
    if (state.status == FingerFaceSecurityStatus.failure &&
        state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (state.status == FingerFaceSecurityStatus.setupSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric security enabled'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FingerFaceSecurityCubit, FingerFaceSecurityState>(
      listener: _handleStateChange,
      builder: (context, state) {
        final isLoading = state.isLoading;
        final data = state.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Biometric Security'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 24),

              // Header icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data?.isFaceIdAvailable == true
                        ? Icons.face_rounded
                        : Icons.fingerprint_rounded,
                    size: 48,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  data?.biometricTypeDescription ?? 'Biometric Security',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Secure your app with biometric authentication',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // Toggle tile
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable Biometric Lock'),
                    subtitle: Text(
                      data?.isBiometricEnabled == true
                          ? 'App will require biometric on launch'
                          : 'Tap to enable biometric lock',
                    ),
                    value: data?.isBiometricEnabled ?? false,
                    onChanged: isLoading ? null : _handleToggle,
                    secondary: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            data?.isBiometricEnabled == true
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            color: data?.isBiometricEnabled == true
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info card
              if (data?.isAnyBiometricAvailable == false)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: theme.colorScheme.onErrorContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No biometrics enrolled on this device. '
                              'Set up fingerprint or face ID in device settings first.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
