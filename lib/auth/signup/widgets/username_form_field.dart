// ignore_for_file: document_ignores, avoid_types_on_closure_parameters

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/auth/auth.dart';
import 'package:flutter_luminous_clone/l10n/l10n.dart';

import 'package:shared/shared.dart';

class UsernameFormField extends StatefulWidget {
  const UsernameFormField({super.key});

  @override
  State<UsernameFormField> createState() => _UsernameFormFieldState();
}

class _UsernameFormFieldState extends State<UsernameFormField> {
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
      context.read<SignUpCubit>().onUsernameUnfocused();
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
    final isLoading = context.select(
      (SignUpCubit cubit) => cubit.state.submissionStatus.isLoading,
    );
    final usernameError = context.select(
      (SignUpCubit cubit) => cubit.state.username.errorMessage,
    );
    return AppTextField(
      filled: true,
      errorText: usernameError,
      focusNode: _focusNode,
      enabled: !isLoading,
      hintText: context.l10n.usernameText,
      textInputAction: TextInputAction.next,
      errorMaxLines: 3,
      autofillHints: const [AutofillHints.name],
      onChanged: (value) => _debouncer.run(() {
        context.read<SignUpCubit>().onUsernameChanged(value);
      }),
    );
  }
}
