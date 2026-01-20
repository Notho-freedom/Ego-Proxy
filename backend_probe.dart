import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final url = args.isNotEmpty ? args.first : 'http://localhost:4000/health';
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    stdout.writeln('status: ${response.statusCode}');
    stdout.writeln(body);
  } catch (error) {
    stdout.writeln('error: $error');
  } finally {
    client.close();
  }
}
