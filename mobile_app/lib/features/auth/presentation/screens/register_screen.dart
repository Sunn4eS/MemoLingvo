import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memo_lingvo/core/localization/l10n/app_localizations.dart';
import 'package:memo_lingvo/features/auth/logic/auth_cubit.dart';
import 'package:memo_lingvo/features/auth/logic/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
      appBar: AppBar(title: Text(l10n.register_screen_register)),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (msg) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg))),
          );
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListenableBuilder(
                    listenable: _emailController,
                    builder: (context, _) {
                      return TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.register_screen_email,
                          suffixIcon: _emailController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () => _emailController.clear(),
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  ListenableBuilder(
                    listenable: _passwordController,
                    builder: (context, _) {
                      return TextField(
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
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  state.maybeWhen(
                    loading: () => const CircularProgressIndicator(),
                    orElse: () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthCubit>().register(
                            _emailController.text,
                            _passwordController.text,
                          );
                        },
                        child: Text(l10n.register_screen_create_account),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RegisterScreen2 extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.register_screen_register),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (msg) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg))),
          );
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: (AppLocalizations.of(
                      context,
                    )!.register_screen_email),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: (AppLocalizations.of(
                      context,
                    )!.register_screen_password),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                state.maybeWhen(
                  loading: () => const CircularProgressIndicator(),
                  orElse: () => ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().register(
                      _emailController.text,
                      _passwordController.text,
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.register_screen_create_account,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
