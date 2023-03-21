import 'dart:convert';
import 'dart:io';

import 'package:dart_pact_consumer/src/functional.dart';
import 'package:dart_pact_consumer/src/pact_contract_dto.dart';

class PactHost {
  final String _hostUri;
  final Default<HttpClient> _lazyClient;

  HttpClient get _client => _lazyClient.value;

  PactHost(this._hostUri, {HttpClient? client})
      : _lazyClient = Default.fromNullable(client, () => HttpClient());

  Future<void> publishContract(Pact contract, String version) async {
    final urlStr =
        '${_pactUrl(contract.provider.name, contract.consumer.name)}/version/$version';

    var uri = Uri.parse(urlStr);
    final request = await _client.putUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(contract.toJson()));

    await _doRequest(request);
  }

  String _pactUrl(String provider, String consumer) {
    return '$_hostUri/pacts/provider/${provider}/consumer/' '${consumer}';
  }

  String _participantUrl(String participant) {
    return '$_hostUri/pacticipants/$participant';
  }

  Future<void> _doRequest(HttpClientRequest request) async {
    final response = await request.close();
    var statusCode = response.statusCode;
    if (statusCode ~/ 100 != 2) {
      final content = await _getContent(response);
      throw PactHostException(
          response.statusCode, response.reasonPhrase, content);
    }
  }

  Future<void> addTag(String participant, String version, String tag) async {
    final pactUrl =
        '${_participantUrl(participant)}/versions/$version/tags/$tag';
    var uri = Uri.parse(pactUrl);
    final request = await _client.putUrl(uri);
    request.headers.contentType = ContentType.json;
    await _doRequest(request);
  }

  Future<void> addLabel(String participant, String label) async {
    final pactUrl = '${_participantUrl(participant)}/labels/$label';
    var uri = Uri.parse(pactUrl);
    final request = await _client.putUrl(uri);
    request.headers.contentType = ContentType.json;
    await _doRequest(request);
  }

  Future<void> deleteParticipant(String participant) async {
    final pactUrl = '${_participantUrl(participant)}';
    var uri = Uri.parse(pactUrl);
    final request = await _client.deleteUrl(uri);
    request.headers.contentType = ContentType.json;
    await _doRequest(request);
  }

  Future<String> _getContent(HttpClientResponse response) async {
    if (response.contentLength == 0) {
      return '';
    }
    final contentType = response.headers.contentType;
    if (contentType?.mimeType == ContentType.json.mimeType ||
        contentType?.mimeType == ContentType.text.mimeType) {
      return response.fold<List<int>>([], (prev, elem) => prev..addAll(elem))
          // todo fixed encoding
          .then((value) => utf8.decode(value));
    }
    return '';
  }

  void close({bool force = false}) {
    _client.close(force: force);
  }
}

class PactHostException {
  PactHostException(this.statusCode, this.reason, this.content);

  final int statusCode;
  final String reason;
  final String content;

  @override
  String toString() {
    return '''Status code: $statusCode
Reason: $reason
Content: $content''';
  }
}
