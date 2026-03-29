
// ignore_for_file: document_ignores, lines_longer_than_80_chars, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_luminous_clone/auth/login/widgets/widgets.dart';


class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmailFormField(),
              SizedBox(height: AppSpacing.md),
              PasswordFormField(),
            ],
          );
      },
    );
  }
}
