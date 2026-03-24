import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:vittalo/core/constants/app_constants.dart';
import 'package:vittalo/features/price_estimator/domain/entities/nlp_scores.dart';

// ─── NLP Service (Tiny Transformer — TFLite) ──────────────────────────────────
//
// Model: bert_tiny.tflite  (1.1 MB, float32)
// Vocab: bert_vocab.json   (char-level, 29 tokens + special)
// Input:  [1, 64]  int32 token IDs (char-level, CLS=1 SEP=2 PAD=0)
// Output: [1, 3]   float32  [urgency_score, condition_score, confidence]
//
// Stores raw model bytes so Interpreter is created inside Isolate.run(),
// keeping the main/UI thread completely unblocked during inference.
// ─────────────────────────────────────────────────────────────────────────────

class NlpService {
  NlpService._();
  static final NlpService instance = NlpService._();

  Uint8List? _modelBytes;
  Map<String, int> _vocab = {};

  bool get isModelLoaded => _modelBytes != null && _vocab.isNotEmpty;

  // ─── Initialise ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    debugPrint('[NlpService] initialize() called');
    try {
      final data = await rootBundle.load(AppConstants.bertTinyModelPath);
      _modelBytes = data.buffer.asUint8List();
      debugPrint('[NlpService] bert_tiny.tflite loaded — '
          '${(_modelBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB');

      final vocabJson =
          await rootBundle.loadString('assets/models/bert_vocab.json');
      _vocab = Map<String, int>.from(jsonDecode(vocabJson) as Map);
      debugPrint('[NlpService] vocab loaded — ${_vocab.length} tokens');
    } catch (e, stack) {
      debugPrint('[NlpService] ⚠️  initialization FAILED: $e');
      debugPrint(stack.toString());
      _modelBytes = null;
      _vocab = {};
    }
    debugPrint('[NlpService] isModelLoaded = $isModelLoaded');
  }

  // ─── Public API ──────────────────────────────────────────────────────────────

  Future<NlpScores> analyze({
    required String reasonForSelling,
    required String conditionDescription,
  }) async {
    debugPrint('[NlpService] analyze() called');
    debugPrint('[NlpService]   reasonForSelling    : "$reasonForSelling"');
    debugPrint('[NlpService]   conditionDescription: "$conditionDescription"');

    if (reasonForSelling.isEmpty && conditionDescription.isEmpty) {
      debugPrint('[NlpService] ⏭  empty inputs → returning NlpScores.neutral');
      return NlpScores.neutral;
    }

    final text = '$reasonForSelling $conditionDescription'.toLowerCase();
    debugPrint('[NlpService] combined text (${text.length} chars)');
    debugPrint('[NlpService] isModelLoaded=$isModelLoaded → '
        '${isModelLoaded ? "TFLite isolate" : "heuristic fallback"}');

    final payload = _NlpPayload(
      modelBytes: _modelBytes,
      vocab: Map.unmodifiable(_vocab),
      text: text,
    );
    final scores = await Isolate.run(() => _runNlpInIsolate(payload));
    debugPrint('[NlpService] result → urgency=${scores.urgencyScore}  '
        'condition=${scores.conditionScore}  confidence=${scores.confidence}');
    return scores;
  }
}

// ─── Isolate Payload ──────────────────────────────────────────────────────────

class _NlpPayload {
  final Uint8List? modelBytes;
  final Map<String, int> vocab;
  final String text;
  const _NlpPayload({
    required this.modelBytes,
    required this.vocab,
    required this.text,
  });
}

// ─── NLP Inference (runs in isolate) ─────────────────────────────────────────

const _seqLen = 64;

NlpScores _runNlpInIsolate(_NlpPayload p) {
  // debugPrint works inside isolates — it calls print() under the hood but
  // satisfies the avoid_print lint rule and respects kDebugMode throttling.
  if (p.modelBytes != null && p.vocab.isNotEmpty) {
    debugPrint('[NlpIsolate] model bytes present '
        '(${(p.modelBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB) '
        '— attempting TFLite inference');
    try {
      final interpreter = Interpreter.fromBuffer(p.modelBytes!);
      debugPrint('[NlpIsolate] Interpreter.fromBuffer() succeeded');
      final result = _tfliteNlp(interpreter, p.vocab, p.text);
      interpreter.close();
      debugPrint('[NlpIsolate] TFLite inference complete ✓');
      return result;
    } catch (e) {
      debugPrint('[NlpIsolate] ⚠️  TFLite FAILED: $e — falling back to heuristic');
    }
  } else {
    debugPrint('[NlpIsolate] no model bytes '
        '(modelBytes=${p.modelBytes == null ? "null" : "present"}, '
        'vocabSize=${p.vocab.length}) — using heuristic');
  }
  return _heuristicInference(p.text);
}

