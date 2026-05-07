// ignore_for_file: unnecessary_ignore, document_ignores, lines_longer_than_80_chars, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/app/app.dart';
import 'package:flutter_luminous_clone/auth/auth.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          openSnackbar(
            SnackbarMessage.success(
              title: 'Account created successfully!',
              description: 'Welcome! Please log in with your credentials.',
            ),
            clearIfQueue: true,
          );
          // Switch back to login page
          context.read<AuthCubit>().changeAuth(showLogin: true);
        } else if (state.submissionStatus.isError) {
          openSnackbar(
            SnackbarMessage.error(
              title: state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : signupSubmissionStatusMessage[state.submissionStatus]
                            ?.title ??
                        'Something went wrong! Try again later.',
              description: signupSubmissionStatusMessage[state.submissionStatus]
                  ?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (previous, current) {
        return previous.submissionStatus != current.submissionStatus;
      },
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //email
          EmailFormField(),
          SizedBox(height: AppSpacing.md),
          //fullname
          FullNameFormField(),
          SizedBox(height: AppSpacing.md),
          //username
          UsernameFormField(),
          SizedBox(height: AppSpacing.md),
          //password
          PasswordFormField(),
        ],
      ),
    );
  }
}
