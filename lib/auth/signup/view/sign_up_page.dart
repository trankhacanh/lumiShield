import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/auth/auth.dart';
import 'package:luminous_blocks_ui/luminous_blocks_ui.dart';
import 'package:user_repository/user_repository.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  File? _avatarFile;
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxlg + AppSpacing.xlg),
            const AppLogo(
              fit: BoxFit.fitHeight,
            ),
            Expanded(
              child: Column(
                children: [
                  Align(
                    child: AvatarImagePicker(
                      onUpload: (_, avatarFile) {
                        setState(() => _avatarFile = avatarFile);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SignUpForm(),
                  const SizedBox(height: AppSpacing.xlg),
                  SignUpButton(avatarFile: _avatarFile),
                ],
              ),
            ),
            //login in account button
            const SignInIntoAccountButton(),
          ],
        ),
      ),
    );
  }
}
