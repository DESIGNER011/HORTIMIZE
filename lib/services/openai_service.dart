import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  OpenAIService({required this.apiKey});

  Future<String> getExpertSuggestion(String query) async {
    try {
      // Construct the prompt to focus on agricultural advice related to India and Tamil Nadu
      final String promptWithContext = """
I need specific, practical agricultural advice for Tamil Nadu, India on this question: "$query"

Please provide detailed information focusing on:
1. Direct answers to the specific question asked
2. Practical recommendations tailored to Tamil Nadu's climate, soil, and market conditions
3. Location-specific data (prices, market trends, climate conditions, etc.)
4. Actionable advice a farmer or gardener can immediately implement

FORMAT YOUR RESPONSE WITH:
- Clear section headings
- Bullet points for recommendations
- Include specific varieties, quantities, and timelines where applicable
- Use metric measurements and Indian Rupees (₹) for any figures

If the question is NOT related to agriculture, farming, gardening, market trends for agricultural products, or rural livelihoods in Tamil Nadu, politely explain that you can only provide agricultural advice for Tamil Nadu, India.
""";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system', 
              'content': 'You are an agricultural expert advisor with deep knowledge of farming in Tamil Nadu, India. You provide practical, specific, actionable advice tailored to local conditions. You focus exclusively on agricultural topics including farming practices, crop selection, market trends, climate adaptation, soil management, pest control, and rural livelihoods. Your expertise covers traditional and modern farming techniques relevant to Tamil Nadu\'s unique agricultural landscape.'
            },
            {'role': 'user', 'content': promptWithContext}
          ],
          'max_tokens': 600,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'].trim();
      } else {
        print('Failed API call: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        if (response.statusCode == 401) {
          return 'Error: API key is invalid or expired. Please update your API key.';
        } else if (response.statusCode == 429) {
          return 'Error: Rate limit exceeded. Please try again later.';
        } else if (response.statusCode >= 500) {
          return 'Error: OpenAI service is currently unavailable. Please try again later.';
        } else {
          try {
            final jsonResponse = jsonDecode(response.body);
            final errorMessage = jsonResponse['error']['message'] ?? 'Unknown error';
            return 'Error: $errorMessage';
          } catch (e) {
            return 'Error: Unable to get expert suggestion at this time. Please try again later.';
          }
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
      return 'Error: Something went wrong while connecting to our experts. Please check your internet connection and try again.';
    }
  }
} 