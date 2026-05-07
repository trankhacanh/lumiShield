// ignore_for_file: use_null_aware_elements, lines_longer_than_80_chars, document_ignores, public_member_api_docs

import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

abstract class UserBaseRepository {
  const UserBaseRepository();

  String? get currentUserId;

  Stream<User> profile({required String userId});

  /// Updates currently authenticated database user's metadata.
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
  });

  Stream<int> followersCountOf({required String userId});

  Stream<int> followingsCountOf({required String userId});

  /// Returns realtime stream of followings status of the user identified by
  /// [followerId] to the user identified by [userId].
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  });

  /// Follows to the user by provided [followToId]. [followerId] is the id
  /// of currently authenticated user.
  Future<void> follow({
    required String followToId,
    String? followerId,
  });

  /// Unfollow from user profile, identified by [unfollowId].
  Future<void> unfollow({required String unfollowId, String? unfollowerId});

  /// Removes follower from followers of current users.
  Future<void> removeFollower({required String id});

  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  });

  Stream<List<User>> followers({required String userId});

  /// Returns a list of followings of the user identified by [userId].
  Future<List<User>> getFollowings({String? userId});
}

abstract class PostsBaseRepository {
  const PostsBaseRepository();

  Stream<int> postsAmountOf({required String userId});

  /// Create a new post with provided details.
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  });

  /// Fetches the profiles of users who liked the post, identified by [postId]
  /// and who are in followings of the user identified by current user `id`.
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  });

  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  });
}

/// {@template database_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
abstract class DatabaseClient
    implements UserBaseRepository, PostsBaseRepository {
  /// {@macro database_client}
  const DatabaseClient();
}

class PowerSyncDatabaseClient extends DatabaseClient {
  const PowerSyncDatabaseClient({
    required PowerSyncRepository powerSyncRepository,
  }) : _powerSyncRepository = powerSyncRepository;

  final PowerSyncRepository _powerSyncRepository;
  @override
  String? get currentUserId =>
      _powerSyncRepository.supabase.auth.currentSession?.user.id;

  @override
  Stream<User> profile({required String userId}) => _powerSyncRepository
      .db()
      .watch(
        '''
      SELECT * FROM profiles WHERE id = ?
      ''',
        parameters: [userId],
      )
      .map(
        (event) => event.isEmpty ? User.anonymous : User.fromJson(event.first),
      );

  @override
  Stream<int> postsAmountOf({required String userId}) => _powerSyncRepository
      .db()
      .watch(
        '''
    SELECT COUNT(*) as posts_count FROM posts where user_id = ?
    ''',
        parameters: [userId],
      )
      .map(
        (event) => event.first['posts_count'] as int,
      );

  @override
  Stream<int> followersCountOf({required String userId}) => _powerSyncRepository
      .db()
      .watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscribed_to_id = ?',
        parameters: [userId],
      )
      .map(
        (event) => event.first['subscription_count'] as int,
      );

  @override
  Stream<int> followingsCountOf({required String userId}) =>
      _powerSyncRepository
          .db()
          .watch(
            'SELECT COUNT(*) AS subscription_count FROM subscriptions '
            'WHERE subscriber_id = ?',
            parameters: [userId],
          )
          .map(
            (event) => event.first['subscription_count'] as int,
          );

  @override
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) {
    if (followerId == null && currentUserId == null) {
      return const Stream.empty();
    }
    return _powerSyncRepository
        .db()
        .watch(
          '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
          parameters: [followerId ?? currentUserId, userId],
        )
        .map((event) => event.isNotEmpty);
  }

  @override
  Future<void> follow({
    required String followToId,
    String? followerId,
  }) async {
    if (currentUserId == null) return;
    if (followToId == currentUserId) return;
    final exists = await isFollowed(
      followerId: followerId ?? currentUserId!,
      userId: followToId,
    );
    if (!exists) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO subscriptions(id, subscriber_id, subscribed_to_id)
            VALUES(uuid(), ?, ?)
      ''',
        [followerId ?? currentUserId!, followToId],
      );
      return;
    }
    await unfollow(
      unfollowId: followToId,
      unfollowerId: followerId ?? currentUserId!,
    );
  }

  @override
  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      [followerId ?? currentUserId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Future<void> unfollow({
    required String unfollowId,
    String? unfollowerId,
  }) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [unfollowerId ?? currentUserId, unfollowId],
    );
  }

  @override
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  }) async {
    if (currentUserId == null) return null;
    final result = await Future.wait([
      _powerSyncRepository.db().execute(
        '''
    INSERT INTO posts(id, user_id, caption, media, created_at)
    VALUES(?, ?, ?, ?, ?)
    RETURNING *
    ''',
        [
          id,
          currentUserId,
          caption,
          media,
          DateTime.timestamp().toIso8601String(),
        ],
      ),
      _powerSyncRepository.db().get(
        '''
SELECT * FROM profiles WHERE id = ?
''',
        [currentUserId],
      ),
    ]);
    if (result.isEmpty) return null;
    final row = Map<String, dynamic>.from((result.first as ResultSet).first);
    final author = User.fromJson(result.last as Row);
    return Post.fromJson(row).copyWith(author: author);
  }

  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  inner join profiles p on posts.user_id = p.id 
ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
    ''',
      [limit, offset],
    );

    final instaBlocks = result.map((row) {
      final json = Map<String, dynamic>.from(row);
      return Post.fromJson(json);
    });
    return instaBlocks.toList();
  }

  @override
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT id, avatar_url, username, full_name
FROM profiles
WHERE id IN (
    SELECT l.user_id
    FROM likes l
    WHERE l.post_id = ?1
    AND EXISTS (
        SELECT *
        FROM subscriptions f
        WHERE f.subscribed_to_id = l.user_Id
        AND f.subscriber_id = ?2
    ) AND id <> ?2
)
LIMIT ?3 OFFSET ?4
''',
      [postId, currentUserId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Future<List<User>> getFollowings({String? userId}) async {
    final followingsUserId = await _powerSyncRepository.db().getAll(
      'SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ? ',
      [userId ?? currentUserId],
    );
    if (followingsUserId.isEmpty) return [];

    final followings = <User>[];
    for (final followingsUserId in followingsUserId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followingsUserId['subscribed_to_id']],
      );
      if (result.isEmpty) continue;
      final following = User.fromJson(result.first);
      followings.add(following);
    }
    return followings;
  }

  @override
  Stream<List<User>> followers({required String userId}) async* {
    final streamResult = _powerSyncRepository.db().watch(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      parameters: [userId],
    );
    await for (final result in streamResult) {
      final followers = <User>[];
      final followersFutures = await Future.wait(
        result
            .where((row) => row.isNotEmpty)
            .safeMap(
              (row) => _powerSyncRepository.db().getOptional(
                'SELECT * FROM profiles WHERE id = ?',
                [row['subscriber_id']],
              ),
            ),
      );
      for (final user in followersFutures) {
        if (user == null) continue;
        final follower = User.fromJson(user);
        followers.add(follower);
      }
      yield followers;
    }
  }

  @override
  Future<void> removeFollower({required String id}) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [id, currentUserId],
    );
  }

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
    String? password,
  }) => _powerSyncRepository.updateUser(
    email: email,
    password: password,
    data: {
      if (fullName != null) 'full_name': fullName,
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (pushToken != null) 'push_token': pushToken,
    },
  );
}
