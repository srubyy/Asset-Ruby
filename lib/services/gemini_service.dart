import 'dart:convert';
import 'package:http/http.dart' as http;

/// Calls the Gemini 1.5 Flash REST API to perform real AI mutation analysis.
/// Uses Google AI Studio API key (free tier available at aistudio.google.com).
class GeminiService {
  // Paste your Google AI Studio API key here:
  // Get one free at: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyDEMO_REPLACE_WITH_YOUR_KEY';

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Analyzes a piracy case and returns structured mutation analysis from Gemini.
  static Future<GeminiAnalysisResult> analyzeMutations({
    required String assetName,
    required String assetHash,
    required String platform,
    required double confidence,
  }) async {
    final prompt = '''
You are a digital forensics AI working for a sports media rights protection company.
Analyze the following piracy case and return a detailed mutation analysis report.

PROTECTED ASSET: "$assetName"
ORIGINAL FINGERPRINT HASH: $assetHash
DETECTED ON PLATFORM: $platform
AI MATCH CONFIDENCE: ${(confidence * 100).toStringAsFixed(1)}%

Perform the following analysis and return JSON in EXACTLY this format (no markdown, no code blocks):
{
  "evasionScore": <integer 0-100>,
  "sophisticationLevel": "<BASIC|INTERMEDIATE|ADVANCED|NATION-STATE>",
  "leakSource": "<your assessment of how this leaked>",
  "leakRegion": "<most likely geographic origin>",
  "mutations": [
    {
      "name": "<mutation name>",
      "confidence": <float 0.0-1.0>,
      "detail": "<specific technical detail>",
      "type": "<watermark|temporal|color|encoding>"
    }
  ],
  "recommendation": "<one-sentence action recommendation>",
  "threatActor": "<brief profile of likely attacker>"
}

Base your analysis on realistic piracy evasion techniques used against sports broadcast content.
Be specific, technical, and realistic. Return ONLY the JSON object.
''';

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final rawText = data['candidates'][0]['content']['parts'][0]['text'] as String;

    // Parse the JSON from Gemini's response
    final cleaned = rawText.trim().replaceAll('```json', '').replaceAll('```', '').trim();
    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;

    return GeminiAnalysisResult.fromJson(parsed);
  }
}

class GeminiAnalysisResult {
  final int evasionScore;
  final String sophisticationLevel;
  final String leakSource;
  final String leakRegion;
  final List<GeminiMutation> mutations;
  final String recommendation;
  final String threatActor;

  GeminiAnalysisResult({
    required this.evasionScore,
    required this.sophisticationLevel,
    required this.leakSource,
    required this.leakRegion,
    required this.mutations,
    required this.recommendation,
    required this.threatActor,
  });

  factory GeminiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return GeminiAnalysisResult(
      evasionScore: (json['evasionScore'] as num).toInt(),
      sophisticationLevel: json['sophisticationLevel'] as String? ?? 'INTERMEDIATE',
      leakSource: json['leakSource'] as String? ?? 'Unknown',
      leakRegion: json['leakRegion'] as String? ?? 'Unknown',
      mutations: (json['mutations'] as List<dynamic>? ?? [])
          .map((m) => GeminiMutation.fromJson(m as Map<String, dynamic>))
          .toList(),
      recommendation: json['recommendation'] as String? ?? '',
      threatActor: json['threatActor'] as String? ?? '',
    );
  }
}

class GeminiMutation {
  final String name;
  final double confidence;
  final String detail;
  final String type;

  GeminiMutation({
    required this.name,
    required this.confidence,
    required this.detail,
    required this.type,
  });

  factory GeminiMutation.fromJson(Map<String, dynamic> json) {
    return GeminiMutation(
      name: json['name'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      detail: json['detail'] as String? ?? '',
      type: json['type'] as String? ?? 'encoding',
    );
  }
}
