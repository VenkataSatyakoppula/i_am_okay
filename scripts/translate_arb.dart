// ignore_for_file: avoid_print

/// Script to translate app_en.arb to app_fr.arb using Google Cloud Translation API v2.
///
/// Prerequisites:
/// 1. Enable Cloud Translation API in your Google Cloud project
/// 2. Create an API key at https://console.cloud.google.com/apis/credentials
/// 3. Set environment variable: GOOGLE_CLOUD_TRANSLATION_API_KEY=your_api_key
///
/// Run: dart run scripts/translate_arb.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String apiKeyEnv = 'GOOGLE_CLOUD_TRANSLATION_API_KEY';
const String arbEnPath = 'lib/l10n/app_en.arb';
const String arbFrPath = 'lib/l10n/app_fr.arb';
const String apiUrl = 'https://translation.googleapis.com/language/translate/v2';

Future<void> main() async {
  final apiKey = Platform.environment[apiKeyEnv];
  if (apiKey == null || apiKey.isEmpty) {
    print('Error: Set $apiKeyEnv environment variable with your Google Cloud Translation API key.');
    exit(1);
  }

  final enFile = File(arbEnPath);
  if (!await enFile.exists()) {
    print('Error: $arbEnPath not found.');
    exit(1);
  }

  final enContent = await enFile.readAsString();
  final enJson = jsonDecode(enContent) as Map<String, dynamic>;

  final toTranslate = <String, String>{};
  for (final entry in enJson.entries) {
    final key = entry.key;
    if (key.startsWith('@')) continue;
    final value = entry.value;
    if (value is String && value.isNotEmpty) {
      toTranslate[key] = value;
    }
  }

  if (toTranslate.isEmpty) {
    print('No strings to translate.');
    exit(0);
  }

  print('Translating ${toTranslate.length} strings from English to French...');

  final frJson = Map<String, dynamic>.from(enJson);
  final batchSize = 100; // API allows up to 128 strings per request
  final keys = toTranslate.keys.toList();

  for (var i = 0; i < keys.length; i += batchSize) {
    final batchKeys = keys.skip(i).take(batchSize).toList();
    final texts = batchKeys.map((k) => toTranslate[k]!).toList();
    final body = {'q': texts, 'target': 'fr', 'format': 'text'};
    final response = await http.post(
      Uri.parse('$apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      print('API error ${response.statusCode}: ${response.body}');
      exit(1);
    }

    final respBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data = respBody['data'] as Map<String, dynamic>?;
    final translations = data?['translations'] as List<dynamic>? ?? [];

    for (var j = 0; j < batchKeys.length && j < translations.length; j++) {
      final trans = translations[j] as Map<String, dynamic>;
      frJson[batchKeys[j]] = trans['translatedText'] as String? ?? toTranslate[batchKeys[j]];
    }
    print('  Translated ${(i + batchKeys.length).clamp(0, keys.length)}/${keys.length}');
  }

  frJson['@@locale'] = 'fr';
  final frContent = const JsonEncoder.withIndent('  ').convert(frJson);
  await File(arbFrPath).writeAsString('$frContent\n');
  print('Wrote $arbFrPath');
}
