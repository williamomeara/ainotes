import 'package:flutter/material.dart';

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
