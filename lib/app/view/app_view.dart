// ignore_for_file: document_ignores

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_luminous_clone/app/app.dart';
import 'package:flutter_luminous_clone/app/view/app_init_utilities.dart';
import 'package:flutter_luminous_clone/l10n/l10n.dart';
import 'package:flutter_luminous_clone/selector/locale/bloc/locale_bloc.dart';
import 'package:flutter_luminous_clone/selector/theme/bloc/theme_mode_bloc.dart';
import 'package:shared/shared.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfig = router(context.read<AppBloc>());

    return BlocBuilder<LocaleBloc, Locale>(
      builder: (context, locale) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => LocaleSettings.setLocaleRaw(locale.languageCode),
        );
        return BlocBuilder<ThemeModeBloc, ThemeMode>(
          builder: (_, themeMode) {
            return AnimatedSwitcher(
              duration: 350.ms,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.noScaling),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  theme: const AppTheme().theme,
                  darkTheme: const AppDarkTheme().theme,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  builder: (context, child) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => initUtilities(context, locale),
                    );
                    return Stack(
                      children: [
                        child!,
                        AppSnackbar(key: snackbarKey),
                        AppLoadingIndeterminate(
                          key: loadingIndeterminateKey,
                        ),
                      ],
                    );
                  },
                  routerConfig: routerConfig,
                  locale: locale,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
