import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
sealed class ChatMessage with _$ChatMessage {
  const factory ChatMessage.user({
    required String text,
    required DateTime timestamp,
  }) = UserMessage;

  const factory ChatMessage.ai({
    required String text,
    required DateTime timestamp,
    @Default([]) List<String> sourceNoteIds,
  }) = AiMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
