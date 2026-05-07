import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_luminous_clone/app/app.dart';
import 'package:flutter_luminous_clone/bootstrap.dart';
import 'package:flutter_luminous_clone/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

Future<void> main() async {
  await bootstrap(
    (powersyncRepository) async {
      final tokenStorage = InMemoryTokenStorage();

      final iosClientId = getIt<AppFlavor>().getEnv(Env.iOSClientId);
      final webClientId = getIt<AppFlavor>().getEnv(Env.webClientId);
      final googleSignIn = GoogleSignIn(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? iosClientId
            : null,
        serverClientId: webClientId,
      );
      final supabaseAuthenticationClient = SupabaseAuthenticationClient(
        powerSyncRepository: powersyncRepository,
        tokenStorage: tokenStorage,
        googleSignIn: googleSignIn,
      );

      final powerSyncDatabaseClient = PowerSyncDatabaseClient(
        powerSyncRepository: powersyncRepository,
      );

      final userRepository = UserRepository(
        databaseClient: powerSyncDatabaseClient,
        authenticationClient: supabaseAuthenticationClient,
      );

      final postsRepository = PostsRepository(
        databaseClient: powerSyncDatabaseClient,
      );
      return App(
        user: await userRepository.user.first,
        userRepository: userRepository,
        postsRepository: postsRepository,
      );
    },
    appFlavor: AppFlavor.development(),
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
