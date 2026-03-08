import 'package:flutter_test/flutter_test.dart';
import 'package:ainotes/core/ai/mock_intent_classifier.dart';
import 'package:ainotes/features/unified_input/domain/input_intent.dart';

void main() {
  group('MockIntentClassifier', () {
    late MockIntentClassifier classifier;

    setUp(() {
      classifier = MockIntentClassifier();
    });

    test('detects questions', () async {
      final intent = await classifier.classify('What did I say about groceries?');
      expect(intent, isA<QuestionIntent>());
    });

    test('detects shopping notes', () async {
      final intent = await classifier.classify('buy milk and eggs');
      expect(intent, isA<NoteIntent>());
      expect((intent as NoteIntent).suggestedCategoryName, 'shopping');
    });

    test('detects todo notes', () async {
      final intent = await classifier.classify('remind me to call the dentist');
      expect(intent, isA<NoteIntent>());
      expect((intent as NoteIntent).suggestedCategoryName, 'todos');
    });

    test('detects idea notes', () async {
      final intent =
          await classifier.classify('I have an idea for a new app');
      expect(intent, isA<NoteIntent>());
      expect((intent as NoteIntent).suggestedCategoryName, 'ideas');
    });

    test('defaults to general', () async {
      final intent = await classifier.classify('The weather is nice today');
      expect(intent, isA<NoteIntent>());
      expect((intent as NoteIntent).suggestedCategoryName, 'general');
    });

    test('case insensitive', () async {
      final intent = await classifier.classify('HOW do I fix this?');
      expect(intent, isA<QuestionIntent>());
    });
  });
}
