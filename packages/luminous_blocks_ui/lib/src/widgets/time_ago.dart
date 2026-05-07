// ignore_for_file: document_ignores, public_member_api_docs

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:luminous_blocks_ui/luminous_blocks_ui.dart';

class TimeAgo extends StatelessWidget {
  const TimeAgo({required this.createdAt, this.short = false, super.key});

  final bool short;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Text(
      short
          ? BlockSettings().dateTimeDelegate.timeAgoShort(createdAt)
          : BlockSettings().dateTimeDelegate.timeAgo(createdAt),
      overflow: TextOverflow.visible,
      style: context.bodyMedium?.copyWith(color: AppColors.grey),
    ); // Text
  }
}
