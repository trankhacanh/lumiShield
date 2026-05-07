import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/app/app.dart';
import 'package:flutter_luminous_clone/auth/forgot_password/forgot_password.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  @override
  void initState() {
    super.initState();
    context.read<ChangePasswordCubit>().resetState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ChangePasswordCubit>().resetState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          openSnackbar(
            SnackbarMessage.success(
              title: changePasswordStatusMessage[state.status]!.title,
              description:
                  changePasswordStatusMessage[state.status]?.description,
            ),
          );
        }
      },
      listenWhen: (previous, current) => previous.status != current.status,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ChangePasswordOtpField(),
          Gap.v(AppSpacing.md),
          ChangePasswordField(),
        ],
      ),
    );
  }
}
