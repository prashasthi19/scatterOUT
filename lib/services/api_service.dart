import 'package:http/http.dart' as http;

class ApiService {
  // Replace these with your Colab API endpoints
  static const String endpoint1 = 'https://colab-endpoint-1-url';
  static const String endpoint2 = 'https://colab-endpoint-2-url';

  static Future<void> triggerEndpoints() async {
    try {
      await http.get(Uri.parse(endpoint1));
      await http.get(Uri.parse(endpoint2));
      print('✅ Colab endpoints triggered successfully');
    } catch (e) {
      print('❌ Error triggering endpoints: $e');
    }
  }
}
