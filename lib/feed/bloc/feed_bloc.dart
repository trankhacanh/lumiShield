import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lumi_blocks/lumi_blocks.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required PostsRepository postsRepository,
  }) : _postsRepository = postsRepository,
       super(const FeedState.initial()) {
    on<FeedPageRequested>(_onFeedPageRequested);
  }

  final PostsRepository _postsRepository;

  static const _feedPageLimit = 10;

  Future<void> _onFeedPageRequested(
    FeedPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final currentPage = event.page ?? state.feed.feedPage.page;
      final posts = await _postsRepository.getPage(
        offset: currentPage * _feedPageLimit,
        limit: _feedPageLimit,
      );
      final postLikersFutures = posts.map(
        (post) => _postsRepository.getPostLikersInFollowings(postId: post.id),
      );
      final postLikers = await Future.wait(postLikersFutures);

      final newPage = currentPage + 1;

      final hasMore = posts.length >= _feedPageLimit;

     

    
      
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.failure());
    }
  }
}
