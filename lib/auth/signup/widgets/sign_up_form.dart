// ignore_for_file: document_ignores, lines_longer_than_80_chars, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_luminous_clone/auth/auth.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
