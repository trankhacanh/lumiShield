// ignore_for_file: unnecessary_ignore, unused_local_variable

import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:lumi_blocks/lumi_blocks.dart';
import 'package:shared/shared.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeedView();
  }
}

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = List.generate(
      10,
      (index) => PostLargeBlock(
        id: uuid.v4(),
        author: PostAuthor.randomConfirmed(),
        createdAt: DateTime.now().subtract(
          Duration(days: Random().nextInt(365)),
        ),
        media: [
          ImageMedia(
            id: uuid.v4(),
            url:
                'https://tse3.mm.bing.net/th/id/OIP.gUMbXsPoxKuhFYT81YQVgwHaEK?pid=ImgDet&w=474&h=266&rs=1&o=7&rm=3',
          ),
        ],
        caption: 'Lorem ipsum dolor sit amet',
      ),
    );

    return AppScaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: feed.length,
              itemBuilder: (context, index) {
                final post = feed[index];
                return Image.network(post.firstMediaUrl!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
