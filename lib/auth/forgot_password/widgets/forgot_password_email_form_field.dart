// ignore_for_file: document_ignores, avoid_types_on_closure_parameters

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/auth/forgot_password/forgot_password.dart';
import 'package:flutter_luminous_clone/l10n/l10n.dart';

import 'package:shared/shared.dart';

class ForgotPasswordEmailFormField extends StatefulWidget {
  const ForgotPasswordEmailFormField({super.key});

  @override
  State<ForgotPasswordEmailFormField> createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<ForgotPasswordEmailFormField> {
  late Debouncer _debouncer;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_focusNodeListener);
    _debouncer = Debouncer();
  }

  void _focusNodeListener() {
    if (!_focusNode.hasFocus) {
      context.read<ForgotPasswordCubit>().onEmailUnfocused();
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_focusNodeListener)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailError = context.select(
      (ForgotPasswordCubit cubit) => cubit.state.email.errorMessage,
    );
    return AppTextField(
      filled: true,
      errorText: emailError,
      focusNode: _focusNode,
      hintText: context.l10n.emailText,
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (value) => _debouncer.run(() {
        context.read<ForgotPasswordCubit>().onEmailChanged(value);
      }),
    );
  }
}
