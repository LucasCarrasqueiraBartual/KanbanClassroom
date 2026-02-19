import 'package:http/http.dart' as http;

// Su función principal es adjuntar automáticamente cabeceras de autenticación (como el Token de Google)
class AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
