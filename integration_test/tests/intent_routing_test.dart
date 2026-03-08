import 'package:flutter_test/flutter_test.dart';

import 'package:ainotes/core/ai/mock_intent_classifier.dart';
import 'package:ainotes/features/unified_input/domain/input_intent.dart';

/// Register intent classification routing tests.
///
/// These exercise the MockIntentClassifier regex patterns.
void registerIntentRoutingTests() {
  group('Intent Routing', () {
    late MockIntentClassifier classifier;

    setUp(() {
      classifier = MockIntentClassifier();
    });

    test('questions route to QuestionIntent', () async {
      final questions = [
        'What groceries do I need?',
        'When is my dentist appointment?',
        'Where did I put my keys?',
        'Who is working on the API?',
        'How do I make pasta?',
        'Why did the build fail?',
        'Find my shopping list',
        'Show me recent notes',
      ];

      for (final q in questions) {
        final intent = await classifier.classify(q);
        expect(intent, isA<QuestionIntent>(),
            reason: '"$q" should be classified as a question');
        expect((intent as QuestionIntent).question, equals(q));
      }
    });

    test('shopping statements route to NoteIntent with shopping category',
        () async {
      final inputs = [
        'buy milk and eggs',
        'I need to get some bread',
        'purchase new headphones',
        'pick up dry cleaning',
        'grocery list for this week',
      ];

      for (final input in inputs) {
        final intent = await classifier.classify(input);
        expect(intent, isA<NoteIntent>(),
            reason: '"$input" should be classified as a note');
        expect((intent as NoteIntent).suggestedCategoryName,
            equals('shopping'),
            reason: '"$input" should be classified as shopping');
      }
    });

    test('todo statements route to NoteIntent with todos category', () async {
      final inputs = [
        'remind me to call the dentist',
        'I need to send the report',
        'dont forget to water the plants',
        'todo: review the pull request',
      ];

      for (final input in inputs) {
        final intent = await classifier.classify(input);
        expect(intent, isA<NoteIntent>(),
            reason: '"$input" should be classified as a note');
        expect(
            (intent as NoteIntent).suggestedCategoryName, equals('todos'),
            reason: '"$input" should be classified as todos');
      }
    });

    test('idea statements route to NoteIntent with ideas category', () async {
      final inputs = [
        'idea for a new feature',
        'concept for the redesign',
        'maybe we could add dark mode',
        'brainstorm session topics',
      ];

      for (final input in inputs) {
        final intent = await classifier.classify(input);
        expect(intent, isA<NoteIntent>(),
            reason: '"$input" should be classified as a note');
        expect((intent as NoteIntent).suggestedCategoryName,
            equals('ideas'),
            reason: '"$input" should be classified as ideas');
      }
    });

    test('general statements route to NoteIntent with general category',
        () async {
      final inputs = [
        'The weather is nice today',
        'Meeting notes from standup',
        'Pasta recipe with parmesan',
      ];

      for (final input in inputs) {
        final intent = await classifier.classify(input);
        expect(intent, isA<NoteIntent>(),
            reason: '"$input" should be classified as a note');
        expect((intent as NoteIntent).suggestedCategoryName,
            equals('general'),
            reason: '"$input" should be classified as general');
      }
    });
  });
}
