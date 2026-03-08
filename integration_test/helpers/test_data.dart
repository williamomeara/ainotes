/// A canned test note with raw input and expected pipeline outputs.
class TestNote {
  final String description;
  final String rawInput;
  final String expectedCategory;

  /// Words we expect to find in the rewritten output.
  final List<String> expectedContentWords;

  const TestNote({
    required this.description,
    required this.rawInput,
    required this.expectedCategory, // category name as String
    required this.expectedContentWords,
  });
}

/// A RAG test query with expected behaviour.
class TestQuery {
  final String question;

  /// IDs (indices into [testNotes]) of notes that should be cited.
  final List<int> expectedSourceIndices;

  /// Keywords the answer should contain.
  final List<String> expectedAnswerKeywords;

  const TestQuery({
    required this.question,
    required this.expectedSourceIndices,
    required this.expectedAnswerKeywords,
  });
}

/// 7 canned notes across all categories.
const testNotes = <TestNote>[
  // 0 — shopping (groceries with filler words)
  TestNote(
    description: 'Grocery shopping with filler words',
    rawInput:
        'okay so um I need to buy milk and bread and eggs oh and also coffee and oat milk',
    expectedCategory: 'shopping',
    expectedContentWords: ['milk', 'bread', 'eggs', 'coffee'],
  ),

  // 1 — shopping (hardware store)
  TestNote(
    description: 'Hardware store trip',
    rawInput:
        'I need to get some screws and wood glue from the hardware store also pick up sandpaper',
    expectedCategory: 'shopping',
    expectedContentWords: ['screws', 'glue', 'sandpaper'],
  ),

  // 2 — todos (dentist reminder)
  TestNote(
    description: 'Dentist appointment reminder',
    rawInput:
        'remind me to call the dentist tomorrow morning to schedule a cleaning appointment',
    expectedCategory: 'todos',
    expectedContentWords: ['dentist', 'cleaning', 'appointment'],
  ),

  // 3 — todos (work email)
  TestNote(
    description: 'Work email todo',
    rawInput:
        'I need to send that quarterly report email to Sarah by end of day Friday',
    expectedCategory: 'todos',
    expectedContentWords: ['report', 'email', 'Sarah', 'Friday'],
  ),

  // 4 — idea (app idea)
  TestNote(
    description: 'App feature idea',
    rawInput:
        'idea for the app maybe we could add a feature where you take a photo of a whiteboard and it automatically converts it into organized notes',
    expectedCategory: 'ideas',
    expectedContentWords: ['photo', 'whiteboard', 'notes'],
  ),

  // 5 — general (meeting notes)
  TestNote(
    description: 'Team meeting notes',
    rawInput:
        'meeting notes from the team standup John is working on the new API endpoints and Maria finished the login page redesign',
    expectedCategory: 'general',
    expectedContentWords: ['John', 'API', 'Maria', 'login'],
  ),

  // 6 — general (recipe)
  TestNote(
    description: 'Pasta recipe',
    rawInput:
        'so the recipe for the pasta is boil water add salt cook pasta for eight minutes drain then add butter and parmesan cheese',
    expectedCategory: 'general',
    expectedContentWords: ['pasta', 'butter', 'parmesan'],
  ),
];

/// 4 RAG queries that should match specific notes.
const testQueries = <TestQuery>[
  TestQuery(
    question: 'What groceries do I need to buy?',
    expectedSourceIndices: [0], // grocery shopping note
    expectedAnswerKeywords: ['milk', 'bread', 'eggs'],
  ),
  TestQuery(
    question: 'What appointments do I need to schedule?',
    expectedSourceIndices: [2], // dentist reminder
    expectedAnswerKeywords: ['dentist'],
  ),
  TestQuery(
    question: 'What is John working on?',
    expectedSourceIndices: [5], // meeting notes
    expectedAnswerKeywords: ['API'],
  ),
  TestQuery(
    question: 'How do I make the pasta?',
    expectedSourceIndices: [6], // recipe
    expectedAnswerKeywords: ['pasta', 'parmesan'],
  ),
];
