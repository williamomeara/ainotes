import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/mock_embedding_engine.dart';
import '../../../core/ai/mock_llm_engine.dart';
import '../../../core/rag/rag_engine.dart';
import '../../models_manager/domain/download_state.dart';
import '../../models_manager/providers/model_manager_provider.dart';
import '../../processing/providers/pipeline_provider.dart';
import '../domain/chat_message.dart';

/// RAG engine provider for Q&A.
final ragEngineProvider = Provider<RAGEngine>((ref) {
  return RAGEngine(
    embeddingEngine: ref.watch(embeddingEngineProvider),
    llmEngine: ref.watch(llmEngineProvider),
    vectorStore: ref.watch(vectorStoreProvider),
  );
});

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  bool _isProcessing = false;

  ChatNotifier(this.ref) : super([]);

  Future<void> sendMessage(String text) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final preview = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    debugPrint('[AiNotes] Chat message: "$preview"');

    // Add user message
    state = [
      ...state,
      ChatMessage.user(text: text, timestamp: DateTime.now()),
    ];

    _setThinking('Thinking...');

    try {
      // Initialize engines
      final llm = ref.read(llmEngineProvider);
      final embedding = ref.read(embeddingEngineProvider);
      debugPrint('[AiNotes] Chat using LLM: ${llm.runtimeType}, Embedding: ${embedding.runtimeType}');

      if (llm is MockLLMEngine) {
        await llm.loadModel('');
        debugPrint('[AiNotes] Chat LLM loaded (mock)');
      } else {
        final modelState = ref.read(modelManagerProvider);
        final llmState = modelState.getDownloadState('qwen-2.5-1.5b');
        if (llmState is Ready && llmState.localPath.isNotEmpty) {
          final modelFile = File(llmState.localPath);
          if (await modelFile.exists()) {
            await llm.loadModel(llmState.localPath);
            debugPrint('[AiNotes] Chat LLM loaded (real)');
          }
        }
      }

      // Load embedding (non-fatal — RAG needs it but we give a specific error)
      var embeddingLoaded = false;
      if (embedding is MockEmbeddingEngine) {
        await embedding.loadModel('');
        embeddingLoaded = true;
        debugPrint('[AiNotes] Chat embedding loaded (mock)');
      } else {
        final modelState = ref.read(modelManagerProvider);
        final embState = modelState.getDownloadState('embedding-gemma-300m');
        if (embState is Ready && embState.localPath.isNotEmpty) {
          try {
            await embedding.loadModel(embState.localPath);
            embeddingLoaded = true;
            debugPrint('[AiNotes] Chat embedding loaded (real)');
          } catch (e) {
            debugPrint('[AiNotes] Chat embedding load failed (non-fatal): $e');
          }
        }
      }

      if (!embeddingLoaded) {
        debugPrint('[AiNotes] Chat: embedding not available, cannot run RAG');
        _replaceThinking(ChatMessage.ai(
          text: "I can't search your notes right now — the embedding model "
              "isn't ready. Check AI Models in Settings to download or "
              "reinstall it.",
          timestamp: DateTime.now(),
        ));
        return;
      }

      debugPrint('[AiNotes] Chat engines loaded, starting RAG query');
      _setThinking('Searching your notes...');

      // Use RAG engine for Q&A
      final ragEngine = ref.read(ragEngineProvider);
      final result = await ragEngine.query(text);

      debugPrint('[AiNotes] RAG result: ${result.answer.length} chars, ${result.sourceNoteIds.length} sources');

      _replaceThinking(ChatMessage.ai(
        text: result.answer,
        timestamp: DateTime.now(),
        sourceNoteIds: result.sourceNoteIds,
      ));
    } catch (e) {
      debugPrint('[AiNotes] Chat/RAG failed: $e');
      final errorMsg = e.toString();
      String userMessage;
      if (errorMsg.contains('load') || errorMsg.contains('model')) {
        userMessage =
            "AI models aren't ready yet. Check AI Models in Settings.";
      } else if (errorMsg.contains('no relevant') ||
          errorMsg.contains('empty')) {
        userMessage =
            "I couldn't find relevant notes. Try adding more notes first!";
      } else {
        userMessage = "Something went wrong processing your question. "
            "Please try again.";
      }
      _replaceThinking(ChatMessage.ai(
        text: userMessage,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isProcessing = false;
    }
  }

  void _setThinking(String text) {
    final messages = [...state];
    // Update existing thinking message or append new one
    final thinkingIdx = messages.lastIndexWhere((m) => m is ThinkingMessage);
    final thinking = ChatMessage.thinking(
      statusText: text,
      timestamp: DateTime.now(),
    );
    if (thinkingIdx >= 0) {
      messages[thinkingIdx] = thinking;
    } else {
      messages.add(thinking);
    }
    state = messages;
  }

  void _replaceThinking(ChatMessage replacement) {
    final messages = [...state];
    final thinkingIdx = messages.lastIndexWhere((m) => m is ThinkingMessage);
    if (thinkingIdx >= 0) {
      messages[thinkingIdx] = replacement;
    } else {
      messages.add(replacement);
    }
    state = messages;
  }

  void clear() {
    state = [];
  }
}
