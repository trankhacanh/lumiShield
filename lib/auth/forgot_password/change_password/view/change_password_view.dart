import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/auth/auth.dart';
import 'package:flutter_luminous_clone/auth/forgot_password/forgot_password.dart';
import 'package:flutter_luminous_clone/l10n/l10n.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  void _confirmGoBack(BuildContext context) => context.confirmAction(
    fn: () => context.read<ManagePasswordCubit>().changeScreen(
      showForgotPassword: true,
    ),
    title: context.l10n.goBackConfirmationText,
    content: context.l10n.loseAllEditsText,
    noText: context.l10n.cancelText,
    yesText: context.l10n.goBackText,
    yesTextStyle: context.labelLarge?.apply(color: AppColors.blue),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmGoBack(context);
      },
      child: AppScaffold(
        releaseFocus: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(context.l10n.changePasswordText),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.adaptive.arrow_back),
            onPressed: () => _confirmGoBack(context),
          ),
        ),
        body: const AppConstrainedScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
          child: Column(
            children: [
              Gap.v(AppSpacing.xxxlg * 3),
              Expanded(
                child: Column(
                  children: [
                    ChangePasswordForm(),
                    Gap.v(AppSpacing.md),
                    ChangePasswordButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
