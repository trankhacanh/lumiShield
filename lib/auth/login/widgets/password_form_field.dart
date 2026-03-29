

// ignore_for_file: document_ignores, avoid_types_on_closure_parameters

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/auth/login/login.dart';
import 'package:flutter_luminous_clone/l10n/l10n.dart';

import 'package:shared/shared.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({super.key});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  late Debouncer _debouncer;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_focusNodeListener);
    _debouncer = Debouncer();
  }

  void _focusNodeListener() {
    if (!_focusNode.hasFocus) {
      context.read<LoginCubit>().onPasswordUnfocused();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode..removeListener(_focusNodeListener)..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordError = 
      context.select((LoginCubit cubit) => cubit.state.password.errorMessage);
    final showPassword = 
      context.select((LoginCubit cubit) => cubit.state.showPassword);
    return AppTextField(
      filled: true,
      errorText: passwordError,
      textController: _controller,
      focusNode: _focusNode,
      hintText: context.l10n.passwordText ,
      obscureText: !showPassword,
      suffixIcon: Tappable(
        color: AppColors.transparent,
        onTap: context.read<LoginCubit>().changePasswordVisibility,
        child: Icon(
          !showPassword ? Icons.visibility : Icons.visibility_off,
          color: context.customAdaptiveColor(light: AppColors.grey),
        ),
      ),
      textInputType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onChanged: (value) => _debouncer.run(() {
        context.read<LoginCubit>().onPasswordChanged(value);
      }),
    );
  }
}
