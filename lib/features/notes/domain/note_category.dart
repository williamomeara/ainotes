import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum NoteCategory {
  shopping,
  todos,
  ideas,
  general;

  String get label => switch (this) {
        shopping => 'Shopping',
        todos => 'Todos',
        ideas => 'Ideas',
        general => 'General',
      };

  IconData get icon => switch (this) {
        shopping => Icons.shopping_cart_outlined,
        todos => Icons.check_circle_outline,
        ideas => Icons.lightbulb_outline,
        general => Icons.note_outlined,
      };

  Color color(AppColors colors) => switch (this) {
        shopping => colors.shopping,
        todos => colors.todos,
        ideas => colors.ideas,
        general => colors.general,
      };
}

enum NoteSource {
  voice,
  text,
  photo,
  document,
  webClip;

  String get label => switch (this) {
        voice => 'Voice',
        text => 'Text',
        photo => 'Photo',
        document => 'Document',
        webClip => 'Web Clip',
      };

  IconData get icon => switch (this) {
        voice => Icons.mic_outlined,
        text => Icons.edit_outlined,
        photo => Icons.camera_alt_outlined,
        document => Icons.description_outlined,
        webClip => Icons.language_outlined,
      };
}
