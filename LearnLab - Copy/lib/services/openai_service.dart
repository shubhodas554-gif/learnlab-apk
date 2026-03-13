import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAiService {
  OpenAiService({http.Client? client, String? key})
      : _client = client ?? http.Client(),
        _key = key ?? const String.fromEnvironment('OPENAI_KEY');

  final http.Client _client;
  final String _key;

  Future<String> explain(String prompt) async {
    final res = await _client.post(
      Uri.https('api.openai.com', '/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4.1-mini',
        'messages': [
          {'role': 'system', 'content': 'You are a friendly, beginner science tutor.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
      }),
    );
    if (res.statusCode != 200) throw Exception('OpenAI error: ${res.body}');
    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'];
  }
}