NlpScores _tfliteNlp(
    Interpreter interpreter, Map<String, int> vocab, String text) {
  final tokens = _tokenize(vocab, text);
  debugPrint('[NlpIsolate] tokenized: seqLen=$_seqLen  '
      'first5=${tokens.take(5).toList()}  '
      'last2=${tokens.skip(_seqLen - 2).toList()}');

  final inputTensor  = [tokens];
  final outputBuffer = [List.filled(3, 0.0)];

  interpreter.run(inputTensor, outputBuffer);

  final rawUrgency   = outputBuffer[0][0];
  final rawCondition = outputBuffer[0][1];
  final rawConf      = outputBuffer[0][2];
  debugPrint('[NlpIsolate] raw TFLite output → '
      '[$rawUrgency, $rawCondition, $rawConf]');

  final urgency   = rawUrgency.clamp(0.1, 0.95);
  final condition = rawCondition.clamp(0.1, 0.95);
  final conf      = rawConf.clamp(0.3, 0.95);

  return NlpScores(
    urgencyScore:   double.parse(urgency.toStringAsFixed(2)),
    conditionScore: double.parse(condition.toStringAsFixed(2)),
    confidence:     double.parse(conf.toStringAsFixed(2)),
  );
}

/// Char-level tokeniser matching training: [CLS]=1, [SEP]=2, [PAD]=0
List<int> _tokenize(Map<String, int> vocab, String text) {
  final ids = <int>[vocab['[CLS]'] ?? 1];
  for (final ch in text.split('')) {
    ids.add(vocab[ch] ?? 0);
    if (ids.length >= _seqLen - 1) break;
  }
  ids.add(vocab['[SEP]'] ?? 2);
  while (ids.length < _seqLen) {
    ids.add(vocab['[PAD]'] ?? 0);
  }
  return ids;
}

// ─── Heuristic Fallback ───────────────────────────────────────────────────────

NlpScores _heuristicInference(String text) {
  debugPrint('[NlpIsolate] *** HEURISTIC INFERENCE ACTIVE (not TFLite) ***');

  const urgentKw = {
    'urgent', 'immediately', 'asap', 'fast', 'quick', 'emergency',
    'need money', 'cash', 'desperate', 'soon', 'today', 'now',
    'moving', 'relocating', 'leaving',
  };
  const calmKw = {
    'upgrade', 'new phone', 'not needed', 'extra', 'spare',
    'replaced', 'gifted', 'bought new',
  };
  const goodKw = {
    'excellent', 'perfect', 'mint', 'like new', 'pristine', 'flawless',
    'good condition', 'well maintained', 'no scratches', 'original',
    'clean', 'undamaged', 'works great', 'fully functional',
  };
  const poorKw = {
    'broken', 'cracked', 'damaged', 'scratches', 'dents', 'issues',
    'problem', 'fault', 'repair', 'not working', 'dead', 'battery',
    'screen', 'display', 'worn',
  };

  final urgentHits = urgentKw.where(text.contains).length;
  final calmHits   = calmKw.where(text.contains).length;
  final goodHits   = goodKw.where(text.contains).length;
  final poorHits   = poorKw.where(text.contains).length;

  debugPrint('[NlpIsolate] keyword hits → '
      'urgent=$urgentHits  calm=$calmHits  good=$goodHits  poor=$poorHits');

  double urgency   = (0.4 + urgentHits * 0.15 - calmHits * 0.1).clamp(0.1, 0.95);
  double condition = (0.65 + goodHits * 0.10 - poorHits * 0.12).clamp(0.1, 0.95);
  double conf      = text.length > 80 ? 0.78 : (text.length > 20 ? 0.65 : 0.45);

  final seed = text.codeUnits.fold(0, (a, b) => a ^ b);
  final rng  = math.Random(seed);
  urgency   = (urgency   + (rng.nextDouble() - 0.5) * 0.04).clamp(0.1, 0.95);
  condition = (condition + (rng.nextDouble() - 0.5) * 0.04).clamp(0.1, 0.95);

  debugPrint('[NlpIsolate] heuristic result → '
      'urgency=$urgency  condition=$condition  conf=$conf');

  return NlpScores(
    urgencyScore:   double.parse(urgency.toStringAsFixed(2)),
    conditionScore: double.parse(condition.toStringAsFixed(2)),
    confidence:     double.parse(conf.toStringAsFixed(2)),
  );
}
