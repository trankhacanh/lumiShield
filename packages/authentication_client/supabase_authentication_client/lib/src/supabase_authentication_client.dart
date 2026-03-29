// ignore_for_file: avoid_catches_without_on_clauses, lines_longer_than_80_chars, document_ignores, use_null_aware_elements

import 'dart:convert';

import 'package:authentication_client/authentication_client.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:token_storage/token_storage.dart';

/// {@template supabase_authentication_client}
/// A Supabase implementation of the [AuthenticationClient] interface.
/// {@endtemplate}
class SupabaseAuthenticationClient implements AuthenticationClient {
  /// {@macro supabase_authentication_client}
  SupabaseAuthenticationClient({
    required PowerSyncRepository powerSyncRepository,
    required TokenStorage tokenStorage,
    required GoogleSignIn googleSignIn,
  }) : _tokenStorage = tokenStorage,
       _powerSyncRepository = powerSyncRepository,
       _googleSignIn = googleSignIn {
    user.listen(_onUserChanged);
  }

  final TokenStorage _tokenStorage;
  final PowerSyncRepository _powerSyncRepository;
  final GoogleSignIn _googleSignIn;

  /// Stream of [AuthenticationUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AuthenticationUser.anonymous] if the user is not authenticated.
  @override
  Stream<AuthenticationUser> get user {
    return _powerSyncRepository.authStateChanges().map((state) {
      final supabaseUser = state.session?.user;
      return supabaseUser == null
          ? AuthenticationUser.anonymous
          : supabaseUser.toUser;
    });
  }

  @override
  Future<void> logInWithPassword({
    required String password,
    String? email,
    String? phone,
  }) async {
    try {
      if (email == null && phone == null) {
        throw const LogInWithPasswordCanceled(
          'You must provide either an email, phone number.',
        );
      }
      await _powerSyncRepository.supabase.auth.signInWithPassword(
        email: email,
        phone: phone,
        password: password,
      );
    } on LogInWithPasswordCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithPasswordFailure(error), stackTrace);
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [LogInWithGoogleCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithGoogleFailure] if an exception occurs.
  @override
  Future<void> logInWithGoogle() async {
    logD('[SupabaseAuth] Bắt đầu logInWithGoogle');
    // Lưu ý: Đảm bảo Web Client ID này đã có trên Supabase Dashboard -> Authentication -> Providers -> Google
    // Client ID nên là Web Client ID, và cũng nên thêm nó vào "Authorized Client IDs".

    // Đảm bảo lấy Token mới nhất bằng cách đăng xuất trước khi đăng nhập
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        logD('[SupabaseAuth] logInWithGoogle đã bị hủy bởi người dùng');
        throw const LogInWithGoogleCanceled(
          'Sign in with Google canceled. No user found!',
        );
      }
      logD(
        '[SupabaseAuth] Đã đăng nhập Google thành công: ${googleUser.email}',
      );

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      logD(
        '[SupabaseAuth] Access Token: len=${accessToken?.length}, prefix=${accessToken?.substring(0, accessToken.length > 10 ? 10 : accessToken.length)}...',
      );
      logD(
        '[SupabaseAuth] ID Token: len=${idToken?.length}, prefix=${idToken?.substring(0, idToken.length > 10 ? 10 : idToken.length)}...',
      );

      if (idToken != null) {
        try {
          final parts = idToken.split('.');
          if (parts.length == 3) {
            final payloadPart = parts[1];
            final normalized = base64.normalize(payloadPart);
            final payloadString = utf8.decode(base64.decode(normalized));
            final payload = json.decode(payloadString) as Map<String, dynamic>;
            logD('[SupabaseAuth] ID Token Claims: iss=${payload['iss']}, aud=${payload['aud']}, email=${payload['email']}, nonce=${payload['nonce']}');
          }
        } catch (e) {
          logE('[SupabaseAuth] Lỗi giải mã JWT: $e');
        }
      }

      if (accessToken == null) {
        logE('[SupabaseAuth] accessToken bị null');
        throw const LogInWithGoogleFailure('No Access Token found.');
      }
      if (idToken == null) {
        logE('[SupabaseAuth] idToken bị null');
        throw const LogInWithGoogleFailure('No ID Token found.');
      }

      logD('[SupabaseAuth] Đang gọi signInWithIdToken...');
      try {
        await _powerSyncRepository.supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        logD('[SupabaseAuth] signInWithIdToken thành công!');
      } on supabase.AuthException catch (e) {
        logE(
          '[SupabaseAuth] Lỗi AuthException từ Supabase: message=${e.message}, status=${e.statusCode}',
        );
        rethrow;
      } catch (e) {
        logE('[SupabaseAuth] Lỗi không xác định khi signInWithIdToken: $e');
        rethrow;
      }
    } on LogInWithGoogleCanceled {
      rethrow;
    } catch (error, stackTrace) {
      logE(
        '[SupabaseAuth] logInWithGoogle thất bại',
        error: error,
        stackTrace: stackTrace,
      );
      Error.throwWithStackTrace(LogInWithGoogleFailure(error), stackTrace);
    }
  }

  /// Starts the Sign In with Github Flow.
  ///
  /// Throws a [LogInWithGithubCanceled] if the flow is canceled by the user.
  /// Throws a [LogInWithGithubFailure] if an exception occurs.
  @override
  Future<void> logInWithGithub() async {
    try {
      await _powerSyncRepository.supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb
            ? null
            : 'com.khacanh.flutter_luminous_clone://login-callback',
      );
    } on LogInWithGithubCanceled {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogInWithGithubFailure(error), stackTrace);
    }
  }

  @override
  Future<void> signUpWithPassword({
    required String password,
    required String fullName,
    required String username,
    String? avatarUrl,
    String? email,
    String? phone,
    String? pushToken,
  }) async {
    final data = {
      'full_name': fullName,
      'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (pushToken != null) 'push_token': pushToken,
    };
    try {
      await _powerSyncRepository.supabase.auth.signUp(
        email: email,
        phone: phone,
        password: password,
        data: data,
        emailRedirectTo: kIsWeb
            ? null
            : 'com.khacanh.flutter_luminous_clone://login-callback',
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(SignUpWithPasswordFailure(error), stackTrace);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _powerSyncRepository.resetPassword(
        email: email,
        redirectTo: redirectTo,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        SendPasswordResetEmailFailure(error),
        stackTrace,
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  }) async {
    try {
      await _powerSyncRepository.verifyOTP(
        token: token,
        email: email,
      );
      await _powerSyncRepository.updateUser(password: newPassword);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(ResetPasswordFailure(error), stackTrace);
    }
  }

  /// Signs out the current user which will emit
  /// [AuthenticationUser.anonymous] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  @override
  Future<void> logOut() async {
    try {
      await _powerSyncRepository.db().disconnectAndClear();
      await _powerSyncRepository.supabase.auth.signOut();
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(LogOutFailure(error), stackTrace);
    }
  }

  /// Updates the user token in [TokenStorage] if the user is authenticated.
  Future<void> _onUserChanged(AuthenticationUser user) async {
    if (!user.isAnonymous) {
      await _tokenStorage.saveToken(user.id);
    } else {
      await _tokenStorage.clearToken();
    }
  }
}

extension on supabase.User {
  AuthenticationUser get toUser {
    return AuthenticationUser(
      id: id,
      email: email,
      fullName: userMetadata?['full_name'] as String?,
      username: userMetadata?['username'] as String?,
      avatarUrl: userMetadata?['avatar_url'] as String?,
      pushToken: userMetadata?['push_token'] as String?,
      isNewUser: createdAt == lastSignInAt,
    );
  }
}
