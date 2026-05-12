import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/auth/logic/auth_cubit.dart';
import 'package:memo_lingvo/features/auth/logic/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login_screen_title)),
      body: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: _emailController,
                  builder: (context, _) => TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.register_screen_email,
                      suffixIcon: _emailController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _emailController.clear(),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ListenableBuilder(
                  listenable: _passwordController,
                  builder: (context, _) => TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.register_screen_password,
                      suffixIcon: _passwordController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _passwordController.clear(),
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                state.maybeWhen(
                  loading: () => const CircularProgressIndicator(),
                  orElse: () => Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.read<AuthCubit>().login(
                            _emailController.text,
                            _passwordController.text,
                          ),
                          child: Text(l10n.login_screen_title),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: Text(l10n.login_screen_no_account),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        listener: (context, state) {
          state.whenOrNull(
            authenticated: (user) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          );
        },
      ),
    );
  }
}
