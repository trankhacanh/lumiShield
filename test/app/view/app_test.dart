import 'package:flutter/material.dart';
import 'package:flutter_luminous_clone/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockPostsRepository extends Mock implements PostsRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('App', () {
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(
        App(
          user: MockUser(),
          userRepository: MockUserRepository(),
          postsRepository: MockPostsRepository(),
        ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
