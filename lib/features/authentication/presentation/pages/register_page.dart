import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/localization/l10n.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/usecases/register_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../../../../app/router/route_names.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _selectedGender;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated || state is AuthRegistered) {
            context.go(RouteNames.patientDashboard);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () => context.pop(),
              ),
              title: Text(l10n.register),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppDimensions.screenPaddingH,
                  vertical: AppDimensions.screenPaddingV,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.translate('fullName'),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.translate('required')
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.translate('required');
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(v)) {
                            return l10n.translate('invalidEmail');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Phone
                      TextFormField(
                        controller: _phoneCtrl,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.translate('phone'),
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.translate('required')
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Gender
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: l10n.translate('gender'),
                          prefixIcon: const Icon(Icons.wc_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text(l10n.translate('male')),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text(l10n.translate('female')),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedGender = v),
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () =>
                                  _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.translate('required');
                          }
                          if (v.length < 8) {
                            return l10n.translate('passwordTooShort');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: l10n.translate('confirmPassword'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () =>
                                  _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.translate('required');
                          }
                          if (v != _passwordCtrl.text) {
                            return l10n
                                .translate('passwordsDoNotMatch');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.spaceXXL),

                      // Register Button
                      AppButton(
                        label: l10n.register,
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.translate('alreadyHaveAccount'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(l10n.login),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthRegisterEvent(
        RegisterParams(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          phone: _phoneCtrl.text.trim(),
          gender: _selectedGender,
        ),
      ),
    );
  }
}
