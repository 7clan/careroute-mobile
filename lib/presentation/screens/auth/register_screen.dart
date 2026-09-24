import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../providers/session_providers.dart';
import '../../widgets/app_text_form_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _submitting = false;
  String? _formError;
  Map<String, List<String>> _fieldErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _formError = null;
      _fieldErrors = {};
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmationController.text,
          );
    } on ValidationException catch (error) {
      // Server-side validation — surface next to the offending fields.
      setState(() => _fieldErrors = error.fieldErrors);
    } on AppException catch (error) {
      setState(() => _formError = error.userMessage);
    } catch (error) {
      setState(() => _formError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join CareRoute',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Save favorite providers and request appointments in '
                      'minutes.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextFormField(
                      controller: _nameController,
                      label: 'Full name',
                      prefixIcon: Icons.person_outline,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) =>
                          _fieldErrors['name']?.firstOrNull ??
                          Validators.name(value),
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) =>
                          _fieldErrors['email']?.firstOrNull ??
                          Validators.email(value),
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscure: true,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) =>
                          _fieldErrors['password']?.firstOrNull ??
                          Validators.password(value),
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      controller: _confirmationController,
                      label: 'Repeat password',
                      prefixIcon: Icons.lock_reset_outlined,
                      obscure: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      validator: (value) =>
                          _fieldErrors['passwordConfirmation']?.firstOrNull ??
                          Validators.passwordConfirmation(
                            value,
                            _passwordController.text,
                          ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_formError != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _formError!,
                                  style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text('Create account'),
                    ),
                    const SizedBox(height: 20),
                    // Wrap: on narrow phones / large text the link
                    // moves to the next line instead of overflowing.
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already registered?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: _submitting
                              ? null
                              : () => context.go('/login'),
                          child: const Text('Sign in'),
                        ),
                      ],
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
