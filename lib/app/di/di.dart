// ignore_for_file: document_ignores, specify_nonobvious_property_types

import 'package:get_it/get_it.dart';
import 'package:shared/shared.dart';

final getIt = GetIt.instance;

void setupDi({required AppFlavor appFlavor}) {
  getIt.registerSingleton<AppFlavor>(appFlavor);
}
