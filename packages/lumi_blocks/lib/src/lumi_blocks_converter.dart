import 'package:json_annotation/json_annotation.dart';
import 'package:lumi_blocks/lumi_blocks.dart';

/// {@template LumiBlocksConverter}
/// A [JsonConverter] that supports (de)serializing a `List<LumiBlock>`.
/// {@endtemplate}
class LumiBlocksConverter
    implements JsonConverter<List<LumiBlock>, List<Map<String, dynamic>>> {
  /// {@macro LumiBlocksConverter}
  const LumiBlocksConverter();

  @override
  List<LumiBlock> fromJson(List<Map<String, dynamic>> jsonString) {
    return jsonString
        .map((dynamic e) => LumiBlock.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<LumiBlock> blocks) {
    return blocks.map((b) => b.toJson()).toList();
  }
}
