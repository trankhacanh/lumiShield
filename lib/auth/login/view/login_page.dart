import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/auth/login/login.dart';
import 'package:flutter_luminous_clone/auth/login/widgets/widgets.dart';
import 'package:user_repository/user_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xlg,
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxlg * 2),
            const AppLogo(
              height: AppSpacing.xxxlg,
              fit: BoxFit.fitHeight,
              width: double.infinity,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //login form
                  const LoginForm(),

                  const Padding(
                    padding: EdgeInsets.only(
                      bottom: AppSpacing.md,
                      top: AppSpacing.xs,
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ForgotPasswordButton(),
                    ),
                  ),
                  //sign in button
                  const Align(
                    child: SignInButton(),
                  ),
                  //divider
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: AppDivider(
                      withText: true,
                    ),
                  ),
                  Align(
                    child: AuthProviderSignInButton(
                      provider: AuthProvider.google,
                      onPressed: () =>
                          context.read<LoginCubit>().loginWithGoogle(),
                    ),
                  ),
                  Align(
                    child: AuthProviderSignInButton(
                      provider: AuthProvider.github,
                      onPressed: () =>
                          context.read<LoginCubit>().loginWithGithub(),
                    ),
                  ),
                ],
              ),
            ),
            const SignUpNewAccountButton(),
          ],
        ),
      ),
    );
  }
}
