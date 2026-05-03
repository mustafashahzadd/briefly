import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/news_item.dart';

class NewsRemoteDataSource {
  final GenerativeModel _model;

  NewsRemoteDataSource({required String apiKey})
    : _model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: apiKey);

  Future<List<NewsItem>> fetchNews() async {
    const prompt = '''
Give me 8 of the latest and most important tech news headlines from today.
For each news item, format it exactly like this:
**Headline here** Brief one or two sentence summary of the story.

Only output the news items in that format, nothing else.
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final rawText = response.text ?? '';

    if (rawText.isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    return _parseNews(rawText);
  }

  List<NewsItem> _parseNews(String rawText) {
    final List<NewsItem> news = [];

    final lines =
        rawText.split('\n').where((line) => line.trim().isNotEmpty).toList();

    for (final line in lines) {
      if (line.contains('**')) {
        final regex = RegExp(r'\*\*(.+?)\*\*');
        final match = regex.firstMatch(line);

        if (match != null) {
          final headline = match.group(1) ?? '';
          final body =
              line.replaceAll(regex, '').trim().replaceAll('*', '').trim();

          news.add(
            NewsItem(
              headline: headline,
              body: body.isEmpty ? 'Read more about this tech trend.' : body,
            ),
          );
        }
      }
    }

    return news;
  }
}
