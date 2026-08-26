import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/core/widgets/app_branding.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final profile = viewModel.userProfile;
      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No fue posible obtener el perfil del usuario.'),
          ),
        );
        return;
      }
      switch (profile.rol) {
        case UserRole.optico:
          context.go('/optico');
        case UserRole.administrador:
          context.go('/administrador');
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible iniciar sesión.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: WarmGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FadeSlideIn(child: Center(child: OculistLogo())),
                      const SizedBox(height: 22),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          children: [
                            Text(
                              'Oculist',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: AppTheme.crimson,
                                fontSize: 42,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gestión óptica inteligente',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF756765),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 180),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Bienvenido',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Ingresa tus datos para continuar.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF756765),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  key: const Key('email_field'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                    ),
                                  ),
                                  validator: viewModel.validateEmail,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: const Key('password_field'),
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _submitForm(),
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip: _obscurePassword
                                          ? 'Mostrar contraseña'
                                          : 'Ocultar contraseña',
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  validator: viewModel.validatePassword,
                                ),
                                const SizedBox(height: 22),
                                GradientActionButton(
                                  key: const Key('login_button'),
                                  onPressed: viewModel.isLoading
                                      ? null
                                      : _submitForm,
                                  icon: Icons.login_rounded,
                                  label: viewModel.isLoading
                                      ? 'Ingresando...'
                                      : 'Iniciar sesión',
                                  isLoading: viewModel.isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 260),
                        child: Text(
                          'Acceso exclusivo para personal autorizado',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A7775),
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
      ),
    );
  }
}
