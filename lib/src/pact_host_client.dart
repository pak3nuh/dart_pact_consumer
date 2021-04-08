
import 'dart:convert';
import 'dart:io';

import 'package:dart_pact_consumer/src/functional.dart';
import 'package:dart_pact_consumer/src/pact_contract_dto.dart';

class PactHost {

  final String _hostUri;
  final Lazy<HttpClient> _lazyClient;
  HttpClient get _client => _lazyClient.value;

  PactHost(this._hostUri, {
    HttpClient client
  }): _lazyClient = Lazy(client, () => HttpClient()) ;

  Future<void> publishContract(Contract contract, String version) async {
    final urlStr = '${_pactUrl(contract.provider.name, contract.consumer.name)}/version/$version';
    
    var uri = Uri.parse(urlStr);
    final request = await _client.putUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(contract.toJson()));

    final response = await request.close();

    _validateStatus(response, uri);
  }

  String _pactUrl(String provider, String consumer) {
    return '$_hostUri/pacts/provider/${provider}/consumer/''${consumer}';
  }

  String _participantUrl(String participant) {
    return '$_hostUri/pacticipants/$participant';
  }

  void _validateStatus(HttpClientResponse response, Uri uri) {
    var statusCode = response.statusCode;
    if (statusCode ~/ 100 != 2) {
      throw HttpException('Status code not success: $statusCode.'
          'Reason: ${response.reasonPhrase}', uri: uri);
    }
  }

  Future<void> addTag(String participant, String version, String tag) async {
    final pactUrl = '${_participantUrl(participant)}/versions/$version/tags/$tag';
    var uri = Uri.parse(pactUrl);
    final request = await _client.putUrl(uri);
    request.headers.contentType = ContentType.json;
    final response =  await request.close();
    _validateStatus(response, uri);
  }

  Future<void> addLabel(String participant, String label) async {
    final pactUrl = '${_participantUrl(participant)}/labels/$label';
    var uri = Uri.parse(pactUrl);
    final request = await _client.putUrl(uri);
    request.headers.contentType = ContentType.json;
    final response =  await request.close();
    _validateStatus(response, uri);
  }
}
