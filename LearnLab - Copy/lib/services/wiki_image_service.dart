import 'dart:convert';
import 'package:http/http.dart' as http;

class WikiImageService {
  Future<String?> fetchDiagram(String topic) async {
    final url = Uri.parse(
      'https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&format=json&pithumbsize=600&titles=$topic',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final pages = data['query']['pages'] as Map<String, dynamic>;
    final page = pages.values.first as Map<String, dynamic>;
    return (page['thumbnail']?['source']) as String?;
  }
}
