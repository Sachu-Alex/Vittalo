# ML Model Files

Place your TFLite model files here before building:

## Required Files

| File | Description | Size target |
|------|-------------|-------------|
| `regression_model.tflite` | Resale price regression model | < 2 MB |
| `bert_tiny.tflite` | BERT-Tiny NLP classifier | < 20 MB |
| `bert_vocab.txt` | BERT tokenizer vocabulary | ~230 KB |

## Input / Output Spec

### regression_model.tflite
- **Input**: `[1, 9]` float32 tensor
  - `[original_price_normalized, age_months_normalized, condition_0_to_1,`
  - `damage_flag, issue_flag, accessories_flag, category_encoded_0_to_1,`
  - `urgency_score, condition_nlp_score]`
- **Output**: `[1, 1]` float32 — predicted base price (normalized 0–1, multiply by max_price)

### bert_tiny.tflite
- **Input**: `[1, 128]` int32 token IDs (padded/truncated)
- **Output**: `[1, 3]` float32 — [urgency_score, condition_score, confidence]

## Training Notes

The heuristic fallback in `ml_service.dart` and `nlp_service.dart`
approximates what a trained model would output.
Once model files are placed here and `_modelLoaded = true` is set,
actual TFLite inference replaces the heuristic automatically.
