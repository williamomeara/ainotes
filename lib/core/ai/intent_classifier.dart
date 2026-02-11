import '../../features/unified_input/domain/input_intent.dart';

abstract class IntentClassifier {
  Future<InputIntent> classify(String text);
}
